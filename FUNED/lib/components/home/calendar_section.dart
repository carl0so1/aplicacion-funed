import 'package:flutter/material.dart';
import 'package:flutter_application_1/AcademicCalendarScreen.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class CalendarSection extends StatelessWidget {
  final String? userType;
  final String? userName;
  
  const CalendarSection({
    Key? key,
    this.userType,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar los valores proporcionados o los valores de AuthService como respaldo
    final String actualUserType = userType ?? AuthService.userType ?? 'estudiante';
    final String actualUserName = userName ?? AuthService.userEmail ?? 'Usuario';
    
    return AcademicCalendarScreen(
      userType: actualUserType,
      userName: actualUserName,
    );
  }
}