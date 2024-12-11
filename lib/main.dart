import 'package:flutter/material.dart';
import 'screens/registration_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const RegistrationFormScreen(),
    );
  }
}

extension ResponsiveExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double responsiveSize(double size) => screenHeight * (size / 1000);
  TextStyle? get textSmall => Theme.of(this).textTheme.titleSmall;
  TextStyle? get textMedium => Theme.of(this).textTheme.titleMedium;
  TextStyle? get textLarge => Theme.of(this).textTheme.titleLarge;
  TextTheme get textTheme => Theme.of(this).textTheme;
}