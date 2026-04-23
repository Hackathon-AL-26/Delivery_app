import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livreur_infflux/services/auth_service.dart';
import 'package:livreur_infflux/screens/auth/login_screen.dart';
import 'package:livreur_infflux/screens/home_screen.dart';

/// Widget qui écoute l'état d'authentification Firebase
/// et affiche soit le LoginScreen soit le HomeScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Utilisateur connecté → écran principal
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Pas connecté → login
        return const LoginScreen();
      },
    );
  }
}
