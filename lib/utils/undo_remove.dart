import 'package:flutter/material.dart';

class UndoRemove<T> {
  T? lastRemoved;
  int? lastRemovedIndex;
  int _snackToken = 0;

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

    final token = ++_snackToken;
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Text('Removed "$label"'),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () {
          // Close the snackbar immediately when undo is tapped.
          messenger.hideCurrentSnackBar();

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
    );

    messenger.showSnackBar(snackBar);

    // Some platforms/themes can leave snackbars visible until the next frame.
    // Force-dismiss after the duration, but only if this is still the latest snack.
    Future.delayed(snackBar.duration, () {
      if (token != _snackToken) return;
      messenger.hideCurrentSnackBar();
    });
  }
}
