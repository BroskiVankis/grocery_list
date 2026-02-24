import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

Future<void> showAddItemSheet({
  required BuildContext context,
  required void Function(String itemName, int quantity, String unit) onAdd,
}) async {
  final controller = TextEditingController();
  int quantity = 1;
  const units = ['kg', 'pcs', 'g', 'L', 'ml'];
  String selectedUnit = 'pcs';

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
        onAdd(text, quantity, selectedUnit);
        Navigator.of(context).pop();
      }

      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: EdgeInsets.fromLTRB(16, 12, 16, 30 + bottomInset),
            decoration: BoxDecoration(
              color: AppColors.sheetSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.sheetHandle.withOpacity(0.60),
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
                Text(
                  'Item name',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  cursorColor: AppColors.brandGreen,
                  onSubmitted: (_) => submit(),
                  decoration: InputDecoration(
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
                const SizedBox(height: 20),
                Text(
                  'Quantity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorderSoft),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Opacity(
                          opacity: quantity > 1 ? 1 : 0.4,
                          child: IconButton(
                            onPressed: quantity > 1
                                ? () => setSheetState(() => quantity -= 1)
                                : null,
                            icon: const Icon(Icons.remove),
                            color: quantity > 1
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.inputBorderSoft.withOpacity(0.85),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$quantity',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.inputBorderSoft.withOpacity(0.85),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: () => setSheetState(() => quantity += 1),
                          icon: const Icon(Icons.add),
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Unit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(
                      context,
                    ).colorScheme.copyWith(primary: AppColors.brandGreen),
                    canvasColor: AppColors.sheetSurface,
                    splashColor: AppColors.brandGreen.withOpacity(0.10),
                    highlightColor: AppColors.brandGreen.withOpacity(0.08),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedUnit,
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: AppColors.sheetSurface,
                    iconEnabledColor: AppColors.textSecondary,
                    isExpanded: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.inputBorderSoft.withOpacity(0.60),
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
                    items: units
                        .map(
                          (unit) => DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() => selectedUnit = value);
                    },
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
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}
