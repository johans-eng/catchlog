import 'package:flutter/material.dart';

/// Full-size tappable button with a reliable hit target (min 52px).
class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final Color? color;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.margin,
    this.gradient,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final bg = color ?? const Color(0xFF0A84FF);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: gradient,
              color: gradient == null ? bg : null,
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: radius,
              splashColor: Colors.white24,
              highlightColor: Colors.white12,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.zero,
        ),
        child: child,
      ),
    );
  }
}

/// Tappable row with at least [minHeight] for checkbox-style options.
class AppSwitchRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget title;
  final double minHeight;

  const AppSwitchRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.minHeight = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Row(
            children: [
              Expanded(child: title),
              IgnorePointer(
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: const Color(0xFF0A84FF),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable row with at least [minHeight] for checkbox-style options.
class AppTapRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget title;
  final double minHeight;

  const AppTapRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.minHeight = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Row(
            children: [
              IgnorePointer(
                child: Checkbox(
                  value: value,
                  onChanged: null,
                  activeColor: const Color(0xFF0A84FF),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Expanded(child: title),
            ],
          ),
        ),
      ),
    );
  }
}
