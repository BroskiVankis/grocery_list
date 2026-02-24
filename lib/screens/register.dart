import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../widgets/auth/auth_fields.dart';

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
      if (!mounted) return;
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

    // Registration should not auto-login; login screen will authenticate.
    await prefs.setBool('logged_in', false);

    if (!mounted) return;
    Navigator.of(context).pop({'email': email});
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isCompact = h < 900;

    final headerBottomPadding = isCompact ? 8.0 : 16.0;
    final titleToSubtitle = isCompact ? 8.0 : 10.0;
    final subtitleToIllustration = isCompact ? 10.0 : 18.0;
    final illustrationHeight = isCompact ? 128.0 : 168.0;
    final cardTopGap = isCompact ? 8.0 : 12.0;
    final headerTopExtra = isCompact ? 10.0 : 16.0;

    final cardInnerTop = isCompact ? 16.0 : 26.0;
    final fieldHeight = isCompact ? 50.0 : 56.0;
    final fieldGap = isCompact ? 12.0 : 16.0;
    final footerLineHeight = isCompact ? 1.35 : 1.5;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageTop,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              _RegisterHeader(
                titleToSubtitle: titleToSubtitle,
                subtitleToIllustration: subtitleToIllustration,
                illustrationHeight: illustrationHeight,
                headerTopExtra: headerTopExtra,
                headerBottomPadding: headerBottomPadding,
                isCompact: isCompact,
              ),
              SizedBox(height: cardTopGap),

              // Form card
              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 2),
                        blurRadius: 12,
                        color: Color(0x0D000000),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      cardInnerTop,
                      24,
                      6 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Your details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: fieldGap),
                          SizedBox(
                            height: fieldHeight,
                            child: ValidatedInputField(
                              controller: _usernameCtrl,
                              icon: Icons.person_outline,
                              hintText: 'Username',
                              keyboardType: TextInputType.name,
                              validator: (v) {
                                final s = (v ?? '').trim();
                                if (s.isEmpty) return 'Username is required';
                                if (s.length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: fieldGap),
                          SizedBox(
                            height: fieldHeight,
                            child: ValidatedInputField(
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
                          ),
                          SizedBox(height: fieldGap),
                          SizedBox(
                            height: fieldHeight,
                            child: ValidatedPasswordField(
                              controller: _passwordCtrl,
                              icon: Icons.lock_outline,
                              hintText: 'Password',
                              obscureText: obscurePassword,
                              onToggle: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                              validator: (v) {
                                final s = v ?? '';
                                if (s.isEmpty) return 'Password is required';
                                if (s.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                final hasNumber = RegExp(r'\\d').hasMatch(s);
                                if (!hasNumber) {
                                  return 'Password must include a number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: fieldGap),
                          SizedBox(
                            height: fieldHeight,
                            child: ValidatedPasswordField(
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
                                if (s != _passwordCtrl.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: isCompact ? 10 : 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  activeColor: AppColors.brandGreen,
                                  value: agreeToTerms,
                                  onChanged: (v) =>
                                      setState(() => agreeToTerms = v ?? false),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.legalSecondary,
                                          height: 1.25,
                                        ),
                                    children: const [
                                      TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: AppColors.brandGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: AppColors.brandGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                    color: Color(0x0F000000),
                                  ),
                                ],
                              ),
                              child: FilledButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith((
                                        states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.disabled,
                                        )) {
                                          return AppColors.brandGreen
                                              .withOpacity(0.35);
                                        }
                                        if (states.contains(
                                          MaterialState.pressed,
                                        )) {
                                          return AppColors.pressedGreen;
                                        }
                                        return AppColors.brandGreen;
                                      }),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith(
                                        (states) =>
                                            states.contains(
                                              MaterialState.disabled,
                                            )
                                            ? Colors.white.withOpacity(0.75)
                                            : Colors.white,
                                      ),
                                  elevation: MaterialStateProperty.all<double>(
                                    0,
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                        const StadiumBorder(),
                                      ),
                                  padding:
                                      MaterialStateProperty.all<
                                        EdgeInsetsGeometry
                                      >(
                                        const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.fromHeight(48),
                                  ),
                                ),
                                onPressed: agreeToTerms ? _createAccount : null,
                                child: const Text('Create account'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'By creating an account you can share lists with family and sync in real time.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.footerText,
                                  height: footerLineHeight,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              const Text('Already have an account?'),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.brandGreen,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
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
  }
}

class _RegisterHeader extends StatelessWidget {
  final double titleToSubtitle;
  final double subtitleToIllustration;
  final double illustrationHeight;
  final double headerTopExtra;
  final double headerBottomPadding;
  final bool isCompact;

  const _RegisterHeader({
    required this.titleToSubtitle,
    required this.subtitleToIllustration,
    required this.illustrationHeight,
    required this.headerTopExtra,
    required this.headerBottomPadding,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + headerTopExtra,
        24,
        headerBottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sageTop,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.textPrimary,
              ),
              const Spacer(),
              const Text(
                'Create account',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          SizedBox(height: titleToSubtitle),
          const Text(
            'Start your shared grocery list in under a minute.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: subtitleToIllustration),
          Center(
            child: SizedBox(
              height: illustrationHeight,
              child: Transform.translate(
                offset: Offset(0, isCompact ? 6 : 10),
                child: Lottie.asset(
                  'assets/lottie/Grocery.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
