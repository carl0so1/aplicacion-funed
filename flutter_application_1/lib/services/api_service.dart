import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://proyecto-funed-backend.onrender.com';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Autenticación
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔐 Intentando login con email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Login response status: ${response.statusCode}');
      print('📡 Login response body: ${response.body}');
      
      final result = _processResponse(response);
      print('🔍 Processed login result: $result');
      
      return result;
    } catch (e) {
      print('❌ Error en login: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = AuthService.authToken;
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Cursos
  static Future<Map<String, dynamic>> getCoursesByStudent() async {
    try {
      final token = AuthService.authToken;
      print('🎓 Obteniendo cursos para estudiante');
      print('🔑 Token: ${token?.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/cursos'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      print('📡 getCoursesByStudent status: ${response.statusCode}');
      print('📡 getCoursesByStudent body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      print('❌ Error en getCoursesByStudent: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Nuevo método para obtener cursos por ID de persona
  static Future<Map<String, dynamic>> getCoursesByPersonId(String personId) async {
    try {
      final token = AuthService.authToken;
      print('🎓 Obteniendo cursos para persona ID: $personId');
      print('🔑 Token: ${token?.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/cursosPersonas/$personId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      print('📡 getCoursesByPersonId status: ${response.statusCode}');
      print('📡 getCoursesByPersonId body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      print('❌ Error en getCoursesByPersonId: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCoursesByTeacher() async {
    try {
      final token = AuthService.authToken;
      print('👨‍🏫 Obteniendo cursos para docente');
      print('🔑 Token: ${token?.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/cursos/docente'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      print('📡 getCoursesByTeacher status: ${response.statusCode}');
      print('📡 getCoursesByTeacher body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      print('❌ Error en getCoursesByTeacher: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCourseDetailForStudent(String courseId) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/cursos/estudiante/$courseId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
  
  // Método general para obtener detalles de un curso
  static Future<Map<String, dynamic>> getCourseDetails(String courseId) async {
    if (AuthService.authToken == null) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }
    
    final userType = AuthService.userType;
    if (userType == null) {
      return {'success': false, 'message': 'Tipo de usuario no disponible'};
    }
    
    try {
      if (userType == 'estudiante') {
        return await getCourseDetailForStudent(courseId);
      } else if (userType == 'docente') {
        return await getCourseDetailForTeacher(courseId);
      } else {
        return {'success': false, 'message': 'Tipo de usuario no válido: $userType'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error al obtener detalles del curso: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCourseDetailForTeacher(String courseId) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/cursos/docente/$courseId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Recursos de apoyo
  static Future<Map<String, dynamic>> updateSupportContent(String courseId, Map<String, dynamic> content) async {
    try {
      final token = AuthService.authToken;
      final response = await http.put(
        Uri.parse('$baseUrl/cursos/recursos/$courseId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
        body: jsonEncode(content),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Estudiantes
  static Future<Map<String, dynamic>> getStudentsList(String courseId) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/cursos/$courseId/estudiantes'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Módulos
  static Future<Map<String, dynamic>> getModulesByTeacher() async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/modulos/docente'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Asistencia
  static Future<Map<String, dynamic>> getAttendanceRecords(String courseId) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/asistencia/$courseId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAttendance(String courseId, Map<String, dynamic> attendanceData) async {
    try {
      final token = AuthService.authToken;
      final response = await http.put(
        Uri.parse('$baseUrl/asistencia/$courseId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
        body: jsonEncode(attendanceData),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Perfil
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/perfil'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final token = AuthService.authToken;
      final response = await http.put(
        Uri.parse('$baseUrl/perfil'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
        body: jsonEncode(profileData),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Gestión administrativa de cursos
  static Future<Map<String, dynamic>> createCourse(Map<String, dynamic> courseData) async {
    try {
      final token = AuthService.authToken;
      final response = await http.post(
        Uri.parse('$baseUrl/admin/cursos'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
        body: jsonEncode(courseData),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateCourse(String courseId, Map<String, dynamic> courseData) async {
    try {
      final token = AuthService.authToken;
      final response = await http.put(
        Uri.parse('$baseUrl/admin/cursos/$courseId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
        body: jsonEncode(courseData),
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteCourse(String courseId) async {
    try {
      final token = AuthService.authToken;
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/cursos/$courseId'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAllCourses() async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/admin/cursos'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- Endpoints de Render especificados ---

  // Módulos por oferta
  static Future<Map<String, dynamic>> getModulesByOffer(String idOferta) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/api/modulos/oferta/$idOferta'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Calificaciones por oferta
  static Future<Map<String, dynamic>> getGradesByOffer(String idOferta) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/api/calificaciones/oferta/$idOferta'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Asistencia por persona y curso matriculado
  static Future<Map<String, dynamic>> getAttendanceByPersonAndCourse({
    required String idPersona,
    required String idMatricula,
  }) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/api/asistencia/persona/$idPersona/curso/$idMatricula'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Contenido de apoyo por oferta
  static Future<Map<String, dynamic>> getSupportContentByOffer(String idCursoOferta) async {
    try {
      final token = AuthService.authToken;
      final response = await http.get(
        Uri.parse('$baseUrl/api/contenidoApoyo/oferta/$idCursoOferta'),
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Procesamiento de respuestas
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'message': 'Error ${response.statusCode}: ${response.body}',
      };
    }
  }
}