import 'dart:convert';

class AuthService {
  // Simulación de base de datos local
  static final Map<String, Map<String, dynamic>> _users = {};
  
  static Future<bool> registerUser({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      // Simular registro exitoso
      _users[email] = {
        'email': email,
        'password': password, // En una app real, esto estaría hasheado
        'userType': userType,
        'emailVerified': false,
      };
      
      // Simular envío de correo de verificación
      await sendVerificationEmail(email, userType);
      
      return true;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }
  
  static Future<bool> sendVerificationEmail(String email, String userType) async {
    try {
      // Simular envío de correo
      print('Simulando envío de correo de verificación a: $email');
      await Future.delayed(Duration(seconds: 1)); // Simular delay de red
      return true;
    } catch (e) {
      print('Error enviando correo: $e');
      return false;
    }
  }
  
  static String generateVerificationToken(String email) {
    // Simular generación de token
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final token = base64Encode(utf8.encode('$email:$timestamp'));
    return token;
  }
  
  static Future<bool> verifyEmail(String email, String token) async {
    try {
      // Simular verificación de email
      if (_users.containsKey(email)) {
        _users[email]!['emailVerified'] = true;
        return true;
      }
      return false;
    } catch (e) {
      print('Error verificando email: $e');
      return false;
    }
  }
  
  static Future<bool> loginUser({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      // Verificar si el usuario existe y está verificado
      if (_users.containsKey(email)) {
        final user = _users[email]!;
        if (user['password'] == password && 
            user['userType'] == userType && 
            user['emailVerified'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }
  
  static Future<bool> isUserLoggedIn() async {
    // Simular verificación de sesión
    return false;
  }
  
  static Future<void> logout() async {
    try {
      // Simular logout
      print('Usuario desconectado');
    } catch (e) {
      print('Error en logout: $e');
    }
  }
  
  static Future<Map<String, String?>> getUserInfo() async {
    try {
      // Simular obtención de información del usuario
      return {
        'email': null,
        'userType': null,
      };
    } catch (e) {
      return {'email': null, 'userType': null};
    }
  }
} 