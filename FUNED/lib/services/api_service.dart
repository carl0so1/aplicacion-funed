import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

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
      
      final url = Uri.parse('$baseUrl/api/cursos/docente');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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

  // Ofertas de cursos por docente usando id_persona
  static Future<Map<String, dynamic>> getOffersByTeacherPersonId(String idPersona) async {
    try {
      final token = AuthService.authToken;
      debugPrint('👨‍🏫 Solicitud ofertas por docente id_persona: $idPersona');
      debugPrint('🔑 Token: ${token?.substring(0, 20)}...');
      final url = Uri.parse('$baseUrl/api/ofertaCursos/docente/$idPersona');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      print('📡 getOffersByTeacherPersonId status: ${response.statusCode}');
      print('📡 getOffersByTeacherPersonId body: ${response.body}');

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCourseDetailForStudent(String courseId) async {
    try {
      final token = AuthService.authToken;
      final url = Uri.parse('$baseUrl/api/cursos/estudiante/$courseId');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/cursos/docente/$courseId');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/modulos/docente');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/asistencia/$courseId');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/asistencia/$courseId');
      print('➡️ PUT: $url');
      final response = await http.put(
        url,
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
      final url = Uri.parse('$baseUrl/api/perfil');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/perfil');
      print('➡️ PUT: $url');
      final response = await http.put(
        url,
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
      final url = Uri.parse('$baseUrl/api/admin/cursos');
      print('➡️ POST: $url');
      final response = await http.post(
        url,
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
      final url = Uri.parse('$baseUrl/api/admin/cursos/$courseId');
      print('➡️ PUT: $url');
      final response = await http.put(
        url,
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
      final url = Uri.parse('$baseUrl/api/admin/cursos/$courseId');
      print('➡️ DELETE: $url');
      final response = await http.delete(
        url,
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
      final url = Uri.parse('$baseUrl/api/admin/cursos');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Procesamiento de respuestas
  static Map<String, dynamic> _processResponse(http.Response response) {
    print('🧾 Procesando respuesta (${response.statusCode})');
    dynamic parsed;
    try {
      if (response.body.isNotEmpty) {
        parsed = jsonDecode(response.body);
      }
    } catch (_) {
      parsed = response.body; // no-JSON, devolver texto crudo
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': parsed,
      };
    } else {
      return {
        'success': false,
        'message': 'Error ${response.statusCode}',
        'details': parsed,
      };
    }
  }
 

  // --- Endpoints de Render especificados ---

  // Módulos por docente (id_persona) y oferta de curso (id_oferta_curso)
  static Future<Map<String, dynamic>> getModulesByTeacherAndOffer({
    required String idPersona,
    required String idOfertaCurso,
  }) async {
    try {
      final token = AuthService.authToken;
      // Según especificación: /api/modulos/docente/:id_persona/oferta_curso/:id_oferta_curso
      final url = Uri.parse('$baseUrl/api/modulos/docente/$idPersona/oferta_curso/$idOfertaCurso');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Módulos por oferta
  static Future<Map<String, dynamic>> getModulesByOffer(String idOferta) async {
    try {
      final token = AuthService.authToken;
      final url = Uri.parse('$baseUrl/api/modulos/oferta/$idOferta');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/calificaciones/oferta/$idOferta');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/asistencia/persona/$idPersona/curso/$idMatricula');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
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
      final url = Uri.parse('$baseUrl/api/contenidoApoyo/oferta/$idCursoOferta');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Docente asignado por módulo para una oferta
  static Future<Map<String, dynamic>> getModuleTeachersByOffer(String idOfertaCurso) async {
    try {
      final token = AuthService.authToken;
      final url = Uri.parse('$baseUrl/api/modulo-docente/oferta/$idOfertaCurso');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Notas por persona y oferta de curso
  static Future<Map<String, dynamic>> getModuleGradesByPersonAndOffer({
    required String idPersona,
    required String idOfertaCurso,
  }) async {
    try {
      final token = AuthService.authToken;
      final url = Uri.parse('$baseUrl/api/notas-modulo/$idPersona/$idOfertaCurso');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Asistencias por persona y curso matriculado
  static Future<Map<String, dynamic>> getAttendanceByPersonAndEnrolledCourse({
    required String idPersona,
    required String idCursoMatriculado,
  }) async {
    try {
      final token = AuthService.authToken;
      final url = Uri.parse('$baseUrl/api/asistencia/persona/$idPersona/curso/$idCursoMatriculado');
      print('➡️ GET: $url');
      final response = await http.get(
        url,
        headers: {...headers, if (token != null) 'Authorization': 'Bearer $token'},
      );
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}