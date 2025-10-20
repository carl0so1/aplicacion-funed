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

    // Mapeo robusto para otros endpoints (ofertas/cursos/docente por id_persona)
    // Resolver ID de curso preferentemente (no de oferta)
    String courseId = (apiCourse['idCurso']
            ?? apiCourse['id_curso']
            ?? apiCourse['cursoId']
            ?? apiCourse['curso_id']
            ?? apiCourse['courseId'])
        ?.toString() ?? '';
    if (courseId.isEmpty || courseId == 'null') {
      final cursoObj = apiCourse['curso'] ?? apiCourse['course'];
      if (cursoObj is Map) {
        final nestedId = (cursoObj['id'] ?? cursoObj['idCurso'] ?? cursoObj['courseId']);
        if (nestedId != null) courseId = nestedId.toString();
      }
    }
    if (courseId.isEmpty || courseId == 'null') {
      // Último recurso: usar 'id' si es lo único disponible
      courseId = apiCourse['id']?.toString() ?? '';
    }

    // Resolver ID de oferta de curso
    final idOferta = (apiCourse['idOferta']
            ?? apiCourse['id_oferta']
            ?? apiCourse['idCursoOferta']
            ?? apiCourse['id_oferta_curso']
            ?? apiCourse['idOfertaCurso'])
        ?.toString();

    // Resolver nombre del curso
    String nombre = (apiCourse['nombre_curso']
            ?? apiCourse['nombreCurso']
            ?? apiCourse['nombre'])
        ?.toString() ?? '';
    if (nombre.isEmpty || nombre == 'null') {
      final cursoObj = apiCourse['curso'] ?? apiCourse['course'];
      if (cursoObj is Map) {
        nombre = (cursoObj['nombre'] ?? cursoObj['nombre_curso'] ?? cursoObj['title'])?.toString() ?? '';
      }
    }
    if (nombre.isEmpty) nombre = 'Sin nombre';

    // Resolver código del curso
    String codigo = (apiCourse['codigo']
            ?? apiCourse['codigo_curso']
            ?? apiCourse['sigla']
            ?? apiCourse['code'])
        ?.toString() ?? '';
    if (codigo.isEmpty || codigo == 'null') {
      final cursoObj = apiCourse['curso'] ?? apiCourse['course'];
      if (cursoObj is Map) {
        codigo = (cursoObj['codigo'] ?? cursoObj['sigla'] ?? cursoObj['code'])?.toString() ?? '';
      }
    }
    if (codigo.isEmpty) codigo = (courseId.isNotEmpty ? courseId : 'N/A');

    // Resolver horario (puede venir como string o lista de objetos)
    String horario = apiCourse['horario']?.toString() ?? '';
    if (horario.isEmpty) {
      final horarios = apiCourse['horarios'];
      if (horarios is List && horarios.isNotEmpty) {
        final parts = <String>[];
        for (final h in horarios) {
          if (h is String) {
            parts.add(h);
          } else if (h is Map) {
            final dia = (h['dia'] ?? h['day'])?.toString();
            final ini = (h['horaInicio'] ?? h['inicio'] ?? h['start'])?.toString();
            final fin = (h['horaFin'] ?? h['fin'] ?? h['end'])?.toString();
            final aula = (h['aula'] ?? h['salon'] ?? h['room'])?.toString();
            final seg = [dia, ini, fin, aula].where((e) => e != null && e.toString().isNotEmpty).join(' ');
            if (seg.isNotEmpty) parts.add(seg);
          }
        }
        horario = parts.join(' | ');
      }
    }

    return {
      'id': courseId,
      'nombre': nombre,
      'codigo': codigo,
      'duracion': apiCourse['duracion'],
      'temario': apiCourse['temario']?.toString() ?? '',
      'tipo_curso': apiCourse['tipo_curso']?.toString() ?? apiCourse['tipo']?.toString() ?? '',
      'idOferta': idOferta,
      'fechaInicio': apiCourse['fechaInicio']?.toString() ?? apiCourse['fecha_inicio']?.toString() ?? '',
      'fechaFin': apiCourse['fechaFin']?.toString() ?? apiCourse['fecha_fin']?.toString() ?? '',
      'horario': horario,
      'precio': apiCourse['precio']?.toString() ?? '',
      'cupos': apiCourse['cupos'] ?? apiCourse['vacantes'] ?? apiCourse['capacidad'],
      'color': Colors.cyan,
      'progreso': 0,
      'totalEstudiantes': apiCourse['totalEstudiantes'] ?? apiCourse['estudiantes'] is List ? (apiCourse['estudiantes'] as List).length : 0,
      'tareasPendientes': apiCourse['tareasPendientes'] ?? 0,
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
      // Docente: preferir endpoint por id_persona si disponible
      final userId = AuthService.userId;
      debugPrint('HomeScreen:_loadCourses → rol=docente, id_persona desde login = ${userId ?? '(no disponible)'}');
      if (userId != null && userId.isNotEmpty) {
        debugPrint('HomeScreen:_loadCourses → consumiendo api/ofertaCursos/docente/$userId');
        result = await ApiService.getOffersByTeacherPersonId(userId);
      } else {
        debugPrint('HomeScreen:_loadCourses → consumiendo api/cursos/docente (sin id_persona)');
        result = await ApiService.getCoursesByTeacher();
      }
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
            'cursosPersonas', 'cursos_personas', 'lista', 'rows',
            'ofertaCursos', 'ofertasCursos', 'oferta_cursos', 'ofertas_cursos'
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
        // Logs de verificación de mapeo
        debugPrint('📚 Cursos recibidos: ${rawCourses.length}');
        debugPrint('📚 Cursos mapeados: ${mappedCourses.length}');
        if (mappedCourses.isNotEmpty) {
          final sample = mappedCourses.first;
          debugPrint('🔎 Ejemplo curso mapeado → id: ${sample['id']}, idOferta: ${sample['idOferta']}, nombre: ${sample['nombre']}, codigo: ${sample['codigo']}');
        }

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
  double asistenciaCalculada = double.nan;
  // Mapa auxiliar de docentes por módulo para pasar a la pantalla de detalle
  final Map<String, String> moduleTeachersById = {};
  final Map<String, String> moduleTeachersByName = {};
  final idOferta = course['idOferta']?.toString();
  if (idOferta != null && idOferta.isNotEmpty) {
      // Primero intentamos con el endpoint de docente+oferta si aplica; hacemos fallback a módulos por oferta SOLO si falla
      Map<String, dynamic> modulesResult = (widget.userType.toLowerCase() == 'docente' && (AuthService.userId ?? '').isNotEmpty)
          ? await ApiService.getModulesByTeacherAndOffer(
              idPersona: AuthService.userId!,
              idOfertaCurso: idOferta,
            )
          : await ApiService.getModulesByOffer(idOferta);
      final teachersResult = await ApiService.getModuleTeachersByOffer(idOferta);
      // Preparar mapa de docentes por módulo (por id o nombre)
      {
        final dynamic root = teachersResult['data'] ?? teachersResult['result'] ?? teachersResult['records'] ?? teachersResult['items'] ?? teachersResult;
        List<dynamic> asignaciones = [];
        if (teachersResult['success'] == true) {
          if (root is List) {
            asignaciones = root;
          } else if (root is Map) {
            // Respuesta según ejemplo: { asignaciones: [ ... ] }
            final dynamic ar = root['asignaciones'];
            if (ar is List) {
              asignaciones = ar;
            } else {
              // Intentar encontrar lista anidada
              for (final v in root.values) {
                if (v is List && v.isNotEmpty && v.first is Map) {
                  asignaciones = v;
                  break;
                } else if (v is Map) {
                  final lv = v['asignaciones'];
                  if (lv is List) { asignaciones = lv; break; }
                }
              }
            }
          }
        }
        for (final t in asignaciones.whereType<Map>()) {
          // id del módulo
          final String idModulo = (
            t['id_modulo'] ?? t['idModulo'] ?? (t['modulo'] is Map ? (t['modulo']['id']) : null)
          )?.toString() ?? '';
          // nombre del módulo
          String nombreModulo = '';
          final dynamic mod = t['modulo'];
          if (mod is Map) {
            nombreModulo = (mod['nombre'] ?? mod['title'] ?? mod['nombreModulo'] ?? mod['nombre_modulo'] ?? '').toString();
          } else {
            nombreModulo = (t['nombreModulo'] ?? t['modulo'] ?? t['nombre'] ?? t['nombre_modulo'] ?? '').toString();
          }
          // docente asignado
          String docente = (t['docenteNombre'] ?? '').toString();
          if (docente.isEmpty || docente.toLowerCase() == 'null') {
            final dynamic d = t['docente'];
            if (d is Map) {
              final dynamic p = d['persona'];
              if (p is Map) {
                final nombres = (p['nombre'] ?? p['nombres'] ?? '').toString();
                final apellidos = (p['apellido'] ?? p['apellidos'] ?? '').toString();
                final combinado = '$nombres $apellidos'.trim();
                if (combinado.isNotEmpty && combinado.toLowerCase() != 'null') {
                  docente = combinado;
                }
              }
              if (docente.isEmpty || docente.toLowerCase() == 'null') {
                final nombres = (d['nombres'] ?? d['nombre'] ?? '').toString();
                final apellidos = (d['apellidos'] ?? d['apellido'] ?? '').toString();
                final combinado = '$nombres $apellidos'.trim();
                if (combinado.isNotEmpty && combinado.toLowerCase() != 'null') {
                  docente = combinado;
                }
              }
            }
          }
          if (docente.isNotEmpty && docente.toLowerCase() != 'null') {
            if (idModulo.isNotEmpty && idModulo.toLowerCase() != 'null') {
              moduleTeachersById[idModulo] = docente;
            }
            if (nombreModulo.isNotEmpty && nombreModulo.toLowerCase() != 'null') {
              moduleTeachersByName[nombreModulo.toLowerCase().trim()] = docente;
            }
          }
        }
      }
      if (modulesResult['success'] == true) {
        dynamic raw = modulesResult['data'] ?? modulesResult['result'] ?? modulesResult['records'] ?? modulesResult['items'];
        List<dynamic> rawList = [];
        if (raw is List) {
          rawList = raw;
        } else if (raw is Map) {
          final keys = ['modulos', 'modules', 'modulosDisponibles', 'data', 'result', 'records', 'items'];
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

        // Si la llamada fue exitosa pero lista vacía y eres docente, no hacemos fallback (evitamos mostrar módulos ajenos).
        modules = List<Map<String, dynamic>>.from(rawList.whereType<Map>().map((m) {
          final id = (m['id'] ?? m['idModulo'] ?? m['id_modulo']).toString();
          final name = (m['nombre'] ?? m['titulo'] ?? m['nombreModulo'] ?? m['nombre_modulo'] ?? 'Módulo').toString();
          final normalized = name.toLowerCase().trim();
          // Priorizar docente directo del módulo; si no está, usar mapa por id/nombre
          final dynamic teacherRaw = m['docente'] ?? m['teacher'];
          final String teacher = (teacherRaw != null && teacherRaw.toString().trim().isNotEmpty && teacherRaw.toString().toLowerCase() != 'null')
              ? teacherRaw.toString()
              : (moduleTeachersById[id] ?? moduleTeachersByName[normalized] ?? 'Asignado');
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
      // Fallback solo si la petición principal falló
      else if (widget.userType.toLowerCase() == 'docente') {
        final offerModulesRes = await ApiService.getModulesByOffer(idOferta);
        if (offerModulesRes['success'] == true) {
          dynamic oraw = offerModulesRes['data'] ?? offerModulesRes['result'] ?? offerModulesRes['records'] ?? offerModulesRes['items'];
          List<dynamic> rawList = [];
          if (oraw is List) {
            rawList = oraw;
          } else if (oraw is Map) {
            final okeys = ['modulos', 'modules', 'modulosDisponibles', 'data', 'result', 'records', 'items'];
            for (final k in okeys) {
              final v = oraw[k];
              if (v is List) {
                rawList = v;
                break;
              }
            }
            if (rawList.isEmpty) {
              for (final v in oraw.values) {
                if (v is List && v.isNotEmpty && v.first is Map) {
                  rawList = v;
                  break;
                }
              }
            }
          }
          modules = List<Map<String, dynamic>>.from(rawList.whereType<Map>().map((m) {
            final id = (m['id'] ?? m['idModulo'] ?? m['id_modulo']).toString();
            final name = (m['nombre'] ?? m['titulo'] ?? m['nombreModulo'] ?? m['nombre_modulo'] ?? 'Módulo').toString();
            final normalized = name.toLowerCase().trim();
            final teacher = moduleTeachersById[id] ?? moduleTeachersByName[normalized] ?? 'Asignado';
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
            // Extraer estado y normalizar a Aprobado/Pendiente/Desaprobado
            String statusText = '';
            final rawStatus = gr['estado'] ?? gr['status'];
            if (rawStatus is Map) {
              statusText = (rawStatus['estado'] ?? rawStatus['status'] ?? rawStatus['name'] ?? rawStatus['label'] ?? rawStatus['texto'] ?? '').toString();
            } else if (rawStatus is String) {
              statusText = rawStatus;
            } else if (rawStatus != null) {
              statusText = rawStatus.toString();
            }
            String statusNorm = statusText.trim();
            final lower = statusNorm.toLowerCase();
            if (lower.contains('aprob') || lower.contains('complet') || lower.contains('finaliz')) {
              statusNorm = 'Aprobado';
            } else if (lower.contains('pend') || lower.contains('progres') || lower.contains('curso')) {
              statusNorm = 'Pendiente';
            } else if (lower.contains('desaprob') || lower.contains('reprob') || lower.contains('no aprob') || lower.contains('desap')) {
              statusNorm = 'Desaprobado';
            } else if (!scoreVal.isNaN) {
              statusNorm = scoreVal >= 60 ? 'Aprobado' : 'Desaprobado';
            } else {
              statusNorm = 'Pendiente';
            }
            return {
              'moduleId': moduleId,
              'module': moduleName,
              'score': scoreVal.isNaN ? null : scoreVal,
              'status': statusNorm,
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

          // Calcular porcentaje de asistencia para métricas
          int presentes = 0;
          final int totalSesiones = attendance.length;
          for (final a in attendance) {
            final st = (a['status'] ?? '').toString().toLowerCase();
            if (st.contains('prese') || st.contains('asist') || st.contains('si')) {
              presentes += 1;
            }
          }
          asistenciaCalculada = totalSesiones > 0 ? (presentes * 100.0) / totalSesiones : double.nan;
        }

        // Actualizar estado 'completed' de módulos usando calificaciones
        if (modules.isNotEmpty && grades.isNotEmpty) {
          final Set<String> completosPorId = {};
          final Set<String> completosPorNombre = {};

          for (final gr in grades) {
            final String status = (gr['status'] ?? '').toString().toLowerCase();
            final dynamic scoreRaw = gr['score'];
            double scoreVal = double.nan;
            if (scoreRaw is num) {
              scoreVal = scoreRaw.toDouble();
            } else if (scoreRaw is String) {
              final parsed = double.tryParse(scoreRaw.replaceAll('%', '').trim());
              if (parsed != null) scoreVal = parsed;
            }
            final String mid = (gr['moduleId'] ?? '').toString();
            final String mname = (gr['module'] ?? '').toString().toLowerCase().trim();

            bool isComplete = false;
            if (status.contains('apro') || status.contains('complet') || status.contains('finaliz')) {
              isComplete = true;
            } else if (!scoreVal.isNaN && scoreVal >= 60) { // heurística
              isComplete = true;
            }

            if (isComplete) {
              if (mid.isNotEmpty) completosPorId.add(mid);
              if (mname.isNotEmpty) completosPorNombre.add(mname);
            }
          }

          modules = modules.map((m) {
            final id = (m['id'] ?? '').toString();
            final nameNorm = (m['title'] ?? m['nombre'] ?? '').toString().toLowerCase().trim();
            final completed = completosPorId.contains(id) || (nameNorm.isNotEmpty && completosPorNombre.contains(nameNorm));
            return {
              ...m,
              'completed': completed,
            };
          }).toList();
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
      'moduleTeachersData': {
        'byId': moduleTeachersById,
        'byName': moduleTeachersByName,
      },
      'supportContentData': supportContent,
      'gradesData': grades,
      'attendanceData': attendance,
      if (!promedioDesdeNotas.isNaN) 'promedio': promedioDesdeNotas,
      if (!asistenciaCalculada.isNaN) 'asistencia': asistenciaCalculada,
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