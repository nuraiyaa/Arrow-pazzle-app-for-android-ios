import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final bool hasGlow;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.borderColor,
    this.hasGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.surfaceBorder;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: hasGlow ? AppColors.brandPrimary.withValues(alpha: 0.4) : effectiveBorderColor,
          width: hasGlow ? 1.5 : 1.0,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
