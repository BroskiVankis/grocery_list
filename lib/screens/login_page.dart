import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool rememberMe = false;
  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final e = email.trim();
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(e);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    return sha256.convert(bytes).toString();
  }

  Future<void> _login() async {
    setState(() => _submitted = true);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('local_user_email');
    final storedSalt = prefs.getString('local_user_salt');
    final storedHash = prefs.getString('local_user_hash');

    if (storedEmail == null || storedSalt == null || storedHash == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No account found. Please create one.')),
      );
      return;
    }

    if (storedEmail.toLowerCase() != email) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email not found.')));
      return;
    }

    final inputHash = _hashPassword(password, storedSalt);
    if (inputHash != storedHash) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Wrong password.')));
      return;
    }

    // Mark session as logged in (for later MVP routing if you want)
    await prefs.setBool('logged_in', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/app');
  }

  Future<void> _openRegister() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));

    if (result is Map && result['email'] != null) {
      _emailCtrl.text = (result['email'] as String).trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fresh Market palette
    const sageTop = Color(0xFFF2F7F3);
    const white = Color(0xFFFFFFFF);

    // Brand
    const brandGreen = Color(0xFF5E8C61);
    const pressedGreen = Color(0xFF4F7A52);

    // Neutrals
    const socialBorder = Color(0xFFE3E8E5); // per spec for social buttons
    const inputBorder = Color(0xFFE7ECE9); // slightly lighter than before
    const dividerColor = Color(0xFFEEF2EF); // lighter than input borders

    const textPrimary = Color(0xFF1F2A24);
    const textSecondary = Color(0xFF6B7C73);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: sageTop,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top header area (similar vibe to your reference)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          24,
                          MediaQuery.of(context).padding.top + 24,
                          24,
                          32,
                        ),
                        decoration: const BoxDecoration(
                          color: sageTop,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Center(
                              child: Column(
                                children: const [
                                  SizedBox(height: 6),
                                  Text(
                                    'Grocery Store',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Everything you need, in one place',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: SizedBox(
                                height: 180,
                                child: Lottie.asset(
                                  'assets/lottie/Grocery.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Form card (fills to bottom; includes safe-area padding)
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, -6),
                                blurRadius: 18,
                                color: Color(0x0A000000), // rgba(0,0,0,0.04)
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              24,
                              24,
                              24 + MediaQuery.of(context).padding.bottom,
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _submitted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                children: [
                                  const SizedBox(height: 6),
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
                                  const SizedBox(height: 16),
                                  _ValidatedPasswordField(
                                    controller: _passwordCtrl,
                                    icon: Icons.lock_outline,
                                    hintText: 'Password',
                                    obscureText: _obscurePassword,
                                    onToggle: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    validator: (v) {
                                      final s = v ?? '';
                                      if (s.isEmpty)
                                        return 'Password is required';
                                      if (s.length < 8)
                                        return 'Password must be at least 8 characters';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Checkbox(
                                        activeColor: brandGreen,
                                        value: rememberMe,
                                        onChanged: (v) => setState(
                                          () => rememberMe = v ?? false,
                                        ),
                                      ),
                                      const Text('Remember me'),
                                      const Spacer(),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: brandGreen,
                                        ),
                                        onPressed: () {},
                                        child: const Text('Forgot Password?'),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            offset: Offset(0, 4),
                                            blurRadius: 12,
                                            color: Color(
                                              0x0F000000,
                                            ), // rgba(0,0,0,0.06)
                                          ),
                                        ],
                                      ),
                                      child: FilledButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.resolveWith(
                                                (states) =>
                                                    states.contains(
                                                      MaterialState.pressed,
                                                    )
                                                    ? pressedGreen
                                                    : brandGreen,
                                              ),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                Colors.white,
                                              ),
                                          elevation:
                                              MaterialStateProperty.all<double>(
                                                0,
                                              ),
                                          shape:
                                              MaterialStateProperty.all<
                                                OutlinedBorder
                                              >(const StadiumBorder()),
                                          padding:
                                              MaterialStateProperty.all<
                                                EdgeInsetsGeometry
                                              >(
                                                const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                ),
                                              ),
                                        ),
                                        onPressed: _login,
                                        child: const Text('Sign in'),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(color: dividerColor),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: const TextStyle(
                                            color: textSecondary,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(color: dividerColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: white,
                                            foregroundColor: textPrimary,
                                            side: const BorderSide(
                                              color: socialBorder,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          onPressed: () {},
                                          icon: const FaIcon(
                                            FontAwesomeIcons.facebookF,
                                            size: 18,
                                            color: Color(0xFF1877F2),
                                          ),
                                          label: const Text('Facebook'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: white,
                                            foregroundColor: textPrimary,
                                            side: const BorderSide(
                                              color: socialBorder,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          onPressed: () {},
                                          icon: ShaderMask(
                                            shaderCallback: (rect) {
                                              return const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF4285F4),
                                                  Color(0xFF34A853),
                                                  Color(0xFFFBBC05),
                                                  Color(0xFFEA4335),
                                                ],
                                                stops: [0.0, 0.33, 0.66, 1.0],
                                              ).createShader(rect);
                                            },
                                            child: const FaIcon(
                                              FontAwesomeIcons.google,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          label: const Text('Google'),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Don't have an account? "),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: brandGreen,
                                        ),
                                        onPressed: _openRegister,
                                        child: const Text('Register Now'),
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
  final bool obscureText;
  final TextInputType? keyboardType;

  const _InputField({
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    const brandGreen = Color(0xFF5E8C61);
    const border = Color(0xFFE7ECE9);

    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: brandGreen, width: 1.6),
        ),
      ),
    );
  }
}

class _ValidatedInputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ValidatedInputField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    const brandGreen = Color(0xFF5E8C61);
    const border = Color(0xFFE7ECE9);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: brandGreen, width: 1.6),
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
    const white = Color(0xFFFFFFFF);
    const brandGreen = Color(0xFF5E8C61);
    const border = Color(0xFFE7ECE9);

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
        fillColor: white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: brandGreen, width: 1.6),
        ),
      ),
    );
  }
}
