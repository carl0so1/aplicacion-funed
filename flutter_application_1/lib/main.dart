import 'package:flutter/material.dart';

// Importar tus pantallas personalizadas
import 'LoginScreen.dart';
import 'RegisterScreen.dart';
import 'RecoverScreen.dart';
import 'PasswordSentScreen.dart';
import 'ChooseAccountScreen.dart';
import 'NameFormScreen.dart';
import 'WelcomeScreen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUNED Educación',
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
        '/nameForm': (context) => NameFormScreen(),
        '/passwordSent': (context) => PasswordSentScreen(),
      },
    );
  }
}

