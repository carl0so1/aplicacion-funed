import 'package:flutter/material.dart';
import 'dart:async';
import 'services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userType;
  final String userName;
  final String userEmail;

  const EmailVerificationScreen({
    Key? key,
    required this.userType,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _simulateEmailSending();
  }

  void _startResendTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _simulateEmailSending() async {
    setState(() {
      _isLoading = true;
    });

    // Enviar correo de verificación real
    final success = await AuthService.sendVerificationEmail(
      widget.userEmail,
      widget.userType,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo de verificación enviado a ${widget.userEmail}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enviando correo. Intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _verifyEmail() async {
    setState(() {
      _isLoading = true;
    });

    // Verificar correo real
    final token = AuthService.generateVerificationToken(widget.userEmail);
    final success = await AuthService.verifyEmail(widget.userEmail, token);

    if (mounted) {
      setState(() {
        _isVerified = success;
        _isLoading = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Correo verificado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar a la pantalla de login después de la verificación
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(
            context,
            '/',
            arguments: widget.userType,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verificando correo. Intenta de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resendEmail() {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _canResend = false;
      _resendTimer = 60;
    });

    _simulateEmailSending();
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de verificación
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),

                // Título
                Text(
                  'Verifica tu correo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15),

                // Mensaje explicativo
                Text(
                  'Hemos enviado un enlace de verificación a:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),

                // Correo del usuario
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2B1A7F),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Instrucciones
                Text(
                  'Por favor, revisa tu bandeja de entrada y haz clic en el enlace de verificación para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 30),

                // Botón de verificación
                if (!_isVerified)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Ya verifiqué mi correo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                SizedBox(height: 20),

                // Botón de reenvío
                if (!_isVerified)
                  TextButton(
                    onPressed: _canResend && !_isLoading ? _resendEmail : null,
                    child: Text(
                      _canResend
                          ? 'Reenviar correo'
                          : 'Reenviar en $_resendTimer segundos',
                      style: TextStyle(
                        color: _canResend ? Colors.lightBlueAccent : Colors.grey,
                      ),
                    ),
                  ),
                SizedBox(height: 20),

                // Opción de cambiar correo
                if (!_isVerified)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cambiar correo electrónico',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),

                // Mensaje de verificación exitosa
                if (_isVerified)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '¡Correo verificado exitosamente!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Redirigiendo al inicio de sesión...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 