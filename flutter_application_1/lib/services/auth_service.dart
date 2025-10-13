import 'package:flutter_application_1/services/api_service.dart';

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
      print('🚀 AuthService: Iniciando login para $email como $userType');
      final response = await ApiService.login(email, password);
      
      print('📋 AuthService: Respuesta del login: $response');
      
      if (response['success']) {
        // Guardar el token de autenticación
        final data = response['data'];
        print('📊 AuthService: Data recibida: $data');
        print('📊 AuthService: Estructura completa de data: ${data.runtimeType}');
        print('📊 AuthService: Keys disponibles en data: ${data.keys}');
        
        // Log detallado de cada campo posible para userId
        print('🔍 AuthService: Buscando userId en los siguientes campos:');
        print('  - data["userId"]: ${data['userId']}');
        print('  - data["id"]: ${data['id']}');
        print('  - data["user_id"]: ${data['user_id']}');
        print('  - data["idPersona"]: ${data['idPersona']}');
        print('  - data["persona_id"]: ${data['persona_id']}');
        print('  - data["personaId"]: ${data['personaId']}');
        
        // Extraer token - puede estar en diferentes campos
        _authToken = data['token'] ?? data['access_token'] ?? data['accessToken'] ?? data['authToken'];
        
        // Extraer userType - puede estar en diferentes campos
        _userType = data['userType'] ?? data['role'] ?? data['user_type'] ?? data['type'] ?? userType;
        
        // Extraer userId - puede estar en diferentes campos
        _userId = data['userId']?.toString() ?? data['id']?.toString() ?? data['user_id']?.toString() ?? data['idPersona']?.toString();
        
        // Si data contiene un objeto user anidado, buscar ahí también
        if (data['user'] != null) {
          final userData = data['user'];
          print('📊 AuthService: Datos de usuario anidados: $userData');
          _userType = _userType ?? userData['userType'] ?? userData['role'] ?? userData['user_type'] ?? userData['type'];
          _authToken = _authToken ?? userData['token'] ?? userData['access_token'];
          _userId = _userId ?? userData['userId']?.toString() ?? userData['id']?.toString() ?? userData['user_id']?.toString() ?? userData['idPersona']?.toString() ?? userData['id_persona']?.toString();
          
          // Extraer el rol del objeto persona anidado
          if (userData['persona'] != null) {
            final personaData = userData['persona'];
            print('👤 AuthService: Datos de persona: $personaData');
            _userType = _userType ?? personaData['rol'];
          }
        }
        
        _userEmail = email;
        
        print('✅ AuthService: Token guardado: $_authToken');
        print('✅ AuthService: UserType guardado: $_userType');
        print('✅ AuthService: Email guardado: $_userEmail');
        print('✅ AuthService: UserId guardado: $_userId');
        
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