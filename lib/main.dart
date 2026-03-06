import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_list/state/units_preference.dart';

import 'screens/landing_page.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS: dark bg -> light content
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final UnitsPreferenceController _unitsPreferenceController;

  @override
  void initState() {
    super.initState();
    _unitsPreferenceController = UnitsPreferenceController();
  }

  @override
  void dispose() {
    _unitsPreferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UnitsPreferenceScope(
      controller: _unitsPreferenceController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Grocery List',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LandingPage(),
          '/app': (_) => const MainShell(),
        },
      ),
    );
  }
}
