import 'package:flutter/material.dart';

class UndoRemove<T> {
  T? lastRemoved;
  int? lastRemovedIndex;

  void removeWithUndo({
    required BuildContext context,
    required List<T> list,
    required int index,
    required String label,
    required VoidCallback onChanged,
  }) {
    final removed = list[index];

    lastRemoved = removed;
    lastRemovedIndex = index;
    list.removeAt(index);
    onChanged();

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text('Removed "$label"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            final item = lastRemoved;
            final at = lastRemovedIndex;
            if (item == null || at == null) return;

            final insertAt = at.clamp(0, list.length);
            list.insert(insertAt, item);
            lastRemoved = null;
            lastRemovedIndex = null;
            onChanged();
          },
        ),
      ),
    );
  }
}
