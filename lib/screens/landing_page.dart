import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fresh Market theme
    // Slightly warmer / greener than #F2F7F3 (about ~2–3% shift)
    const sageTop = Color(0xFFF0F8F2);
    const whiteBottom = Color(0xFFFFFFFF);

    // Slightly richer button green (more contrast / "alive")
    const brandGreen = Color(0xFF4F7A52);
    const pressedGreen = Color(0xFF446B47);

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
        body: Stack(
          children: [
            // Clean split background (Top 55% sage, bottom 45% white)
            Positioned.fill(
              child: Column(
                children: const [
                  Expanded(flex: 55, child: ColoredBox(color: sageTop)),
                  Expanded(flex: 45, child: ColoredBox(color: whiteBottom)),
                ],
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Grocery shopping\nmade easy',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        height: 1.05,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Create a list, share it with family, and shop together in real time.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textSecondary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            // Mild desaturation (approx 85% saturation)
                            0.91, 0.09, 0.09, 0, 0,
                            0.09, 0.91, 0.09, 0, 0,
                            0.09, 0.09, 0.91, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                          child: Lottie.asset(
                            'assets/lottie/grocery_delivery.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 12,
                            color: Color(
                              0x0F000000,
                            ), // 0 4px 12px rgba(0,0,0,0.06)
                          ),
                        ],
                      ),
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => states.contains(MaterialState.pressed)
                                ? pressedGreen
                                : brandGreen,
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white,
                          ),
                          elevation: MaterialStateProperty.all<double>(0),
                          overlayColor: MaterialStateProperty.all<Color>(
                            const Color(0x14000000),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            const StadiumBorder(),
                          ),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                        ),
                        onPressed: () {
                          // Next: navigate to the login page
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text('Get started'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
