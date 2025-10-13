import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 👈 Importante
import 'Screen/inicio_screen.dart';
import 'Screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NICOLE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      // 👇 Esto le da soporte al calendario (date picker) y otros widgets con idiomas
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés
      ],
      home: const SplashScreen(),
    );
  }
}
