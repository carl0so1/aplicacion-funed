import 'package:flutter/material.dart';

class LogoutDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: Color(0xFF2B1A7F),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}