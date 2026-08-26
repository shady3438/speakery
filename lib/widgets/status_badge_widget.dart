import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeStatus { success, warning, error, info, premium, level, neutral }

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final double fontSize;
  final EdgeInsets? padding;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    this.status = BadgeStatus.neutral,
    this.fontSize = 11,
    this.padding,
  });

  Color get _bgColor {
    switch (status) {
      case BadgeStatus.success:
        return AppTheme.success.withAlpha(46);
      case BadgeStatus.warning:
        return AppTheme.warning.withAlpha(46);
      case BadgeStatus.error:
        return AppTheme.error.withAlpha(46);
      case BadgeStatus.info:
        return AppTheme.info.withAlpha(46);
      case BadgeStatus.premium:
        return AppTheme.xpGold.withAlpha(46);
      case BadgeStatus.level:
        return AppTheme.primary.withAlpha(56);
      case BadgeStatus.neutral:
        return AppTheme.glassWhite;
    }
  }

  Color get _textColor {
    switch (status) {
      case BadgeStatus.success:
        return AppTheme.success;
      case BadgeStatus.warning:
        return AppTheme.warning;
      case BadgeStatus.error:
        return AppTheme.error;
      case BadgeStatus.info:
        return AppTheme.info;
      case BadgeStatus.premium:
        return AppTheme.xpGold;
      case BadgeStatus.level:
        return AppTheme.primaryLight;
      case BadgeStatus.neutral:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _textColor.withAlpha(77), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
