import 'package:flutter/material.dart';

// Servicios
import 'services/api_service.dart';
import 'services/auth_service.dart';

// Pantallas
import 'CourseDetailScreen.dart';
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
  _HomeScreenState createState() => _HomeScreenState();
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

    // Mapeo original para otros endpoints (ofertas/cursos)
    return {
      'id': apiCourse['id'],
      'nombre': apiCourse['nombre_curso']?.toString() ?? 'Sin nombre',
      'codigo': apiCourse['codigo']?.toString() ?? apiCourse['id']?.toString() ?? 'N/A',
      'duracion': apiCourse['duracion'],
      'temario': apiCourse['temario']?.toString() ?? '',
      'tipo_curso': apiCourse['tipo_curso']?.toString() ?? '',
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

    print('Cargando cursos para tipo de usuario: ${widget.userType}');
    
    Map<String, dynamic> result;
    
    if (widget.userType.toLowerCase() == 'estudiante') {
      // Usar el nuevo endpoint con ID de persona si está disponible
      final userId = AuthService.userId;
      if (userId != null && userId.isNotEmpty) {
        print('🆔 Usando endpoint cursosPersonas con ID: $userId');
        result = await ApiService.getCoursesByPersonId(userId);
      } else {
        print('⚠️ No se encontró userId, usando endpoint por defecto');
        result = await ApiService.getCoursesByStudent();
      }
    } else {
      result = await ApiService.getCoursesByTeacher();
    }
    
    print('Resultado de la API: $result');
    
    if (mounted) {
      if (result['success'] == true) {
        // Mapear los datos de la API al formato esperado
        List<Map<String, dynamic>> rawCourses;
        
        // Verificar si la respuesta tiene estructura de cursosPersonas
        if (result['data'] is Map && result['data']['cursos'] != null) {
          rawCourses = List<Map<String, dynamic>>.from(result['data']['cursos'] ?? []);
        } else {
          rawCourses = List<Map<String, dynamic>>.from(result['data'] ?? []);
        }
        
        final mappedCourses = rawCourses.map((course) => _mapCourseData(course)).toList();
        
        setState(() {
          _courses = mappedCourses;
          _currentCourse = _courses.isNotEmpty ? _courses.first : null;
          _isLoading = false;
        });
        print('Cursos cargados: ${_courses.length}');
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
  
    final courseDetails = await ApiService.getCourseDetails(courseId);
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