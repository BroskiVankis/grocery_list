import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.mini = false,
    this.tooltip,
    this.heroTag,
    this.shadowColor = const Color(0x1F000000),
    this.shadowBlur = 20,
    this.shadowOffset = const Offset(0, 6),
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final bool mini;
  final String? tooltip;
  final Object? heroTag;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: FloatingActionButton(
        mini: mini,
        elevation: 0,
        highlightElevation: 0,
        tooltip: tooltip,
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: AppColors.brandGreen,
        foregroundColor: AppColors.white,
        child: Icon(icon),
      ),
    );
  }
}
