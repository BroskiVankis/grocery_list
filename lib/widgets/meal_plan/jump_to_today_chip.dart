import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class JumpToTodayChip extends StatelessWidget {
  const JumpToTodayChip({
    super.key,
    required this.visible,
    required this.bottom,
    required this.onPressed,
  });

  final bool visible;
  final double bottom;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: bottom,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          offset: visible ? Offset.zero : const Offset(0, 0.08),
          child: IgnorePointer(
            ignoring: !visible,
            child: ActionChip(
              label: const Text('Jump to Today'),
              onPressed: onPressed,
              backgroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.inputBorder),
            ),
          ),
        ),
      ),
    );
  }
}
