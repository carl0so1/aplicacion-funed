import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Servicios
import 'services/api_service.dart';
import 'services/auth_service.dart';

// Pantallas
import 'CourseDetailMinimalScreen.dart';
import 'AdminCoursesScreen.dart';

// Componentes compartidos
import 'components/shared/BottomNavBar.dart';
import 'components/shared/CustomAppBar.dart';

// Componentes de la pantalla principal
import 'components/home/HomeContent.dart';
import 'components/home/CoursesSection.dart';
import 'components/home/calendar_section.dart';
import 'components/home/ProfileSection.dart';

// Diálogos
import 'components/dialogs/LogoutDialog.dart';

class HomeScreen extends StatefulWidget {
  final String userType;
  final String userName;

  const HomeScreen({
    Key? key,
    required this.userType,
    required this.userName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _courses = [];
  Map<String, dynamic>? _currentCourse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Función para mapear los datos de la API al formato esperado por la UI
  Map<String, dynamic> _mapCourseData(Map<String, dynamic> apiCourse) {
    // Verificar si es del endpoint cursosPersonas (estructura con idMatricula)
    if (apiCourse.containsKey('idMatricula')) {
      return {
        'id': apiCourse['idCurso']?.toString() ?? apiCourse['id']?.toString(),
        'nombre': apiCourse['nombre']?.toString() ?? 'Sin nombre',
        'codigo': apiCourse['codigo']?.toString() ?? apiCourse['idCurso']?.toString() ?? 'N/A',
        'duracion': apiCourse['duracion'],
        'temario': apiCourse['temario']?.toString() ?? '',
        'tipo_curso': apiCourse['tipo']?.toString() ?? '',
        // Nuevos campos para enlazar endpoints por oferta y matrícula
        'idOferta': apiCourse['idOferta']?.toString()
            ?? apiCourse['idCursoOferta']?.toString()
            ?? apiCourse['id_oferta_curso']?.toString()
            ?? apiCourse['id_oferta']?.toString(),
        'idMatricula': apiCourse['idMatricula']?.toString(),
        // Atributos de UI
        'color': Colors.blue,
        'profesor': 'Por asignar',
        'creditos': 3,
        'semestre': 'Actual',
        'progreso': 0,
      };
    }

    // Mapeo original para otros endpoints (ofertas/cursos)
    return {
      'id': apiCourse['id'],
      'nombre': apiCourse['nombre_curso']?.toString() ?? 'Sin nombre',
      'codigo': apiCourse['codigo']?.toString() ?? apiCourse['id']?.toString() ?? 'N/A',
      'duracion': apiCourse['duracion'],
      'temario': apiCourse['temario']?.toString() ?? '',
      'tipo_curso': apiCourse['tipo_curso']?.toString() ?? '',
      // Intentar capturar idOferta en respuestas genéricas
      'idOferta': apiCourse['idOferta']?.toString()
          ?? apiCourse['id_oferta']?.toString()
          ?? apiCourse['idCursoOferta']?.toString()
          ?? apiCourse['id_oferta_curso']?.toString(),
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

  Future<void> _loadCourses() async {
  try {
    // Verificar que tenemos un token de autenticación
    if (AuthService.authToken == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay sesión activa. Por favor, inicia sesión nuevamente.')),
        );
      }
      return;
    }

    Map<String, dynamic> result;
    
    if (widget.userType.toLowerCase() == 'estudiante') {
      // Usar el nuevo endpoint con ID de persona si está disponible
      final userId = AuthService.userId;
      if (userId != null && userId.isNotEmpty) {
        result = await ApiService.getCoursesByPersonId(userId);
      } else {
        result = await ApiService.getCoursesByStudent();
      }
    } else {
      result = await ApiService.getCoursesByTeacher();
    }
    
    if (mounted) {
      if (result['success'] == true) {
        // Mapear los datos de la API al formato esperado
        List<Map<String, dynamic>> rawCourses = [];
        final dynamic data = result['data'];

        // 1) Si data ya es una lista
        if (data is List) {
          rawCourses = List<Map<String, dynamic>>.from(data);
        }
        // 2) Si data es un mapa, intentar en varias claves conocidas
        else if (data is Map) {
          final candidateKeys = [
            'cursos', 'courses', 'data', 'result', 'records', 'items',
            'cursosPersonas', 'cursos_personas', 'lista', 'rows'
          ];
          for (final key in candidateKeys) {
            final value = data[key];
            if (value is List) {
              rawCourses = List<Map<String, dynamic>>.from(value);
              break;
            }
          }
          // 3) Fallback: buscar la primera lista de mapas en los valores
          if (rawCourses.isEmpty) {
            for (final entry in data.entries) {
              final value = entry.value;
              if (value is List && value.isNotEmpty && value.first is Map) {
                rawCourses = List<Map<String, dynamic>>.from(value);
                break;
              }
            }
          }
        }

        final mappedCourses = rawCourses.map((course) => _mapCourseData(course)).toList();

        setState(() {
          _courses = mappedCourses;
          _currentCourse = _courses.isNotEmpty ? _courses.first : null;
          _isLoading = false;
        });
        
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${result['message'] ?? 'Error desconocido'}')),
        );
      }
    }
  } catch (e) {
    debugPrint('Error al cargar cursos: $e');
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar cursos: $e')),
      );
    }
  }
}

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}

