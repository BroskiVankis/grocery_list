import 'package:flutter/material.dart';
import 'package:grocery_list/theme/app_colors.dart';

class EditDisplayNameScreen extends StatefulWidget {
  const EditDisplayNameScreen({super.key, required this.initialDisplayName});

  final String initialDisplayName;

  @override
  State<EditDisplayNameScreen> createState() => _EditDisplayNameScreenState();
}

class _EditDisplayNameScreenState extends State<EditDisplayNameScreen> {
  late final TextEditingController _displayNameController;
  late final FocusNode _displayNameFocusNode;
  bool _isSaving = false;

  bool get _canSave {
    final current = _displayNameController.text.trim();
    final initial = widget.initialDisplayName.trim();
    return !_isSaving && current.isNotEmpty && current != initial;
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialDisplayName,
    );
    _displayNameFocusNode = FocusNode();
    _displayNameController.addListener(_onNameChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _displayNameFocusNode.requestFocus();
      _displayNameController.selection = TextSelection.collapsed(
        offset: _displayNameController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_onNameChanged);
    _displayNameController.dispose();
    _displayNameFocusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  Future<void> _save() async {
    if (!_canSave) return;

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    Navigator.of(context).pop(_displayNameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Edit Display Name',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            Text(
              'Display Name',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              focusNode: _displayNameFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
              cursorColor: AppColors.brandGreen,
              decoration: InputDecoration(
                hintText: 'Enter display name',
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.brandGreen.withOpacity(0.8),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: _canSave ? _save : null,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : const Text('Save'),
          ),
        ),
      ),
    );
  }
}
