import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// True edge refraction for glass panes.
///
/// [ui.ImageFilter.shader] only exists on the Impeller backend, so this is live
/// on Android and iOS builds and quietly unavailable on the web preview, which
/// keeps the painted bevel/dispersion look instead. Every entry point here is
/// null-safe and failure-tolerant: if the program will not load or the filter
/// cannot be built, callers fall back to the plain blur.
class LiquidGlassRefraction {
  LiquidGlassRefraction._();

  static const String _asset = 'shaders/liquid_glass.frag';

  static ui.FragmentProgram? _program;
  static bool _loading = false;
  static bool _unavailable = false;

  /// Whether a refraction filter can currently be produced.
  static bool get isReady => _program != null;

  /// Whether the backend could ever support it (Impeller only).
  static bool get isSupported => ui.ImageFilter.isShaderFilterSupported;

  /// Loads the shader once. Safe to call from many widgets; later calls are
  /// no-ops. Returns true when the program is ready.
  static Future<bool> load() async {
    if (_program != null) return true;
    if (_unavailable || _loading) return false;
    if (!isSupported) {
      _unavailable = true;
      return false;
    }
    _loading = true;
    try {
      _program = await ui.FragmentProgram.fromAsset(_asset);
      return true;
    } catch (error, stack) {
      _unavailable = true;
      assert(() {
        debugPrint('Liquid glass refraction unavailable: $error\n$stack');
        return true;
      }());
      return false;
    } finally {
      _loading = false;
    }
  }

  /// Builds a shader configured for one pane. Returns null when unsupported —
  /// the caller should then use its normal blur filter.
  ///
  /// [size] only seeds the mandatory leading vec2, which the engine overwrites
  /// with the real size of the filtered image. Pass the screen size: if a
  /// backend ever skips that injection the shader then treats every fragment as
  /// deep inside the pane, bends nothing, and passes the backdrop through
  /// untouched rather than sampling garbage.
  ///
  /// The caller owns the returned shader and must dispose it.
  static ui.FragmentShader? shaderFor({
    required ui.Size size,
    required double radius,
    required double refraction,
    required double dispersion,
    required double band,
  }) {
    final program = _program;
    if (program == null || size.isEmpty) return null;
    try {
      final shader = program.fragmentShader();
      // 0,1 are the mandatory leading vec2. The engine supplies the size of the
      // filtered image; seeding it keeps the shader sane if it ever does not.
      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);
      shader.setFloat(2, radius);
      shader.setFloat(3, refraction);
      shader.setFloat(4, dispersion);
      shader.setFloat(5, band);
      return shader;
    } catch (error) {
      assert(() {
        debugPrint('Liquid glass refraction shader failed: $error');
        return true;
      }());
      return null;
    }
  }

  /// Wraps [shader] as an image filter, or null if the backend refuses it.
  static ui.ImageFilter? filterFor(ui.FragmentShader shader) {
    try {
      return ui.ImageFilter.shader(shader);
    } catch (error) {
      _unavailable = true;
      assert(() {
        debugPrint('Liquid glass refraction filter rejected: $error');
        return true;
      }());
      return null;
    }
  }
}
