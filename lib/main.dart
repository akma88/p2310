import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart';
import 'logger_riverpod.dart';

void main() {
  runApp(
    ProviderScope(observers: [LoggerRiverpod()], child: const PeoplePulseApp()),
  );
}

class PeoplePulseApp extends StatelessWidget {
  const PeoplePulseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'People Pulse',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6554D9)),
      scaffoldBackgroundColor: const Color(0xFFF7F7FC),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    home: const HomePage(),
  );
}
