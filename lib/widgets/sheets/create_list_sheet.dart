import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CreateListSheet extends StatefulWidget {
  const CreateListSheet({super.key, required this.onCreate});

  final ValueChanged<String> onCreate;

  @override
  State<CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<CreateListSheet> {
  final controller = TextEditingController();
  final _nameFocus = FocusNode();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
    _nameFocus.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    final canSubmitNow = controller.text.trim().isNotEmpty;
    if (canSubmitNow != _canSubmit) {
      setState(() {
        _canSubmit = canSubmitNow;
      });
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _nameFocus.removeListener(_onFocusChanged);
    controller.removeListener(_onTextChanged);
    _nameFocus.dispose();
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    widget.onCreate(name);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 20),
            child: child,
          ),
        );
      },
      child: Container(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.brandGreen.withOpacity(0.22),
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    color: AppColors.brandGreen.withOpacity(0.92),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a new list',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a shared shopping list',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.done,
              cursorColor: AppColors.focusGreen,
              decoration: InputDecoration(
                labelText: 'List name *',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g. Weekly groceries',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: _nameFocus.hasFocus
                    ? AppColors.white
                    : AppColors.inputBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.inputBorderSoft,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.focusGreen,
                    width: 1.8,
                  ),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.disabledBg,
                disabledForegroundColor: AppColors.disabledFg,
                elevation: 3,
                shadowColor: AppColors.brandGreen.withOpacity(0.08),
                shape: const StadiumBorder(),
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _canSubmit ? _submit : null,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
