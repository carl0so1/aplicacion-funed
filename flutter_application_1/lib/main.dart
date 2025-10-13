import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importar tus pantallas personalizadas
import 'LoginScreen.dart';
import 'RecoverScreen.dart';
import 'PasswordSentScreen.dart';
import 'ChooseAccountScreen.dart';

import 'WelcomeScreen.dart';
import 'HomeScreen.dart';
import 'EmailVerificationScreen.dart';
import 'AcademicCalendarScreen.dart';
import 'CourseDetailScreen.dart';
import 'GradesScreen.dart';
import 'AttendanceScreen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar datos de localización para español
  await initializeDateFormatting('es_ES', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FUNED Academia de Belleza',
      debugShowCheckedModeBanner: false, // Quitar etiqueta DEBUG
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2B1A7F), // Color azul oscuro
      ),
      // Configuración de localización en español
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (fallback)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Configuración adicional para asegurar que se use español
      localeResolutionCallback: (locale, supportedLocales) {
        // Forzar el uso de español
        return const Locale('es', 'ES');
      },
      // Usar home directamente para evitar conflictos con initialRoute
      home: WelcomeScreen(),
      routes: {
        // Nota: No definir la ruta "/" cuando se usa `home` para evitar la aserción de duplicidad
        '/login': (context) => LoginScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/recover': (context) => RecoverScreen(),
        '/chooseAccount': (context) => ChooseAccountScreen(),
        '/academicCalendar': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
          return AcademicCalendarScreen(
            userType: args?['userType'] ?? 'estudiante',
            userName: args?['userName'] ?? 'Usuario',
          );
        },
        '/courseDetail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return CourseDetailScreen(
            courseInfo: args?['courseInfo'] ?? {},
            userType: args?['userType'] ?? 'estudiante',
          );
        },
        '/grades': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
          return GradesScreen(
            userType: args?['userType'] ?? 'estudiante',
            userName: args?['userName'] ?? 'Usuario',
          );
        },
        '/attendance': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
          return AttendanceScreen(
            userType: args?['userType'] ?? 'estudiante',
            userName: args?['userName'] ?? 'Usuario',
          );
        },

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

