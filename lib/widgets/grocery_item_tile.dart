import 'package:flutter/material.dart';
import '../utils/item_emoji.dart';

class GroceryItemTile extends StatelessWidget {
  const GroceryItemTile({
    super.key,
    required this.name,
    required this.onTapRemove,
  });

  final String name;
  final VoidCallback onTapRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTapRemove,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
          ),
          child: ListTile(
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            trailing: Text(
              emojiForItem(name),
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}
