import 'package:flutter/material.dart';
import 'package:coma_bem/views/00_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ComaBemApp());
}

class ComaBemApp extends StatelessWidget {
  const ComaBemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coma Bem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E6B34),
          primary: const Color(0xFF2E6B34),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
