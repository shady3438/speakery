import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _usernameFocus = FocusNode();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscure = true;
  String? _errorMessage;

  _FieldCheck _emailCheck = const _FieldCheck.idle();
  _FieldCheck _usernameCheck = const _FieldCheck.idle();
  Timer? _emailDebounce;
  Timer? _usernameDebounce;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _usernameDebounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  // ── availability checks ───────────────────────────────────────────────────

  /// Both checks are debounced: they fire on a pause in typing, not on every
  /// keystroke, so a long handle costs one read instead of fifteen.
  void _onEmailChanged() {
    if (_isLogin) return;
    _emailDebounce?.cancel();
    final value = _emailController.text.trim();
    if (value.isEmpty) {
      setState(() => _emailCheck = const _FieldCheck.idle());
      return;
    }
    if (!_looksLikeEmail(value)) {
      setState(() => _emailCheck =
          const _FieldCheck.bad('Enter a valid email address.'));
      return;
    }
    // The format is all that can be confirmed before submitting; see
    // _checkEmail for why there is no live "already registered" lookup.
    setState(() =>
        _emailCheck = const _FieldCheck.good('Email format looks right.'));
  }

  void _onUsernameChanged() {
    if (_isLogin) return;
    _usernameDebounce?.cancel();
    final raw = _usernameController.text.trim().toLowerCase();
    if (raw.isEmpty) {
      setState(() => _usernameCheck = const _FieldCheck.idle());
      return;
    }
    final invalid = _usernameProblem(raw);
    if (invalid != null) {
      setState(() => _usernameCheck = _FieldCheck.bad(invalid));
      return;
    }
    setState(() => _usernameCheck = const _FieldCheck.checking());
    _usernameDebounce = Timer(
      const Duration(milliseconds: 550),
      () => _checkUsername(raw),
    );
  }

  bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    final dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1;
  }

  String? _usernameProblem(String value) {
    if (value.length < 3) return 'At least 3 characters.';
    if (value.length > 20) return 'At most 20 characters.';
    for (final unit in value.codeUnits) {
      final isLetter = unit >= 97 && unit <= 122;
      final isDigit = unit >= 48 && unit <= 57;
      final isAllowed = unit == 95 || unit == 46;
      if (!isLetter && !isDigit && !isAllowed) {
        return 'Only letters, numbers, dot and underscore.';
      }
    }
    return null;
  }

  // There is deliberately no live "is this email registered?" lookup.
  //
  // Firebase closed that door on purpose: fetchSignInMethodsForEmail is
  // deprecated, and with email enumeration protection — on by default — it
  // answers "available" for every address, so a live tick would be a
  // confident lie. Building our own public email index would hand anyone a
  // way to test whether a person has an account here, which is the exact
  // attack that protection exists to stop.
  //
  // So the field confirms the format live, and the authoritative answer comes
  // from the server on submit, where _handleAuthError puts the warning back on
  // this field.

  Future<void> _checkUsername(String username) async {
    try {
      final doc =
          await _firestore.collection('usernames').doc(username).get();
      if (!mounted || _usernameController.text.trim().toLowerCase() != username) {
        return;
      }
      setState(() => _usernameCheck = doc.exists
          ? const _FieldCheck.bad('This username is taken.')
          : const _FieldCheck.good('Username is free.'));
    } catch (_) {
      if (!mounted) return;
      setState(() => _usernameCheck = const _FieldCheck.idle());
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin) {
      // A failed availability check is a hard stop; a pending one just waits.
      if (_emailCheck.isBad || _usernameCheck.isBad) {
        setState(() => _errorMessage =
            'Fix the highlighted fields before continuing.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential;

      if (_isLogin) {
        // LOGIN
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // REGISTER
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Create the user profile documents after registration.
        final user = userCredential.user;

        if (user != null) {
          final email = user.email ?? _emailController.text.trim();
          final name = _nameController.text.trim().isEmpty
              ? email.split('@').first
              : _nameController.text.trim();
          final username = _normalizeUsername(
            _usernameController.text.trim().isEmpty
                ? email.split('@').first
                : _usernameController.text.trim(),
          );

          await user.updateDisplayName(name);

          // Claim the handle first. The create rule rejects a second claim, so
          // if two people register the same username at the same moment the
          // loser fails here instead of ending up with a duplicate profile.
          await _firestore.collection('usernames').doc(username).set({
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          await _firestore.collection('users').doc(user.uid).set({
            'email': email,
            'name': name,
            'username': username,
            'usernameLower': username,
            'level': 'A1',
            'xp': 0,
            'streak': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });

          await _firestore.collection('publicProfiles').doc(user.uid).set({
            'name': name,
            'username': username,
            'usernameLower': username,
            'bio': 'Building fluency one lesson at a time.',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home-screen');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _authMessageFor(e);
        if (e.code == 'email-already-in-use') {
          _emailCheck =
              const _FieldCheck.bad('This email is already registered.');
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _isLogin
            ? 'We could not sign you in. Please try again.'
            : 'We could not create the account. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _normalizeUsername(String value) {
    final buffer = StringBuffer();
    for (final unit
        in value.toLowerCase().trim().replaceAll('@', '').codeUnits) {
      final isLetter = unit >= 97 && unit <= 122;
      final isDigit = unit >= 48 && unit <= 57;
      final isAllowedSymbol = unit == 95 || unit == 46;
      if (isLetter || isDigit || isAllowedSymbol) {
        buffer.writeCharCode(unit);
      }
    }
    final username = buffer.toString();
    return username.length >= 3 ? username : 'learner${DateTime.now().year}';
  }

  String _authMessageFor(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account is disabled.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'Email or password is incorrect.',
      'email-already-in-use' => 'This email is already registered.',
      'weak-password' => 'Use at least 6 characters for the password.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      'network-request-failed' => 'Check your internet connection.',
      _ => 'Authentication failed. Please try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: IosDynamicGlassBackdrop(
        primary: tokens.secondaryAccent,
        secondary: tokens.primaryAccent,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 32, 22, 28),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _brandMark(tokens),
                      const SizedBox(height: 32),
                      _formCard(tokens),
                      const SizedBox(height: 18),
                      Text(
                        'Speak. Connect. Grow.',
                        style: TextStyle(
                          color: tokens.textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _brandMark(SpeakeryThemeTokens tokens) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: tokens.brandGradient,
            boxShadow: [
              BoxShadow(
                color: tokens.primaryAccent.withAlpha(90),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        ShaderMask(
          shaderCallback: (bounds) => tokens.brandGradient.createShader(bounds),
          child: const Text(
            'Speakery',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isLogin ? 'Welcome back' : 'Create your account',
          style: TextStyle(
            color: tokens.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _formCard(SpeakeryThemeTokens tokens) {
    return IosLiquidGlassSurface(
      radius: 32,
      blur: 26,
      strong: true,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isLogin) ...[
              _GlassField(
                controller: _nameController,
                focusNode: _nameFocus,
                hint: 'Full name',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.name,
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: 12),
              _GlassField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                hint: 'Username',
                icon: Icons.alternate_email_rounded,
                suffix: _CheckBadge(check: _usernameCheck),
                validator: (v) {
                  final problem = _usernameProblem(
                      (v ?? '').trim().toLowerCase());
                  if (problem != null) return problem;
                  return _usernameCheck.isBad ? _usernameCheck.message : null;
                },
              ),
              if (_usernameCheck.message != null) ...[
                const SizedBox(height: 6),
                _CheckLine(check: _usernameCheck),
              ],
              const SizedBox(height: 12),
            ],
            _GlassField(
              controller: _emailController,
              focusNode: _emailFocus,
              hint: 'Email',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              suffix: _isLogin ? null : _CheckBadge(check: _emailCheck),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your email' : null,
            ),
            if (!_isLogin && _emailCheck.message != null) ...[
              const SizedBox(height: 6),
              _CheckLine(check: _emailCheck),
            ],
            const SizedBox(height: 12),
            _GlassField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: tokens.textMuted,
                  size: 20,
                ),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Use at least 6 characters'
                  : null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _errorMessage!, tokens: tokens),
            ],
            const SizedBox(height: 20),
            _PrimaryGradientButton(
              label: _isLogin ? 'Login' : 'Register',
              loading: _isLoading,
              onTap: _isLoading ? null : _submit,
              gradient: tokens.brandGradient,
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                          _emailCheck = const _FieldCheck.idle();
                          _usernameCheck = const _FieldCheck.idle();
                        });
                      },
                child: Text(
                  _isLogin
                      ? "Don't have an account? Register"
                      : 'Already have an account? Login',
                  style: TextStyle(
                    color: tokens.primaryAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Result of a live "is this free?" lookup, and how it should read.
class _FieldCheck {
  final _CheckState state;
  final String? message;

  const _FieldCheck._(this.state, this.message);

  const _FieldCheck.idle() : this._(_CheckState.idle, null);
  const _FieldCheck.checking() : this._(_CheckState.checking, null);
  const _FieldCheck.good(String message) : this._(_CheckState.good, message);
  const _FieldCheck.bad(String message) : this._(_CheckState.bad, message);

  bool get isBad => state == _CheckState.bad;
  bool get isGood => state == _CheckState.good;
}

enum _CheckState { idle, checking, good, bad }

/// The tick, the warning, or a spinner while the lookup is in flight.
class _CheckBadge extends StatelessWidget {
  final _FieldCheck check;

  const _CheckBadge({required this.check});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: switch (check.state) {
          _CheckState.idle => const SizedBox.shrink(),
          _CheckState.checking => SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(tokens.textMuted),
              ),
            ),
          _CheckState.good => Icon(
              Icons.check_circle_rounded,
              color: tokens.success,
              size: 20,
            ),
          _CheckState.bad => Icon(
              Icons.error_rounded,
              color: tokens.error,
              size: 20,
            ),
        },
      ),
    );
  }
}

/// The one-line explanation under a checked field.
class _CheckLine extends StatelessWidget {
  final _FieldCheck check;

  const _CheckLine({required this.check});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final message = check.message;
    if (message == null) return const SizedBox.shrink();

    final color = check.isGood ? tokens.success : tokens.error;

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Icon(
            check.isGood
                ? Icons.check_rounded
                : Icons.priority_high_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _GlassField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.inputSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.border),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          color: tokens.textPrimary,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: tokens.textMuted,
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: tokens.textMuted, size: 20),
          suffixIcon: suffix,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

class _PrimaryGradientButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  final Gradient gradient;

  const _PrimaryGradientButton({
    required this.label,
    required this.loading,
    required this.onTap,
    required this.gradient,
  });

  @override
  State<_PrimaryGradientButton> createState() =>
      _PrimaryGradientButtonState();
}

class _PrimaryGradientButtonState extends State<_PrimaryGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: widget.gradient,
            boxShadow: widget.onTap == null
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: widget.loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final SpeakeryThemeTokens tokens;

  const _ErrorBanner({required this.message, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: tokens.error.withAlpha(24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokens.error.withAlpha(70)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: tokens.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: tokens.error,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
