import 'package:flutter/material.dart';
import 'services/auth_service.dart';

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

  // Datos del curso (esto podría venir de una API o base de datos)
  final Map<String, dynamic> cursoInfo = {
    'nombre': 'Corte y Peinado Profesional',
    'codigo': 'BELLEZA-101',
    'profesor': 'Lic. María González',
    'creditos': 4,
    'semestre': '2024-1',
    'descripcion': 'Curso completo de técnicas de corte y peinado para diferentes tipos de cabello.',
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _verCurso() {
    // Aquí se navegaría a la pantalla de detalles del curso
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Información del Curso',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre: ${cursoInfo['nombre']}'),
              Text('Código: ${cursoInfo['codigo']}'),
              Text('Profesor: ${cursoInfo['profesor']}'),
              Text('Créditos: ${cursoInfo['creditos']}'),
              Text('Semestre: ${cursoInfo['semestre']}'),
              SizedBox(height: 10),
              Text('Descripción: ${cursoInfo['descripcion']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: Color(0xFF2B1A7F)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _cerrarSesion() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Cerrar Sesión',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Cerrar sesión real
                await AuthService.logout();
                
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/welcome',
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Color(0xFF2B1A7F)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildCoursesContent();
      case 2:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de bienvenida
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido, ${widget.userName}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tipo de usuario: ${widget.userType == 'docente' ? 'Docente' : 'Estudiante'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Tarjeta del curso actual
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Curso Actual',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    Icon(
                      Icons.school,
                      color: Color(0xFF2B1A7F),
                      size: 30,
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  cursoInfo['nombre'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Código: ${cursoInfo['codigo']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Profesor: ${cursoInfo['profesor']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verCurso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2B1A7F),
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Ver todo sobre el curso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Tarjeta de estadísticas rápidas
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Asignaciones', '5', Icons.assignment),
                    _buildStatItem('Exámenes', '2', Icons.quiz),
                    _buildStatItem('Progreso', '75%', Icons.trending_up),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(0xFF2B1A7F),
          size: 30,
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B1A7F),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesContent() {
    if (widget.userType == 'docente') {
      return _buildTeacherCoursesContent();
    } else {
      return _buildStudentCoursesContent();
    }
  }

  Widget _buildStudentCoursesContent() {
    // Lista de cursos para estudiantes
    final List<Map<String, dynamic>> cursos = [
      {
        'nombre': 'Corte y Peinado Profesional',
        'codigo': 'BELLEZA-101',
        'profesor': 'Lic. María González',
        'creditos': 4,
        'progreso': 75,
        'color': Colors.pink,
      },
      {
        'nombre': 'Maquillaje Artístico',
        'codigo': 'BELLEZA-102',
        'profesor': 'Lic. Ana Rodríguez',
        'creditos': 3,
        'progreso': 60,
        'color': Colors.purple,
      },
      {
        'nombre': 'Coloración y Tintes',
        'codigo': 'BELLEZA-103',
        'profesor': 'Lic. Carmen López',
        'creditos': 4,
        'progreso': 90,
        'color': Colors.orange,
      },
      {
        'nombre': 'Manicure y Pedicure',
        'codigo': 'BELLEZA-104',
        'profesor': 'Lic. Patricia Silva',
        'creditos': 3,
        'progreso': 45,
        'color': Colors.red,
      },
      {
        'nombre': 'Tratamientos Faciales',
        'codigo': 'BELLEZA-105',
        'profesor': 'Lic. Rosa Martínez',
        'creditos': 3,
        'progreso': 30,
        'color': Colors.teal,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Cursos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ...cursos.map((curso) => Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            curso['nombre'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B1A7F),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Código: ${curso['codigo']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Profesor: ${curso['profesor']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                                         Container(
                       padding: EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: curso['color'].withOpacity(0.1),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Icon(
                         _getCourseIcon(curso['codigo']),
                         color: curso['color'],
                         size: 30,
                       ),
                     ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso: ${curso['progreso']}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    Text(
                      '${curso['creditos']} créditos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: curso['progreso'] / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(curso['color']),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // Aquí se navegaría a los detalles del curso
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            'Detalles del Curso',
                            style: TextStyle(color: Color(0xFF2B1A7F)),
                          ),
                          content: Text('Aquí se mostrarían los detalles completos del curso ${curso['nombre']}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cerrar',
                                style: TextStyle(color: Color(0xFF2B1A7F)),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: curso['color'],
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ver detalles',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTeacherCoursesContent() {
    // Lista de cursos para docentes
    final List<Map<String, dynamic>> cursosDocente = [
      {
        'nombre': 'Corte y Peinado Profesional',
        'codigo': 'BELLEZA-101',
        'estudiantes': 25,
        'horario': 'Lunes y Miércoles 9:00 AM',
        'color': Colors.pink,
      },
      {
        'nombre': 'Maquillaje Artístico',
        'codigo': 'BELLEZA-102',
        'estudiantes': 18,
        'horario': 'Martes y Jueves 2:00 PM',
        'color': Colors.purple,
      },
      {
        'nombre': 'Coloración y Tintes',
        'codigo': 'BELLEZA-103',
        'estudiantes': 22,
        'horario': 'Viernes 10:00 AM',
        'color': Colors.orange,
      },
      {
        'nombre': 'Manicure y Pedicure',
        'codigo': 'BELLEZA-104',
        'estudiantes': 15,
        'horario': 'Sábados 9:00 AM',
        'color': Colors.red,
      },
      {
        'nombre': 'Tratamientos Faciales',
        'codigo': 'BELLEZA-105',
        'estudiantes': 12,
        'horario': 'Lunes y Viernes 4:00 PM',
        'color': Colors.teal,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Cursos - Panel de Docente',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ...cursosDocente.map((curso) => Container(
            margin: EdgeInsets.only(bottom: 15),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            curso['nombre'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B1A7F),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Código: ${curso['codigo']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Estudiantes: ${curso['estudiantes']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Horario: ${curso['horario']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: curso['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCourseIcon(curso['codigo']),
                        color: curso['color'],
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Gestionar Estudiantes',
                                  style: TextStyle(color: Color(0xFF2B1A7F)),
                                ),
                                content: Text('Aquí podrías ver y gestionar la lista de estudiantes del curso ${curso['nombre']}'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Cerrar',
                                      style: TextStyle(color: Color(0xFF2B1A7F)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.people),
                        label: Text('Estudiantes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: curso['color'],
                          minimumSize: Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Gestionar Contenido',
                                  style: TextStyle(color: Color(0xFF2B1A7F)),
                                ),
                                content: Text('Aquí podrías gestionar el contenido y materiales del curso ${curso['nombre']}'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Cerrar',
                                      style: TextStyle(color: Color(0xFF2B1A7F)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Contenido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          minimumSize: Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (widget.userType == 'docente') {
      return _buildTeacherProfileContent();
    } else {
      return _buildStudentProfileContent();
    }
  }

  Widget _buildStudentProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta de información del usuario
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2B1A7F),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Estudiante',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat('Cursos', '3'),
                    _buildProfileStat('Asignaciones', '12'),
                    _buildProfileStat('Promedio', '85%'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Tarjeta de opciones
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 15),
                _buildProfileOption(
                  'Editar Perfil',
                  Icons.edit,
                  () {
                    // Aquí se navegaría a editar perfil
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de editar perfil en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Configuración',
                  Icons.settings,
                  () {
                    // Aquí se navegaría a configuración
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de configuración en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Ayuda y Soporte',
                  Icons.help,
                  () {
                    // Aquí se navegaría a ayuda
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de ayuda en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Acerca de',
                  Icons.info,
                  () {
                    // Aquí se navegaría a acerca de
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            'Acerca de FUNED',
                            style: TextStyle(color: Color(0xFF2B1A7F)),
                          ),
                          content: Text('FUNED Academia de Belleza - Aplicación móvil para estudiantes y docentes de belleza. Versión 1.0.0'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cerrar',
                                style: TextStyle(color: Color(0xFF2B1A7F)),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Botón de cerrar sesión
          ElevatedButton(
            onPressed: _cerrarSesion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Tarjeta de información del docente
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2B1A7F),
                  child: Icon(
                    Icons.school,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Docente',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat('Cursos', '5'),
                    _buildProfileStat('Estudiantes', '92'),
                    _buildProfileStat('Horas', '120'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Tarjeta de opciones del docente
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel de Docente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 15),
                _buildProfileOption(
                  'Gestionar Cursos',
                  Icons.school,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de gestión de cursos en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Calificaciones',
                  Icons.grade,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de calificaciones en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Asistencia',
                  Icons.checklist,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de asistencia en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Materiales',
                  Icons.folder,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de materiales en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Configuración',
                  Icons.settings,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de configuración en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Ayuda y Soporte',
                  Icons.help,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Función de ayuda en desarrollo')),
                    );
                  },
                ),
                _buildProfileOption(
                  'Acerca de',
                  Icons.info,
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            'Acerca de FUNED',
                            style: TextStyle(color: Color(0xFF2B1A7F)),
                          ),
                          content: Text('FUNED Academia de Belleza - Panel de docente. Versión 1.0.0'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cerrar',
                                style: TextStyle(color: Color(0xFF2B1A7F)),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Botón de cerrar sesión
          ElevatedButton(
            onPressed: _cerrarSesion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B1A7F),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  IconData _getCourseIcon(String codigo) {
    switch (codigo) {
      case 'BELLEZA-101':
        return Icons.content_cut; // Corte y peinado
      case 'BELLEZA-102':
        return Icons.face; // Maquillaje
      case 'BELLEZA-103':
        return Icons.color_lens; // Coloración
      case 'BELLEZA-104':
        return Icons.brush; // Manicure
      case 'BELLEZA-105':
        return Icons.spa; // Tratamientos faciales
      default:
        return Icons.school;
    }
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Color(0xFF2B1A7F),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFF2B1A7F),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'FUNED Academia de Belleza',
          style: TextStyle(
            color: Color(0xFF2B1A7F),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Color(0xFF2B1A7F),
            ),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2B1A7F),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Cursos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
} 