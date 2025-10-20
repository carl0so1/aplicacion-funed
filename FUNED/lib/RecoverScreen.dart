import 'package:flutter/material.dart';

class RecoverScreen extends StatefulWidget {
  @override
  _RecoverScreenState createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();

 void _sendRecovery() {
  if (_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enlace de recuperación enviado')),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushNamed(context, '/passwordSent');
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.lock_reset, size: 100, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Recupera tu cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _inputController,
                    style: TextStyle(color: Colors.blue),
                    decoration: InputDecoration(
                      labelText: 'Correo o número de celular',
                      labelStyle: TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _sendRecovery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      'Enviar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Vuelve al login
                    },
                    child: Text(
                      'Volver al inicio',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
