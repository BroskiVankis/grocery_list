import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool agreeToTerms = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

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
                                const _InputField(
                                  icon: Icons.person_outline,
                                  hintText: 'Username',
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 14),
                                const _InputField(
                                  icon: Icons.mail_outline,
                                  hintText: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),
                                _PasswordField(
                                  icon: Icons.lock_outline,
                                  hintText: 'Password',
                                  obscureText: obscurePassword,
                                  onToggle: () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _PasswordField(
                                  icon: Icons.lock_outline,
                                  hintText: 'Confirm password',
                                  obscureText: obscureConfirm,
                                  onToggle: () => setState(
                                    () => obscureConfirm = !obscureConfirm,
                                  ),
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
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: agreeToTerms
                                        ? () {
                                            // TODO: create account logic
                                          }
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
