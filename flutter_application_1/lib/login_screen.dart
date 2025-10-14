import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
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
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Text('Iniciando sesión...'),
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
      // Tomar el rol real EXCLUSIVAMENTE desde el backend
      final backendRole = (AuthService.userType ?? '').toLowerCase();
      final selectedRole = role.toLowerCase();

      // Si el backend no devolvió rol, no permitir avanzar
      if (backendRole.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo determinar tu rol desde el backend. Intenta nuevamente.'),
            backgroundColor: Colors.orange,
          ),
        );
        await AuthService.logout();
        Navigator.pushReplacementNamed(context, '/chooseAccount');
        return;
      }

      // Enforzar: si no coincide, NO permitir avanzar a Home
      if (backendRole != selectedRole) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tu cuenta es "$backendRole". Por favor ingresa desde la opción correspondiente.'),
            backgroundColor: Colors.orange,
          ),
        );
        // Limpiar sesión para evitar entrar con rol incorrecto
        await AuthService.logout();
        // Redirigir a selección de cuenta
        Navigator.pushReplacementNamed(context, '/chooseAccount');
        return;
      }

      final userLabel = backendRole == 'docente' ? 'docente' : 'estudiante';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido $userLabel, $email!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a la pantalla principal usando el rol validado
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'userType': backendRole,
          'userName': email.contains('@') ? email.split('@')[0] : email,
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
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String userRole = (args is String && (args == 'docente' || args == 'estudiante')) ? args : '';

    // Si no hay rol válido, redirigir a la selección de cuenta
    if (userRole.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/chooseAccount');
      });
      return Scaffold(
        backgroundColor: const Color(0xFF2B1A7F),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Texto bonito para mostrar en pantalla (solo Docente/Estudiante)
    final String roleLabel = userRole == 'docente' ? 'Docente' : 'Estudiante';

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
                  style: const TextStyle(color: Colors.blue),
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: const TextStyle(color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Campo contraseña ----------
                TextField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.blue),
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
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
                      style: const TextStyle(color: Colors.blue),
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
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- Alternativas de login ----------
                const Text(
                  'o continúa con',
                  style: const TextStyle(color: Colors.blue),
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

                // ---------- Información de registro ----------
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Text(
                    '¿No tienes cuenta? Contacta al administrador para obtener acceso.',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                    textAlign: TextAlign.center,
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
