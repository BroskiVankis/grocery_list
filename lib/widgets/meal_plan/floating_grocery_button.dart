import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class FloatingGroceryButton extends StatelessWidget {
  const FloatingGroceryButton({
    super.key,
    required this.visible,
    required this.bottomPadding,
    required this.onPressed,
  });

  final bool visible;
  final double bottomPadding;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 18),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          offset: visible ? Offset.zero : const Offset(0, 0.06),
          child: IgnorePointer(
            ignoring: !visible,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text(
                  'Generate Grocery List',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
