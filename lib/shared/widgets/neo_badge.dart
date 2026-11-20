import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'neo_icon.dart';

class NeoBadge extends StatelessWidget {
  final String text;
  final NeoIconType? icon;
  final Color? iconColor;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const NeoBadge({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
    this.backgroundColor = AppColors.surfaceCardElevated,
    this.textColor = AppColors.textPrimary,
    this.onTap,
  });

  factory NeoBadge.coins(int coins, {VoidCallback? onTap}) {
    return NeoBadge(
      text: coins.toString(),
      icon: NeoIconType.coin,
      iconColor: AppColors.accentGold,
      backgroundColor: AppColors.surfaceCard,
      onTap: onTap,
    );
  }

  factory NeoBadge.hearts(int hearts, {int maxHearts = 3, VoidCallback? onTap}) {
    return NeoBadge(
      text: '$hearts/$maxHearts',
      icon: NeoIconType.heart,
      iconColor: AppColors.accentWarning,
      backgroundColor: AppColors.surfaceCard,
      onTap: onTap,
    );
  }

  factory NeoBadge.level(int level) {
    return NeoBadge(
      text: 'LVL $level',
      icon: NeoIconType.star,
      iconColor: AppColors.brandPrimary,
      backgroundColor: AppColors.brandPrimary.withOpacity(0.15),
      textColor: AppColors.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            NeoIcon(type: icon!, size: 14, color: iconColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: badge);
    }
    return badge;
  }
}
