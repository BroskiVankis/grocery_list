import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_list/theme/app_colors.dart';

class RecipeImagePicker extends StatefulWidget {
  final File? image;
  final VoidCallback onTap;

  const RecipeImagePicker({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  State<RecipeImagePicker> createState() => _RecipeImagePickerState();
}

class _RecipeImagePickerState extends State<RecipeImagePicker> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bodySmall = theme.textTheme.bodySmall;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _isPressed ? 0.98 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (pressed) {
            if (_isPressed == pressed) return;
            setState(() {
              _isPressed = pressed;
            });
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: colorScheme.primary.withOpacity(0.08),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(0.04),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                        color: AppColors.brandGreen,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add recipe photo',
                        style: bodySmall?.copyWith(
                          fontSize: (bodySmall.fontSize ?? 12) + 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Take photo or choose from library',
                        style: bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(widget.image!, fit: BoxFit.cover),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withOpacity(0.08),
                            ),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: AppColors.brandGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
