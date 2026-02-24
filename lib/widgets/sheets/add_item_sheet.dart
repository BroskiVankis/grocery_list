import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

Future<void> showAddItemSheet({
  required BuildContext context,
  required void Function(String itemName) onAdd,
}) async {
  final controller = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.40),
    builder: (context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;

      void submit() {
        final text = controller.text.trim();
        if (text.isEmpty) return;
        onAdd(text);
        Navigator.of(context).pop();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + bottomInset),
        decoration: BoxDecoration(
          color: AppColors.sheetSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.sheetHandle,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add item',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              cursorColor: AppColors.brandGreen,
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Item name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g. Apples, Tomatoes...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.inputBorderSoft,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.brandGreen,
                    width: 1.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: AppColors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Add'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
