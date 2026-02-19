import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool agreeToTerms = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool _submitted = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  bool _isValidEmail(String email) {
    final e = email.trim();
    // Simple MVP-friendly email check
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(e);
  }

  Future<void> _createAccount() async {
    setState(() => _submitted = true);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (!agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms to continue.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // MVP: one local account per device
    final existingEmail = prefs.getString('local_user_email');
    if (existingEmail != null && existingEmail.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An account already exists on this device. Please sign in.',
          ),
        ),
      );
      return;
    }

    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _hashPassword(password, salt);

    await prefs.setString('local_user_username', username);
    await prefs.setString('local_user_email', email);
    await prefs.setString('local_user_salt', salt);
    await prefs.setString('local_user_hash', hash);
    await prefs.setBool('logged_in', false);

    if (!mounted) return;

    // Go back to Login page (typically the previous screen)
    Navigator.of(context).pop({'email': email});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark, // iOS
      ),
      child: Scaffold(
        backgroundColor: scheme.primary,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          MediaQuery.of(context).padding.top + 18,
                          20,
                          18,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(48),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back_ios_new),
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                const Text(
                                  'Create account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const Spacer(),
                                // keep layout centered
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Start your shared grocery list in under a minute.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                height: 140,
                                child: Lottie.asset(
                                  'assets/lottie/Grocery.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form card
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(34),
                              topRight: Radius.circular(34),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 24,
                                offset: const Offset(0, -10),
                                color: Colors.black.withOpacity(0.10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              18,
                              20,
                              26 + MediaQuery.of(context).padding.bottom,
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _submitted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Your details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _ValidatedInputField(
                                    controller: _usernameCtrl,
                                    icon: Icons.person_outline,
                                    hintText: 'Username',
                                    keyboardType: TextInputType.name,
                                    validator: (v) {
                                      final s = (v ?? '').trim();
                                      if (s.isEmpty)
                                        return 'Username is required';
                                      if (s.length < 3)
                                        return 'Username must be at least 3 characters';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _ValidatedInputField(
                                    controller: _emailCtrl,
                                    icon: Icons.mail_outline,
                                    hintText: 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      final s = (v ?? '').trim();
                                      if (s.isEmpty) return 'Email is required';
                                      if (!_isValidEmail(s))
                                        return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _ValidatedPasswordField(
                                    controller: _passwordCtrl,
                                    icon: Icons.lock_outline,
                                    hintText: 'Password',
                                    obscureText: obscurePassword,
                                    onToggle: () => setState(
                                      () => obscurePassword = !obscurePassword,
                                    ),
                                    validator: (v) {
                                      final s = v ?? '';
                                      if (s.isEmpty)
                                        return 'Password is required';
                                      if (s.length < 8)
                                        return 'Password must be at least 8 characters';
                                      final hasNumber = RegExp(
                                        r'\d',
                                      ).hasMatch(s);
                                      if (!hasNumber)
                                        return 'Password must include a number';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _ValidatedPasswordField(
                                    controller: _confirmCtrl,
                                    icon: Icons.lock_outline,
                                    hintText: 'Confirm password',
                                    obscureText: obscureConfirm,
                                    onToggle: () => setState(
                                      () => obscureConfirm = !obscureConfirm,
                                    ),
                                    validator: (v) {
                                      final s = v ?? '';
                                      if (s.isEmpty)
                                        return 'Please confirm your password';
                                      if (s != _passwordCtrl.text)
                                        return 'Passwords do not match';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: agreeToTerms,
                                        onChanged: (v) => setState(
                                          () => agreeToTerms = v ?? false,
                                        ),
                                      ),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: scheme.onSurface
                                                      .withOpacity(0.8),
                                                ),
                                            children: [
                                              const TextSpan(
                                                text: 'I agree to the ',
                                              ),
                                              TextSpan(
                                                text: 'Terms',
                                                style: TextStyle(
                                                  color: scheme.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: TextStyle(
                                                  color: scheme.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: scheme.primary,
                                        foregroundColor: scheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      onPressed: agreeToTerms
                                          ? _createAccount
                                          : null,
                                      child: const Text('Create account'),
                                    ),
                                  ),

                                  const SizedBox(height: 14),
                                  Text(
                                    'By creating an account you can share lists with family and sync in real time.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurface.withOpacity(
                                            0.65,
                                          ),
                                        ),
                                  ),

                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Already have an account? '),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Sign in'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;

  const _InputField({
    required this.icon,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.icon,
    required this.hintText,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        ),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
    );
  }
}

class _ValidatedInputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ValidatedInputField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
    );
  }
}

class _ValidatedPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _ValidatedPasswordField({
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.obscureText,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        ),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
    );
  }
}
