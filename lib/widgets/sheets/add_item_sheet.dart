import 'package:flutter/material.dart';

Future<void> showAddItemSheet({
  required BuildContext context,
  required void Function(String itemName) onAdd,
}) async {
  final controller = TextEditingController();
  final scheme = Theme.of(context).colorScheme;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;

      void submit() {
        final text = controller.text.trim();
        if (text.isEmpty) return;
        onAdd(text);
        Navigator.of(context).pop();
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add item',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Item name',
                hintText: 'e.g. Apples, Tomatoes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: scheme.primary, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
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
