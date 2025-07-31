import 'package:flutter/material.dart';

// Importar tus pantallas personalizadas
import 'LoginScreen.dart';
import 'RegisterScreen.dart';
import 'RecoverScreen.dart';
import 'PasswordSentScreen.dart';
import 'ChooseAccountScreen.dart';
import 'NameFormScreen.dart';
import 'WelcomeScreen.dart';
import 'HomeScreen.dart';
import 'EmailVerificationScreen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUNED Academia de Belleza',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2B1A7F), // Color azul oscuro
      ),
      initialRoute: '/welcome',
      routes: {
        '/': (context) => LoginScreen(), //
        '/welcome': (context) => WelcomeScreen(),
        '/register': (context) => RegisterScreen(),
        '/recover': (context) => RecoverScreen(),
        '/chooseAccount': (context) => ChooseAccountScreen(),

        '/emailVerification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
          return EmailVerificationScreen(
            userType: args?['userType'] ?? 'estudiante',
            userName: args?['userName'] ?? 'Usuario',
            userEmail: args?['userEmail'] ?? 'usuario@ejemplo.com',
          );
        },
        '/passwordSent': (context) => PasswordSentScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
          return HomeScreen(
            userType: args?['userType'] ?? 'estudiante',
            userName: args?['userName'] ?? 'Usuario',
          );
        },
      },
    );
  }
}

