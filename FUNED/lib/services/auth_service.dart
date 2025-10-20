import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Token de autenticación
  static String? _authToken;
  static String? _userType;
  static String? _userEmail;
  static String? _userId;
  
  static String? get authToken => _authToken;
  static String? get userType => _userType;
  static String? get userEmail => _userEmail;
  static String? get userId => _userId;

  // Normaliza valores de rol del backend a 'docente' o 'estudiante'
  static String? _normalizeRole(String? role) {
    if (role == null) return null;
    final r = role.toString().toLowerCase().trim();
    const teacherSynonyms = [
      'docente', 'profesor', 'maestro', 'teacher', 'instructor'
    ];
    const studentSynonyms = [
      'estudiante', 'alumno', 'aprendiz', 'student'
    ];
    if (teacherSynonyms.contains(r)) return 'docente';
    if (studentSynonyms.contains(r)) return 'estudiante';
    return null;
  }
  
  static Future<bool> registerUser({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      // En esta versión no implementamos el registro a través de la API
      // ya que no se mencionó en los endpoints requeridos
      return false;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }
  
  // Estos métodos ya no son necesarios con la API de Render
  static Future<bool> sendVerificationEmail(String email, String userType) async {
    // No implementado en la API de Render
    return false;
  }
  
  static String generateVerificationToken(String email) {
    // No implementado en la API de Render
    return '';
  }
  
  static Future<bool> verifyEmail(String email, String token) async {
    // No implementado en la API de Render
    return false;
  }
  
  static Future<bool> loginUser({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await ApiService.login(email, password);
      
      if (response['success']) {
        // Guardar el token y datos del usuario usando id_persona correctamente
        final data = response['data'];
        
        // Token
        _authToken = data['token'] ?? data['access_token'] ?? data['accessToken'] ?? data['authToken'];
        
        // Usuario anidado
        final userData = (data is Map) ? (data['user'] ?? {}) : {};
        final personaData = (userData is Map) ? (userData['persona'] ?? {}) : {};

        // Email real del usuario
        _userEmail = (userData is Map ? userData['email']?.toString() : null) ?? email;

        // Tipo de usuario (rol) preferentemente desde backend (normalizado)
        final rawRole = (personaData is Map ? personaData['rol']?.toString() : null)
            ?? (userData is Map ? userData['role']?.toString() : null)
            ?? data['userType']?.toString();
        _userType = _normalizeRole(rawRole) ?? _normalizeRole(userType) ?? userType;

        // IDs capturados del payload
        final String? idPersona =
            (personaData is Map ? (personaData['id_persona']?.toString() ?? personaData['idPersona']?.toString()) : null)
            ?? (userData is Map ? (userData['id_persona']?.toString() ?? userData['idPersona']?.toString()) : null)
            ?? data['id_persona']?.toString()
            ?? data['idPersona']?.toString()
            ?? data['persona_id']?.toString()
            ?? data['personaId']?.toString();

        final String? idGenerico =
            (userData is Map ? (userData['id']?.toString() ?? userData['userId']?.toString()) : null)
            ?? data['id']?.toString()
            ?? data['userId']?.toString();

        // Elegir SIEMPRE id_persona si existe
        _userId = idPersona ?? idGenerico;
        debugPrint('AuthService.loginUser → id_persona: ${idPersona ?? '(no presente)'} | id fallback: ${idGenerico ?? '(no presente)'} | userId usado: ${_userId ?? '(vacío)'}');
        debugPrint('AuthService.loginUser → userType: ${_userType ?? '(no presente)'} | email: ${_userEmail ?? '(no presente)'}');

        // Si no hay userId utilizable, abortar
        if (_userId == null || _userId!.isEmpty) {
          return false;
        }
        
        // Validar que tenemos los datos mínimos necesarios
        if (_authToken == null) {
          print('⚠️ AuthService: No se encontró token en la respuesta');
          return false;
        }
        
        return true;
      } else {
        print('❌ AuthService: Login falló - ${response['message']}');
        return false;
      }
    } catch (e) {
      print('❌ AuthService: Error en login: $e');
      return false;
    }
  }
  
  static Future<bool> isUserLoggedIn() async {
    // Verificar si tenemos un token válido
    return _authToken != null;
  }
  
  static Future<void> logout() async {
    try {
      if (_authToken != null) {
        final response = await ApiService.logout();
        if (response['success']) {
          // Limpiar datos de sesión
          _authToken = null;
          _userType = null;
          _userEmail = null;
          _userId = null;
        }
      }
    } catch (e) {
      print('Error en logout: $e');
    }
  }
  
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      if (_authToken != null) {
        final response = await ApiService.getUserProfile();
        if (response['success']) {
          return response['data'];
        }
      }
      return {
        'email': _userEmail,
        'userType': _userType,
      };
    } catch (e) {
      print('Error obteniendo información del usuario: $e');
      return {'email': _userEmail, 'userType': _userType};
    }
  }
}