void _cerrarSesion() {
  LogoutDialog.show(context);
}



void _verCurso(Map<String, dynamic> course) async {
  try {
    final courseId = course['id']?.toString() ?? '';
    if (courseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID del curso no válido')),
      );
      return;
    }
  
    // Pre-cargar módulos y contenido de apoyo por idOferta si disponible
    List<Map<String, dynamic>> modules = [];
    List<Map<String, dynamic>> supportContent = [];
    List<Map<String, dynamic>> grades = [];
    List<Map<String, dynamic>> attendance = [];
    double promedioDesdeNotas = double.nan;
    final idOferta = course['idOferta']?.toString();
    if (idOferta != null && idOferta.isNotEmpty) {
      final modulesResult = await ApiService.getModulesByOffer(idOferta);
      final teachersResult = await ApiService.getModuleTeachersByOffer(idOferta);
      if (modulesResult['success'] == true) {
        dynamic raw = modulesResult['data'] ?? modulesResult['result'] ?? modulesResult['records'] ?? modulesResult['items'];
        List<dynamic> rawList = [];
        if (raw is List) {
          rawList = raw;
        } else if (raw is Map) {
          final keys = ['modulos', 'modules', 'data', 'result', 'records', 'items'];
          for (final k in keys) {
            final v = raw[k];
            if (v is List) {
              rawList = v;
              break;
            }
          }
          if (rawList.isEmpty) {
            for (final v in raw.values) {
              if (v is List && v.isNotEmpty && v.first is Map) {
                rawList = v;
                break;
              }
            }
          }
        }
        

        // Preparar mapa de docentes por módulo (por id o nombre)
        final Map<String, String> teacherById = {};
        final Map<String, String> teacherByName = {};
        final dynamic traw = teachersResult['data'] ?? teachersResult['result'] ?? teachersResult['records'] ?? teachersResult['items'];
        if (teachersResult['success'] == true && traw is List) {
          for (final t in traw) {
            if (t is Map) {
              final idModulo = (t['idModulo'] ?? t['moduloId'] ?? t['id'] ?? t['id_modulo']).toString();
              final nombreModulo = (t['nombreModulo'] ?? t['modulo'] ?? t['nombre'] ?? t['nombre_modulo']).toString();
              final docente = (t['docente'] ?? t['nombreDocente'] ?? t['nombresDocente'] ?? t['profesor'] ??
                  ((t['nombres'] != null || t['apellidos'] != null)
                      ? '${t['nombres'] ?? ''} ${t['apellidos'] ?? ''}'.trim()
                      : null))?.toString();
              if (docente != null && docente.isNotEmpty) {
                if (idModulo.isNotEmpty && idModulo != 'null') teacherById[idModulo] = docente;
                if (nombreModulo.isNotEmpty && nombreModulo != 'null') teacherByName[nombreModulo.toLowerCase().trim()] = docente;
              }
            }
          }
          
        }

        modules = List<Map<String, dynamic>>.from(rawList.map((m) {
          final id = (m['id'] ?? m['idModulo'] ?? m['id_modulo']).toString();
          final name = (m['nombre'] ?? m['titulo'] ?? m['nombreModulo'] ?? m['nombre_modulo'] ?? 'Módulo').toString();
          final normalized = name.toLowerCase().trim();
          final teacher = teacherById[id] ?? teacherByName[normalized] ?? 'Asignado';
          return {
            'id': id,
            'title': name,
            'description': (m['descripcion'] ?? m['description'] ?? '').toString(),
            'duration': (m['duracion'] ?? m['duration'] ?? '').toString(),
            'teacher': teacher,
            'completed': false,
          };
        }));
        
      }

      final contentResult = await ApiService.getSupportContentByOffer(idOferta);
      if (contentResult['success'] == true) {
        dynamic craw = contentResult['data'] ?? contentResult['result'] ?? contentResult['records'] ?? contentResult['items'];
        List<dynamic> cList = [];
        if (craw is List) {
          cList = craw;
        } else if (craw is Map) {
          final keys = ['recursos', 'resources', 'data', 'result', 'records', 'items'];
          for (final k in keys) {
            final v = craw[k];
            if (v is List) {
              cList = v;
              break;
            }
          }
          if (cList.isEmpty) {
            for (final v in craw.values) {
              if (v is List && v.isNotEmpty && v.first is Map) {
                cList = v;
                break;
              }
            }
          }
        }
        supportContent = List<Map<String, dynamic>>.from(cList.map((c) => {
              'id': (c['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
              'title': (c['titulo'] ?? c['nombre'] ?? c['title'] ?? 'Recurso').toString(),
              'type': (c['tipo'] ?? 'Archivo').toString(),
              'size': (c['tamano'] ?? c['size'] ?? '').toString(),
              'downloads': (c['descargas'] ?? c['downloads'] ?? 0),
              'filePath': (c['archivo'] ?? c['url'] ?? c['filePath'] ?? '').toString(),
              'uploadDate': (c['fechaSubida'] ?? c['fecha'] ?? c['uploadDate'] ?? '' ).toString(),
              'description': (c['descripcion'] ?? c['description'] ?? '').toString(),
              'tags': List<String>.from((c['tags'] ?? []) as List? ?? []),
            }));
        
      }

      // Calificaciones por persona y oferta
      final idPersona = AuthService.userId;
      if (idPersona != null && idPersona.isNotEmpty) {
        final gradesResult = await ApiService.getModuleGradesByPersonAndOffer(
          idPersona: idPersona,
          idOfertaCurso: idOferta,
        );
        if (gradesResult['success'] == true) {
          dynamic graw = gradesResult['data'] ?? gradesResult['result'] ?? gradesResult['records'] ?? gradesResult['items'];
          List<dynamic> gList = [];
          if (graw is List) {
            gList = graw;
          } else if (graw is Map) {
            final keys = ['calificaciones', 'notas', 'grades', 'data', 'result', 'records', 'items'];
            for (final k in keys) {
              final v = graw[k];
              if (v is List) {
                gList = v;
                break;
              }
            }
            if (gList.isEmpty) {
              for (final v in graw.values) {
                if (v is List && v.isNotEmpty && v.first is Map) {
                  gList = v;
                  break;
                }
              }
            }
          }

          double sum = 0.0;
          int count = 0;
          grades = List<Map<String, dynamic>>.from(gList.whereType<Map>().map((gr) {
            String moduleId = (gr['idModulo'] ?? gr['moduloId'] ?? gr['id_modulo'] ?? gr['id']).toString();
            // Resolver nombre de módulo evitando imprimir mapas como String
            String moduleName = '';
            final moduloField = gr['modulo'];
            if (moduloField is Map) {
              moduleName = (moduloField['nombre'] ?? moduloField['title'] ?? moduloField['nombreModulo'] ?? moduloField['nombre_modulo'] ?? moduloField['titulo'] ?? '').toString();
              if (moduleId.isEmpty || moduleId == 'null') {
                final mid = (moduloField['id'] ?? moduloField['idModulo'] ?? moduloField['moduloId'] ?? moduloField['id_modulo']);
                if (mid != null) moduleId = mid.toString();
              }
            } else if (moduloField is String) {
              moduleName = moduloField;
            }
            if (moduleName.isEmpty) {
              moduleName = (gr['nombreModulo'] ?? gr['nombre'] ?? gr['nombre_modulo'] ?? gr['titulo'] ?? '').toString();
            }
            if (moduleName.isEmpty || moduleName.startsWith('{')) {
              moduleName = 'Módulo';
            }
            final scoreRaw = gr['nota'] ?? gr['calificacion'] ?? gr['puntaje'] ?? gr['valor'] ?? gr['score'];
            double scoreVal = double.nan;
            if (scoreRaw is num) {
              scoreVal = scoreRaw.toDouble();
            } else if (scoreRaw is String) {
              final parsed = double.tryParse(scoreRaw.replaceAll('%', '').trim());
              if (parsed != null) scoreVal = parsed;
            }
            if (!scoreVal.isNaN) {
              sum += scoreVal;
              count += 1;
            }
            // Extraer estado como texto plano, evitando imprimir mapas
            String statusText = '';
            final rawStatus = gr['estado'] ?? gr['status'];
            if (rawStatus is Map) {
              statusText = (rawStatus['estado'] ?? rawStatus['status'] ?? rawStatus['name'] ?? rawStatus['label'] ?? rawStatus['texto'] ?? '').toString();
            } else if (rawStatus is String) {
              statusText = rawStatus;
            } else if (rawStatus != null) {
              statusText = rawStatus.toString();
            }
            return {
              'moduleId': moduleId,
              'module': moduleName,
              'score': scoreVal.isNaN ? null : scoreVal,
              'status': statusText,
              'date': (gr['fecha'] ?? gr['date'] ?? '').toString(),
              'teacher': (gr['docente'] ?? gr['teacher'] ?? '').toString(),
            };
          }));
          if (count > 0) {
            promedioDesdeNotas = sum / count;
          }
        }
      }
    }

    // Asistencia por persona y curso matriculado (requiere idPersona e idMatricula)
    final idPersona = AuthService.userId;
    final idMatricula = course['idMatricula']?.toString();
    if (widget.userType.toLowerCase() == 'estudiante' && idPersona != null && idPersona.isNotEmpty && idMatricula != null && idMatricula.isNotEmpty) {
      final attResult = await ApiService.getAttendanceByPersonAndEnrolledCourse(
        idPersona: idPersona,
        idCursoMatriculado: idMatricula,
      );
      if (attResult['success'] == true) {
        dynamic raw = attResult['data'] ?? attResult['result'] ?? attResult['records'] ?? attResult['items'] ?? attResult['asistencias'] ?? attResult['attendance'];
        List<dynamic> rawList = [];
        if (raw is List) {
          rawList = raw;
        } else if (raw is Map) {
          final keys = ['asistencias', 'attendance', 'data', 'result', 'records', 'items'];
          for (final k in keys) {
            final v = raw[k];
            if (v is List) {
              rawList = v;
              break;
            }
          }
          if (rawList.isEmpty) {
            for (final v in raw.values) {
              if (v is List && v.isNotEmpty && v.first is Map) {
                rawList = v;
                break;
              }
            }
          }
        }
        if (rawList.isNotEmpty) {
          attendance = List<Map<String, dynamic>>.from(rawList.whereType<Map>().map((a) {
            // Fecha y hora
            final date = (a['fecha'] ?? a['fecha_asistencia'] ?? a['date'] ?? a['createdAt'] ?? '').toString();
            final time = (a['hora'] ?? a['hora_asistencia'] ?? a['time'] ?? '').toString();
            // Estado: puede venir como texto, bool o mapa
            String statusText = '';
            final rawSt = a['estado'] ?? a['status'] ?? a['asistio'] ?? a['presente'];
            if (rawSt is bool) {
              statusText = rawSt ? 'Presente' : 'Ausente';
            } else if (rawSt is Map) {
              statusText = (rawSt['estado'] ?? rawSt['status'] ?? rawSt['label'] ?? '').toString();
            } else if (rawSt is String) {
              statusText = rawSt;
            } else if (rawSt != null) {
              statusText = rawSt.toString();
            }
            // Observaciones
            final notes = (a['observaciones'] ?? a['nota'] ?? a['comentarios'] ?? a['notes'] ?? '').toString();
            // Clase/Sesión
            final session = (a['clase'] ?? a['sesion'] ?? a['session'] ?? a['modulo'] ?? '').toString();
            return {
              'date': date,
              'time': time,
              'status': statusText,
              'notes': notes,
              'session': session,
            };
          }));
        }
      }
    }

    final courseDetails = await ApiService.getCourseDetails(courseId);
    if (!mounted) return;
    // Fallback: intentar extraer módulos desde detalles si no se obtuvo por oferta
    if (modules.isEmpty) {
      final d = courseDetails['data'];
      List<dynamic> dList = [];
      if (d is List) {
        dList = d;
      } else if (d is Map) {
        final keys = ['modulos', 'modules', 'data', 'result', 'records', 'items'];
        for (final k in keys) {
          final v = d[k];
          if (v is List) {
            dList = v;
            break;
          }
        }
        if (dList.isEmpty) {
          for (final v in d.values) {
            if (v is List && v.isNotEmpty && v.first is Map) {
              dList = v;
              break;
            }
          }
        }
      }
      if (dList.isNotEmpty) {
        modules = List<Map<String, dynamic>>.from(dList.map((m) {
          final id = (m['id'] ?? m['idModulo'] ?? m['id_modulo']).toString();
          final name = (m['nombre'] ?? m['titulo'] ?? m['nombreModulo'] ?? m['nombre_modulo'] ?? 'Módulo').toString();
          return {
            'id': id,
            'title': name,
            'description': (m['descripcion'] ?? m['description'] ?? '').toString(),
            'duration': (m['duracion'] ?? m['duration'] ?? '').toString(),
            'teacher': (m['docente'] ?? m['teacher'] ?? 'Asignado').toString(),
            'completed': false,
          };
        }));
        
      }
    }
  
    // Unir información del curso con datos precargados
    final Map<String, dynamic> mergedCourseInfo = {
      ...course,
      ...(courseDetails['data'] is Map
          ? Map<String, dynamic>.from(courseDetails['data'])
          : {}),
      'modulesData': modules,
      'supportContentData': supportContent,
      'gradesData': grades,
      'attendanceData': attendance,
      if (!promedioDesdeNotas.isNaN) 'promedio': promedioDesdeNotas,
    };
  
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailMinimalScreen(
          courseInfo: mergedCourseInfo,
          userType: widget.userType,
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar los detalles del curso: $e')),
    );
  }
}

Widget _buildBody() {
  if (_isLoading) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  switch (_selectedIndex) {
    case 0:
      return HomeContent(
        userType: widget.userType,
        userName: widget.userName,
        currentCourse: _currentCourse,
        onViewCourse: _verCurso,
      );
    case 1:
      return CoursesSection(
        userType: widget.userType,
        onViewCourse: _verCurso,
        courses: _courses,
      );
    case 2:
      return const CalendarSection();
    case 3:
      return ProfileSection(
        userName: widget.userName,
        userType: widget.userType,
        userEmail: 'user@example.com',
        onLogout: _cerrarSesion,
      );
    case 4:
      // Solo mostrar AdminCoursesScreen si el usuario es docente
      if (widget.userType.toLowerCase() == 'docente') {
        return const AdminCoursesScreen();
      }
      return HomeContent(
        userType: widget.userType,
        userName: widget.userName,
        currentCourse: _currentCourse,
        onViewCourse: _verCurso,
      );
    default:
      return HomeContent(
        userType: widget.userType,
        userName: widget.userName,
        currentCourse: _currentCourse,
        onViewCourse: _verCurso,
      );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF2B1A7F),
    appBar: const CustomAppBar(title: 'FUNED'),
    body: _buildBody(),
    bottomNavigationBar: BottomNavBar(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      userType: widget.userType,
    ),
  );
}
}