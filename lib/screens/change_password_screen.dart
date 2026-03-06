import 'package:flutter/material.dart';
import 'package:grocery_list/theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const String _mockCurrentPassword = 'Password123';

  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isUpdating = false;
  bool _showCurrentPasswordError = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _currentPasswordController.addListener(_onChanged);
    _newPasswordController.addListener(_onChanged);
    _confirmPasswordController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onChanged);
    _newPasswordController.removeListener(_onChanged);
    _confirmPasswordController.removeListener(_onChanged);

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_showCurrentPasswordError) {
      _showCurrentPasswordError = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(_newPasswordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newPasswordController.text);
  bool get _passwordsMatch =>
      _newPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  bool get _allRulesPassed =>
      _hasMinLength && _hasUppercase && _hasNumber && _passwordsMatch;

  bool get _canUpdate =>
      !_isUpdating &&
      _currentPasswordController.text.isNotEmpty &&
      _newPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty &&
      _allRulesPassed;

  Future<void> _handleUpdatePassword() async {
    if (!_canUpdate) return;

    setState(() {
      _isUpdating = true;
      _showCurrentPasswordError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final isCurrentPasswordValid =
        _currentPasswordController.text == _mockCurrentPassword;

    if (!isCurrentPasswordValid) {
      setState(() {
        _isUpdating = false;
        _showCurrentPasswordError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is incorrect.')),
      );
      return;
    }

    setState(() {
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.inputBg,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 138 + keyboardInset),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Keep your account secure by using a strong password.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.sheetSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  PasswordField(
                    label: 'Current Password',
                    controller: _currentPasswordController,
                    obscureText: !_showCurrentPassword,
                    enabled: !_isUpdating,
                    onToggleVisibility: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                  ),
                  if (_showCurrentPasswordError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 2),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Current password is incorrect.',
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  PasswordField(
                    label: 'New Password',
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    enabled: !_isUpdating,
                    onToggleVisibility: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    label: 'Confirm New Password',
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    enabled: !_isUpdating,
                    onToggleVisibility: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ValidationRuleRow(
                    label: 'Minimum 8 characters',
                    isMet: _hasMinLength,
                  ),
                  const SizedBox(height: 10),
                  ValidationRuleRow(
                    label: 'At least one uppercase letter',
                    isMet: _hasUppercase,
                  ),
                  const SizedBox(height: 10),
                  ValidationRuleRow(
                    label: 'At least one number',
                    isMet: _hasNumber,
                  ),
                  const SizedBox(height: 10),
                  ValidationRuleRow(
                    label: 'New password matches confirmation',
                    isMet: _passwordsMatch,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 8 : 0),
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: PrimaryButton(
              label: _isUpdating ? 'Updating...' : 'Update Password',
              enabled: _canUpdate,
              loading: _isUpdating,
              onPressed: _handleUpdatePassword,
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.enabled,
    required this.onToggleVisibility,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabled;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: false,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        floatingLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.focusGreen,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.focusGreen, width: 0.9),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderSoft),
        ),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggleVisibility : null,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: obscureText ? AppColors.textSecondary : AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class ValidationRuleRow extends StatelessWidget {
  const ValidationRuleRow({
    super.key,
    required this.label,
    required this.isMet,
  });

  final String label;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.focusGreen;
    final inactiveColor = AppColors.textSecondary;
    final activeTextColor = Color.lerp(
      activeColor,
      AppColors.textSecondary,
      0.35,
    )!;
    final inactiveTextColor = Color.lerp(inactiveColor, AppColors.white, 0.08)!;

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            final scale = Tween<double>(begin: 0.94, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            );
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
          child: isMet
              ? Icon(
                  Icons.check_circle,
                  key: const ValueKey('met'),
                  size: 16,
                  color: activeColor,
                )
              : Container(
                  key: const ValueKey('unmet'),
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: inactiveColor,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: isMet ? activeTextColor : inactiveTextColor,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12.5,
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      opacity: enabled ? 1 : 0.86,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: enabled ? AppColors.primary : AppColors.disabledBg,
            foregroundColor: enabled ? AppColors.white : AppColors.disabledFg,
            disabledBackgroundColor: AppColors.disabledBg,
            disabledForegroundColor: AppColors.disabledFg,
            elevation: enabled ? 1 : 0,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: enabled && !loading ? onPressed : null,
          child: loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Updating...'),
                  ],
                )
              : Text(label),
        ),
      ),
    );
  }
}
