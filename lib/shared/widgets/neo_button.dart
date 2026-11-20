import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'neo_icon.dart';

enum NeoButtonVariant {
  primary,
  secondary,
  rewarded,
  iconOnly,
}

class NeoButton extends StatefulWidget {
  final String? text;
  final String? subtext;
  final NeoIconType? icon;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final double? width;
  final double height;
  final bool isLoading;

  const NeoButton({
    super.key,
    this.text,
    this.subtext,
    this.icon,
    required this.onPressed,
    this.variant = NeoButtonVariant.primary,
    this.width,
    this.height = 54,
    this.isLoading = false,
  });

  const NeoButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = NeoButtonVariant.iconOnly,
    this.height = 48,
    this.width = 48,
  })  : text = null,
        subtext = null,
        isLoading = false;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onPressed != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: _buildDecoration(isEnabled),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isEnabled) {
    if (!isEnabled) {
      return BoxDecoration(
        color: AppColors.surfaceCardElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      );
    }

    switch (widget.variant) {
      case NeoButtonVariant.primary:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandPrimary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case NeoButtonVariant.rewarded:
        return BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGold.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case NeoButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        );

      case NeoButtonVariant.iconOnly:
        return BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        );
    }
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
        ),
      );
    }

    if (widget.variant == NeoButtonVariant.iconOnly && widget.icon != null) {
      return Center(
        child: NeoIcon(type: widget.icon!, size: widget.height * 0.45, color: AppColors.textPrimary),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          NeoIcon(type: widget.icon!, size: 20, color: Colors.white),
          const SizedBox(width: 10),
        ],
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.text != null)
              Text(
                widget.text!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            if (widget.subtext != null)
              Text(
                widget.subtext!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
