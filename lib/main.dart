import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:livreur_infflux/screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livreur Infflux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF607D8B),
          primary: const Color(0xFF546E7A),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFCFD8DC),
          onPrimaryContainer: const Color(0xFF37474F),
          secondary: const Color(0xFF78909C),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFECEFF1),
          onSecondaryContainer: const Color(0xFF455A64),
          tertiary: const Color(0xFF90A4AE),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFE0E0E0),
          onTertiaryContainer: const Color(0xFF424242),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
