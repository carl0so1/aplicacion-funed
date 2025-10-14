import 'package:flutter/material.dart';

// Servicios
import 'services/api_service.dart';
import 'services/auth_service.dart';

// Pantallas
import 'CourseDetailScreen.dart';
// import 'AdminCoursesScreen.dart';

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

import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String userType;
  final String userName;

  const HomeScreen({
    Key? key,
    required this.userType,
    required this.userName,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _courses = [];
  Map<String, dynamic>? _currentCourse;
  bool _isLoading = true;
  String? _uiRoleOverride; // Permite al docente visualizar la UI como estudiante

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Helper para extraer una lista de cursos desde diferentes formas de payload
  List<Map<String, dynamic>> _extractCoursesList(dynamic payload) {
    try {
      if (payload == null) return [];

      // Si el payload es un String que contiene JSON, intentar decodificar y reintentar
      if (payload is String) {
        final trimmed = payload.trim();
        if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
          try {
            final decoded = jsonDecode(trimmed);
            return _extractCoursesList(decoded);
          } catch (_) {}
        }
        return [];
      }

      // Si ya es una lista
      if (payload is List) {
        print('🔎 Payload es List de tamaño: ${payload.length}');
        // Si la lista contiene mapas
        if (payload.isNotEmpty && payload.first is Map) {
          return List<Map<String, dynamic>>.from(payload.map((e) => Map<String, dynamic>.from(e as Map)));
        }
        // Intentar decodificar elementos string que sean JSON
        final decodedElements = payload
            .whereType<String>()
            .map((s) {
              try {
                return jsonDecode(s);
              } catch (_) {
                return null;
              }
            })
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        if (decodedElements.isNotEmpty) {
          print('✅ Lista decodificada desde elementos String con ${decodedElements.length} elementos');
          return decodedElements;
        }
        return [];
      }

      // Si es un mapa, intentar varias llaves comunes y estructuras anidadas
      if (payload is Map) {
        final map = Map<String, dynamic>.from(payload);
        print('🔎 Payload es Map con llaves: ${map.keys.toList()}');

        // Preferencias de llaves posibles
        final keysCandidates = [
          'cursos', 'items', 'result', 'results', 'data', 'lista', 'ofertas', 'courses', 'cursosPersonas', 'listaCursos'
        ];

        // 1) Chequeo directo: alguna key candidata es lista
        for (final k in keysCandidates) {
          final v = map[k];
          if (v == null) continue;

          // Si el valor es String con JSON, decodificar y reintentar
          if (v is String) {
            final t = v.trim();
            if (t.startsWith('[') || t.startsWith('{')) {
              try {
                final dv = jsonDecode(t);
                final extracted = _extractCoursesList(dv);
                if (extracted.isNotEmpty) {
                  print('✅ Lista decodificada desde String en "$k" con ${extracted.length} elementos');
                  return extracted;
                }
              } catch (_) {}
            }
          }

          if (v is List) {
            if (v.isNotEmpty && v.first is Map) {
              print('✅ Lista encontrada en key "$k" con ${v.length} elementos');
              return List<Map<String, dynamic>>.from(v.map((e) => Map<String, dynamic>.from(e as Map)));
            }
            // Intentar decodificar elementos String
            final decodedElements = v
                .whereType<String>()
                .map((s) {
                  try {
                    return jsonDecode(s);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            if (decodedElements.isNotEmpty) {
              print('✅ Lista decodificada desde Strings en "$k" con ${decodedElements.length} elementos');
              return decodedElements;
            }
          }

          // 2) Chequeo anidado: alguna key candidata es MAPA que contiene listas/strings JSON en llaves candidatas
          if (v is Map) {
            final inner = Map<String, dynamic>.from(v);
            for (final innerKey in keysCandidates) {
              final innerVal = inner[innerKey];

              if (innerVal is String) {
                final t = innerVal.trim();
                if (t.startsWith('[') || t.startsWith('{')) {
                  try {
                    final dv = jsonDecode(t);
                    final extracted = _extractCoursesList(dv);
                    if (extracted.isNotEmpty) {
                      print('✅ Lista decodificada en "$k"["$innerKey"] con ${extracted.length} elementos');
                      return extracted;
                    }
                  } catch (_) {}
                }
              }

              if (innerVal is List) {
                if (innerVal.isNotEmpty && innerVal.first is Map) {
                  print('✅ Lista encontrada en "$k"["$innerKey"] con ${innerVal.length} elementos');
                  return List<Map<String, dynamic>>.from(innerVal.map((e) => Map<String, dynamic>.from(e as Map)));
                }
                final decodedElements = innerVal
                    .whereType<String>()
                    .map((s) {
                      try {
                        return jsonDecode(s);
                      } catch (_) {
                        return null;
                      }
                    })
                    .whereType<Map>()
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList();
                if (decodedElements.isNotEmpty) {
                  print('✅ Lista decodificada desde Strings en "$k"["$innerKey"] con ${decodedElements.length} elementos');
                  return decodedElements;
                }
              }
            }
          }
        }

        // 3) Algunas APIs anidan data dentro de data (o como String JSON)
        if (map['data'] is String) {
          final t = (map['data'] as String).trim();
          if (t.startsWith('[') || t.startsWith('{')) {
            try {
              final dv = jsonDecode(t);
              final extracted = _extractCoursesList(dv);
              if (extracted.isNotEmpty) {
                print('✅ Lista decodificada en data (String) con ${extracted.length} elementos');
                return extracted;
              }
            } catch (_) {}
          }
        }

        if (map['data'] is Map) {
          final inner = Map<String, dynamic>.from(map['data']);
          for (final k in keysCandidates) {
            final v = inner[k];
            if (v is List) {
              if (v.isNotEmpty && v.first is Map) {
                print('✅ Lista encontrada en data["$k"] con ${v.length} elementos');
                return List<Map<String, dynamic>>.from(v.map((e) => Map<String, dynamic>.from(e as Map)));
              }
              final decodedElements = v
                  .whereType<String>()
                  .map((s) {
                    try {
                      return jsonDecode(s);
                    } catch (_) {
                      return null;
                    }
                  })
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
              if (decodedElements.isNotEmpty) {
                print('✅ Lista decodificada desde Strings en data["$k"] con ${decodedElements.length} elementos');
                return decodedElements;
              }
            } else if (v is String) {
              final t = v.trim();
              if (t.startsWith('[') || t.startsWith('{')) {
                try {
                  final dv = jsonDecode(t);
                  final extracted = _extractCoursesList(dv);
                  if (extracted.isNotEmpty) {
                    print('✅ Lista decodificada en data["$k"] con ${extracted.length} elementos');
                    return extracted;
                  }
                } catch (_) {}
              }
            } else if (v is Map) {
              final deeper = Map<String, dynamic>.from(v);
              for (final dk in keysCandidates) {
                final dv = deeper[dk];
                if (dv is List) {
                  if (dv.isNotEmpty && dv.first is Map) {
                    print('✅ Lista encontrada en data["$k"]["$dk"] con ${dv.length} elementos');
                    return List<Map<String, dynamic>>.from(dv.map((e) => Map<String, dynamic>.from(e as Map)));
                  }
                  final decodedElements = dv
                      .whereType<String>()
                      .map((s) {
                        try {
                          return jsonDecode(s);
                        } catch (_) {
                          return null;
                        }
                      })
                      .whereType<Map>()
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList();
                  if (decodedElements.isNotEmpty) {
                    print('✅ Lista decodificada desde Strings en data["$k"]["$dk"] con ${decodedElements.length} elementos');
                    return decodedElements;
                  }
                } else if (dv is String) {
                  final t = dv.trim();
                  if (t.startsWith('[') || t.startsWith('{')) {
                    try {
                      final dd = jsonDecode(t);
                      final ex = _extractCoursesList(dd);
                      if (ex.isNotEmpty) {
                        print('✅ Lista decodificada en data["$k"]["$dk"]');
                        return ex;
                      }
                    } catch (_) {}
                  }
                }
              }
            }
          }
        }

        // 4) Fallback: buscar cualquier valor que sea List<Map> o String JSON que contenga lista de mapas
        for (final entry in map.entries) {
          final val = entry.value;
          if (val is List && val.isNotEmpty && val.first is Map) {
            print('✅ Lista inferida en key "${entry.key}" con ${val.length} elementos');
            return List<Map<String, dynamic>>.from(val.map((e) => Map<String, dynamic>.from(e as Map)));
          }
          if (val is List) {
            final decodedElements = val
                .whereType<String>()
                .map((s) {
                  try {
                    return jsonDecode(s);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            if (decodedElements.isNotEmpty) {
              print('✅ Lista inferida decodificada en "${entry.key}" con ${decodedElements.length} elementos');
              return decodedElements;
            }
          }
          if (val is String) {
            final t = val.trim();
            if (t.startsWith('[') || t.startsWith('{')) {
              try {
                final dv = jsonDecode(t);
                final ex = _extractCoursesList(dv);
                if (ex.isNotEmpty) {
                  print('✅ Lista decodificada inferida en "${entry.key}" con ${ex.length} elementos');
                  return ex;
                }
              } catch (_) {}
            }
          }
          if (val is Map) {
            final inner = Map<String, dynamic>.from(val);
            for (final innerEntry in inner.entries) {
              final innerVal = innerEntry.value;
              if (innerVal is List && innerVal.isNotEmpty && innerVal.first is Map) {
                print('✅ Lista inferida en "${entry.key}"->"${innerEntry.key}" con ${innerVal.length} elementos');
                return List<Map<String, dynamic>>.from(innerVal.map((e) => Map<String, dynamic>.from(e as Map)));
              }
              if (innerVal is List) {
                final decodedElements = innerVal
                    .whereType<String>()
                    .map((s) {
                      try {
                        return jsonDecode(s);
                      } catch (_) {
                        return null;
                      }
                    })
                    .whereType<Map>()
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList();
                if (decodedElements.isNotEmpty) {
                  print('✅ Lista inferida decodificada en "${entry.key}"->"${innerEntry.key}" con ${decodedElements.length} elementos');
                  return decodedElements;
                }
              }
              if (innerVal is String) {
                final t = innerVal.trim();
                if (t.startsWith('[') || t.startsWith('{')) {
                  try {
                    final dv = jsonDecode(t);
                    final ex = _extractCoursesList(dv);
                    if (ex.isNotEmpty) {
                      print('✅ Lista decodificada inferida en "${entry.key}"->"${innerEntry.key}" con ${ex.length} elementos');
                      return ex;
                    }
                  } catch (_) {}
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Error extrayendo lista de cursos: $e');
    }
    print('⚠️ No se pudo extraer lista de cursos del payload');
    return [];
  }

  // Función para mapear los datos de la API al formato esperado por la UI
  Map<String, dynamic> _mapCourseData(Map<String, dynamic> apiCourse) {
    // Verificar si es del endpoint cursosPersonas (estructura con idMatricula)
    if (apiCourse.containsKey('idMatricula')) {
      return {
        'id': apiCourse['idCurso']?.toString() ?? apiCourse['id']?.toString(),
        'nombre': (apiCourse['nombre'] ?? apiCourse['nombre_curso'] ?? apiCourse['titulo'] ?? 'Sin nombre').toString(),
        'codigo': (apiCourse['codigo'] ?? apiCourse['idCurso'] ?? apiCourse['id'] ?? 'N/A').toString(),
        'duracion': apiCourse['duracion'],
        'temario': (apiCourse['temario'] ?? '').toString(),
        'tipo_curso': (apiCourse['tipo'] ?? apiCourse['tipo_curso'] ?? '').toString(),
        // Nuevos campos para enlazar endpoints por oferta y matrícula
        'idOferta': apiCourse['idOferta']?.toString(),
        'idMatricula': apiCourse['idMatricula']?.toString(),
        // Atributos de UI
        'color': Colors.blue,
        'profesor': 'Por asignar',
        'creditos': 3,
        'semestre': 'Actual',
        'progreso': 0,
      };
    }

    // Mapeo para otros endpoints (ej. /api/cursos y /api/ofertaCursos/docente)
    return {
      'id': apiCourse['id']?.toString() ?? apiCourse['idCurso']?.toString(),
      // Para cursos de docente, buscar el nombre en la estructura anidada 'curso'
      'nombre': _extractCourseName(apiCourse),
      'codigo': (apiCourse['codigo'] ?? apiCourse['codigo_curso'] ?? apiCourse['id'] ?? apiCourse['idCurso'] ?? 'N/A').toString(),
      'duracion': apiCourse['duracion'],
      'temario': (apiCourse['temario'] ?? '').toString(),
      'tipo_curso': (apiCourse['tipo_curso'] ?? apiCourse['tipo'] ?? '').toString(),
      'fechaInicio': (apiCourse['fecha_inicio_curso'] ?? apiCourse['fechaInicio'] ?? apiCourse['inicio'] ?? '').toString(),
      'fechaFin': (apiCourse['fecha_fin_curso'] ?? apiCourse['fechaFin'] ?? apiCourse['fin'] ?? '').toString(),
      'horario': (apiCourse['horario'] ?? '').toString(),
      'precio': (apiCourse['precio'] ?? '').toString(),
      'cupos': apiCourse['cupos'],
      'color': Colors.cyan,
      'progreso': 0,
      'totalEstudiantes': 0,
      'tareasPendientes': 0,
    };
  }

  // Helper para extraer el nombre del curso desde diferentes estructuras
  String _extractCourseName(Map<String, dynamic> apiCourse) {
    // Primero intentar campos directos
    if (apiCourse['nombre'] != null) return apiCourse['nombre'].toString();
    if (apiCourse['nombre_curso'] != null) return apiCourse['nombre_curso'].toString();
    if (apiCourse['titulo'] != null) return apiCourse['titulo'].toString();
    
    // Para cursos de docente, buscar en la estructura anidada 'curso'
    if (apiCourse['curso'] != null && apiCourse['curso'] is Map) {
      final cursoData = Map<String, dynamic>.from(apiCourse['curso']);
      if (cursoData['nombre_curso'] != null) return cursoData['nombre_curso'].toString();
      if (cursoData['nombre'] != null) return cursoData['nombre'].toString();
      if (cursoData['titulo'] != null) return cursoData['titulo'].toString();
    }
    
    return 'Sin nombre';
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

      // Determinar el tipo de usuario efectivo desde AuthService (si existe)
      final backendUserType = AuthService.userType;
      final effectiveUserType = backendUserType?.toLowerCase() ?? widget.userType.toLowerCase();
      print('Cargando cursos. userType (ruta): ${widget.userType} | userType (backend): ${backendUserType ?? 'desconocido'} | efectivo: $effectiveUserType');

      if (backendUserType != null && backendUserType.toLowerCase() != widget.userType.toLowerCase()) {
        print('⚠️ Desajuste de roles: ruta=${widget.userType} vs backend=$backendUserType');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aviso: tu rol real es "$backendUserType". Usando ese rol para cargar cursos.')),
          );
        }
      }

      Map<String, dynamic> result;

      // Solo considerar docente cuando el rol efectivo es exactamente 'docente'
      if (effectiveUserType != 'docente') {
        // ROL ESTUDIANTE (predeterminado)
        final userId = AuthService.userId;
        print('🔐 Auth userId: $userId');
        if (userId != null && userId.isNotEmpty) {
          print('🆔 Usando endpoint cursosPersonas con ID: $userId');
          result = await ApiService.getCoursesByPersonId(userId);
        } else {
          print('⚠️ No se encontró userId, usando endpoint por defecto /api/cursos');
          result = await ApiService.getCoursesByStudent();
        }
      } else {
        // ROL DOCENTE
        final userId = AuthService.userId;
        print('🔐 Auth docente userId: $userId');
        if (userId != null && userId.isNotEmpty) {
          print('👨‍🏫 Usando endpoint ofertaCursos/docente con ID: $userId');
          result = await ApiService.getTeacherCoursesByPersonId(userId);
        } else {
          print('❌ No se encontró idPersona para docente; no se permitirá cargar cursos de estudiante');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se puede cargar cursos de docente: falta idPersona')),
            );
          }
          setState(() { _isLoading = false; });
          return;
        }
      }

      print('Resultado de la API (success=${result['success']}): ${result['data']?.runtimeType}');

      if (mounted) {
        if (result['success'] == true) {
          final raw = result['data'];
          var rawCourses = _extractCoursesList(raw);

          // Fallback: si eres estudiante y cursosPersonas no devuelve elementos, probar /api/cursos
          if (effectiveUserType == 'estudiante' && rawCourses.isEmpty) {
            print('🔁 Fallback: cursosPersonas vacío, intentando /api/cursos');
            final fallback = await ApiService.getCoursesByStudent();
            if (fallback['success'] == true) {
              final rawFallback = fallback['data'];
              final extractedFallback = _extractCoursesList(rawFallback);
              if (extractedFallback.isNotEmpty) {
                print('✅ Fallback cargó ${extractedFallback.length} cursos');
                rawCourses = extractedFallback;
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mostrando catálogo general de cursos')),
                  );
                }
              } else {
                print('⚠️ Fallback /api/cursos también vacío');
              }
            } else {
              print('⚠️ Fallback /api/cursos falló: ${fallback['message']}');
            }
          }

          // Fallback: si eres docente y /api/cursos/docente no devuelve elementos
          if (effectiveUserType == 'docente' && rawCourses.isEmpty) {
            print('ℹ️ Docente sin cursos asignados; no se mostrará catálogo de estudiante por políticas de rol');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No tienes cursos asignados como docente.')),
              );
            }
          }

          final mappedCourses = rawCourses.map((course) => _mapCourseData(course)).toList();

          setState(() {
            _courses = mappedCourses;
            _currentCourse = _courses.isNotEmpty ? _courses.first : null;
            _isLoading = false;
          });
          print('✅ Cursos cargados: ${_courses.length}');

          if (_courses.isEmpty) {
            final keysInfo = (raw is Map) ? raw.keys.join(', ') : 'payload no es Map';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se encontraron cursos. Llaves en payload: $keysInfo')),
            );
          }
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
      print('Error al cargar cursos: $e');
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
      final courseId = course['id']?.toString();
      final idOfertaCurso = course['idOferta']?.toString();
      if ((courseId == null || courseId.isEmpty) && (idOfertaCurso == null || idOfertaCurso.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró identificador del curso (id o idOferta).')),
        );
        return;
      }

      // Pre-cargar módulos y contenido de apoyo por idOferta si disponible
      List<Map<String, dynamic>> modules = [];
      List<Map<String, dynamic>> supportContent = [];
      final idOferta = course['idOferta']?.toString();
      if (idOferta != null && idOferta.isNotEmpty) {
        final modulesResult = await ApiService.getModulesByOffer(idOferta);
        if (modulesResult['success'] == true) {
          final raw = modulesResult['data'];
          if (raw is List) {
            modules = List<Map<String, dynamic>>.from(raw.map((m) => {
                      'title': (m['nombre'] ?? m['titulo'] ?? 'Módulo').toString(),
                      'description': (m['descripcion'] ?? '').toString(),
                      'duration': (m['duracion'] ?? '').toString(),
                      'completed': false,
                    }));
          }
        }

        final contentResult = await ApiService.getSupportContentByOffer(idOferta);
        if (contentResult['success'] == true) {
          final raw = contentResult['data'];
          if (raw is List) {
            supportContent = List<Map<String, dynamic>>.from(raw.map((c) => {
                      'id': (c['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
                      'title': (c['titulo'] ?? c['nombre'] ?? 'Recurso').toString(),
                      'type': (c['tipo'] ?? 'Archivo').toString(),
                      'size': (c['tamano'] ?? '').toString(),
                      'downloads': (c['descargas'] ?? 0),
                      'filePath': (c['archivo'] ?? c['url'] ?? '').toString(),
                      'uploadDate': (c['fechaSubida'] ?? c['fecha'] ?? '' ).toString(),
                      'description': (c['descripcion'] ?? '').toString(),
                      'tags': List<String>.from((c['tags'] ?? []) as List? ?? []),
                    }));
          }
        }
      }

      final courseDetails = (idOfertaCurso != null && idOfertaCurso.isNotEmpty)
          ? await (() async {
              debugPrint('🔗 Detalle vía oferta: idOferta=$idOfertaCurso');
              final res = await ApiService.getOfferCourseDetails(idOfertaCurso);
              debugPrint('✅ Respuesta detalle oferta (success=${res['success']})');
              return res;
            })()
          : await (() async {
              debugPrint('🔗 Detalle vía courseId: id=$courseId');
              final res = await ApiService.getCourseDetails(courseId!);
              debugPrint('✅ Respuesta detalle curso (success=${res['success']})');
              return res;
            })();
      if (!mounted) return;

      // Unir información del curso con datos precargados
      final Map<String, dynamic> mergedCourseInfo = {
        ...course,
        ...(courseDetails['data'] is Map
            ? Map<String, dynamic>.from(courseDetails['data'])
            : {}),
        'modulesData': modules,
        'supportContentData': supportContent,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailScreen(
            courseInfo: mergedCourseInfo,
            // Usar la modalidad de visualización (override) si está activa
            userType: (_uiRoleOverride ?? widget.userType),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error abriendo curso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modalidad de visualización: permite a un docente ver la interfaz como estudiante
    final displayUserType = (_uiRoleOverride ?? widget.userType);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'FUNED Academia de Belleza',
        actions: [
          if (widget.userType.toLowerCase() == 'docente')
            IconButton(
              tooltip: _uiRoleOverride == 'estudiante' ? 'Ver como Docente' : 'Ver como Estudiante',
              icon: Icon(_uiRoleOverride == 'estudiante' ? Icons.switch_left : Icons.switch_right),
              onPressed: () {
                setState(() {
                  _uiRoleOverride = _uiRoleOverride == 'estudiante' ? null : 'estudiante';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _uiRoleOverride == 'estudiante'
                          ? 'Viendo interfaz como Estudiante'
                          : 'Volviendo a interfaz de Docente',
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                // Inicio
                HomeContent(
                  userName: widget.userName,
                  userType: displayUserType,
                  currentCourse: _currentCourse,
                  onViewCourse: _verCurso,
                ),
                // Cursos
                CoursesSection(
                  courses: _courses,
                  onViewCourse: _verCurso,
                  userType: displayUserType,
                ),
                // Calendario
                CalendarSection(
                  userType: displayUserType,
                  userName: widget.userName,
                ),
                // Perfil
                ProfileSection(
                  userType: displayUserType,
                  userName: widget.userName,
                  userEmail: AuthService.userEmail ?? '',
                  onLogout: _cerrarSesion,
                ),
                // Admin (eliminado para docentes): No se agrega la pantalla admin aquí
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        userType: displayUserType,
      ),
    );
  }
}