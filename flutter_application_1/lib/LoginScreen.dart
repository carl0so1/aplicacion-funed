import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  // Controladores para los campos de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Método de autenticación real
  void _login(BuildContext context, String role) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa correo y contraseña')),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Iniciando sesión...'),
            ],
          ),
        );
      },
    );

    // Intentar login con autenticación real
    final success = await AuthService.loginUser(
      email: email,
      password: password,
      userType: role,
    );

    // Cerrar loading
    Navigator.of(context).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido ${role == 'docente' ? 'docente' : 'estudiante'}, $email!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a la pantalla principal
      Navigator.pushReplacementNamed(
        context, 
        '/home',
        arguments: {
          'userType': role,
          'userName': email.split('@')[0],
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Credenciales incorrectas o correo no verificado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recuperar el argumento enviado desde ChooseAccountScreen
    final String userRole =
        ModalRoute.of(context)!.settings.arguments as String? ?? 'desconocido';

    // Texto bonito para mostrar en pantalla
    String roleLabel =
        userRole == 'docente' ? 'Docente' : userRole == 'estudiante' ? 'Estudiante' : 'Invitado';

    return Scaffold(
      backgroundColor: const Color(0xFF2B1A7F), // Azul oscuro
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------- Título dinámico ----------
                Text(
                  'Iniciar sesión - $roleLabel',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // ---------- Campo correo ----------
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Campo contraseña ----------
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                
                // ---------- Enlace olvidé contraseña ----------
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/recover');
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Botón de iniciar ----------
                ElevatedButton(
                  onPressed: () => _login(context, userRole),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 20),

                // ---------- Alternativas de login ----------
                const Text(
                  'o continúa con',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.facebook,
                          size: 32, color: Colors.white),
                      onPressed: () {
                        // Login con Facebook
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.g_mobiledata,
                          size: 36, color: Colors.white),
                      onPressed: () {
                        // Login con Google
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---------- Ir a registro ----------
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.lightBlueAccent),
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
