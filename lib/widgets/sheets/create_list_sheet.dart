import 'package:flutter/material.dart';

class CreateListSheet extends StatefulWidget {
  const CreateListSheet({super.key, required this.onCreate});

  final ValueChanged<String> onCreate;

  @override
  State<CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<CreateListSheet> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onCreate(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create a new list',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'List name',
              hintText: 'e.g. Weekly groceries',
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
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Create'),
            ),
          ),
        ],
      ),
    );
  }
}
