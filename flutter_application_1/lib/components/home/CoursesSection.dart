import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class CoursesSection extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final Function(Map<String, dynamic>) onViewCourse;
  final String userType;

  const CoursesSection({
    Key? key,
    required this.courses,
    required this.onViewCourse,
    required this.userType,
  }) : super(key: key);

  @override
  State<CoursesSection> createState() => _CoursesSectionState();
}

class _CoursesSectionState extends State<CoursesSection> {
  List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
    _courses = List<Map<String, dynamic>>.from(widget.courses);
    // Si no hay cursos cargados, consumir el endpoint correspondiente según el tipo de usuario
    if (_courses.isEmpty) {
      if (widget.userType.toLowerCase() == 'estudiante') {
        _loadCoursesFromApi();
      } else if (widget.userType.toLowerCase() == 'docente') {
        _loadTeacherCoursesFromApi();
      }
    }
  }

  Future<void> _loadCoursesFromApi() async {
    try {
      final userId = AuthService.userId;
      if (userId == null || userId.isEmpty) {
        // Sin id_persona no podemos consultar
        return;
      }
      final res = await ApiService.getCoursesByPersonId(userId);
      if (res['success'] == true) {
        final data = res['data'];
        List<Map<String, dynamic>> rawCourses = [];
        if (data is List) {
          rawCourses = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // Intentar extraer lista desde varias posibles claves
          final candidateKeys = [
            'cursos', 'courses', 'data', 'result', 'records', 'items',
            'cursosPersonas', 'lista', 'rows'
          ];
          for (final key in candidateKeys) {
            final value = data[key];
            if (value is List) {
              rawCourses = List<Map<String, dynamic>>.from(value);
              break;
            }
          }
        }

        final mapped = rawCourses.map<Map<String, dynamic>>(_mapCourseData).toList();
        if (!mounted) return;
        setState(() {
          _courses = mapped;
        });
      }
    } catch (e) {
      // Silencioso: mantenemos la UI sin cambios si falla
    }
  }

  Map<String, dynamic> _mapCourseData(Map<String, dynamic> apiCourse) {
    // Estructura cursosPersonas con idMatricula
    if (apiCourse.containsKey('idMatricula')) {
      return {
        'id': apiCourse['idCurso']?.toString() ?? apiCourse['id']?.toString(),
        'nombre': apiCourse['nombre']?.toString() ?? 'Sin nombre',
        'codigo': apiCourse['codigo']?.toString() ?? apiCourse['idCurso']?.toString() ?? 'N/A',
        'duracion': apiCourse['duracion'],
        'temario': apiCourse['temario']?.toString() ?? '',
        'tipo_curso': apiCourse['tipo']?.toString() ?? '',
        'idOferta': apiCourse['idOferta']?.toString(),
        'idMatricula': apiCourse['idMatricula']?.toString(),
        'color': Colors.blue,
        'progreso': 0,
        'semestre': 'Actual',
      };
    }

    // Mapeo genérico en caso de otras estructuras
    return {
      'id': apiCourse['id']?.toString(),
      'nombre': apiCourse['nombre_curso']?.toString() ?? apiCourse['nombre']?.toString() ?? 'Sin nombre',
      'codigo': apiCourse['codigo']?.toString() ?? apiCourse['id']?.toString() ?? 'N/A',
      'duracion': apiCourse['duracion'],
      'temario': apiCourse['temario']?.toString() ?? '',
      'tipo_curso': apiCourse['tipo_curso']?.toString() ?? apiCourse['tipo']?.toString() ?? '',
      'fechaInicio': apiCourse['fechaInicio']?.toString() ?? '',
      'fechaFin': apiCourse['fechaFin']?.toString() ?? '',
      'horario': apiCourse['horario']?.toString() ?? '',
      'precio': apiCourse['precio']?.toString() ?? '',
      'cupos': apiCourse['cupos'],
      'color': Colors.cyan,
      'progreso': 0,
      'totalEstudiantes': 0,
      'tareasPendientes': 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Cursos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (courses.isEmpty)
            const Center(
              child: Text(
                'No tienes cursos asignados',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: course['color'] ?? Colors.cyan,
                      child: const Icon(
                        Icons.book,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      course['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código: ${course['codigo'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        if (course['horario'] != null && course['horario'].toString().isNotEmpty)
                          Text(
                            'Horario: ${course['horario']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        if (course['fechaInicio'] != null && course['fechaInicio'].toString().isNotEmpty)
                          Text(
                            'Inicio: ${course['fechaInicio']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        if (course['fechaFin'] != null && course['fechaFin'].toString().isNotEmpty)
                          Text(
                            'Fin: ${course['fechaFin']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (widget.userType.toLowerCase() == 'estudiante') ...[
                          if (course['progreso'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (course['progreso'] ?? 0) / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      course['color'] ?? Colors.cyan,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${course['progreso'] ?? 0}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (course['proximaClase'] != null)
                            Text(
                              'Próxima clase: ${course['proximaClase']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                        if (widget.userType.toLowerCase() == 'docente') ...[
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${course['totalEstudiantes'] ?? 0} estudiantes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${course['tareasPendientes'] ?? 0} tareas pendientes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => widget.onViewCourse(course),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: course['color'] ?? Colors.cyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.userType.toLowerCase() == 'estudiante' ? 'Ver curso' : 'Gestionar',
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _loadTeacherCoursesFromApi() async {
    try {
      final userId = AuthService.userId;
      if (userId == null || userId.isEmpty) {
        // Sin id_persona no podemos consultar
        return;
      }
      final res = await ApiService.getTeacherCoursesByPersonId(userId);
      if (res['success'] == true) {
        final data = res['data'];
        List<Map<String, dynamic>> rawCourses = [];
        if (data is List) {
          rawCourses = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // Intentar extraer lista desde varias posibles claves
          final candidateKeys = [
            'cursos', 'courses', 'data', 'result', 'records', 'items',
            'ofertaCursos', 'ofertas', 'lista', 'rows'
          ];
          for (final key in candidateKeys) {
            final value = data[key];
            if (value is List) {
              rawCourses = List<Map<String, dynamic>>.from(value);
              break;
            }
          }
        }

        final mapped = rawCourses.map<Map<String, dynamic>>(_mapCourseData).toList();
        if (!mounted) return;
        setState(() {
          _courses = mapped;
        });
      }
    } catch (e) {
      // Silencioso: mantenemos la UI sin cambios si falla
    }
  }
}