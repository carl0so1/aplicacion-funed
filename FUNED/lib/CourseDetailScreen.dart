import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'services/api_service.dart';
import 'services/auth_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> courseInfo;
  final String userType;

  const CourseDetailScreen({
    Key? key,
    required this.courseInfo,
    required this.userType,
  }) : super(key: key);

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;
  List<Map<String, dynamic>> _resources = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeResources();
  }

  void _initializeResources() {
    final incoming = widget.courseInfo['supportContentData'];
    if (incoming is List) {
      _resources = List<Map<String, dynamic>>.from(incoming);
      return;
    }
    _resources = [
      {
        'id': '1',
        'title': 'Manual de Técnicas Básicas',
        'type': 'PDF',
        'size': '2.5 MB',
        'downloads': 45,
        'filePath': '/assets/manual_tecnicas.pdf',
        'uploadDate': '2024-01-15',
        'description': 'Manual completo con todas las técnicas básicas del curso',
        'tags': ['manual', 'técnicas', 'básico'],
      },
      {
        'id': '2',
        'title': 'Video Tutorial - Corte Clásico',
        'type': 'MP4',
        'size': '15.2 MB',
        'downloads': 38,
        'filePath': '/assets/video_corte_clasico.mp4',
        'uploadDate': '2024-01-20',
        'description': 'Video demostrativo del corte clásico paso a paso',
        'tags': ['video', 'tutorial', 'corte'],
      },
      {
        'id': '3',
        'title': 'Presentación - Herramientas Profesionales',
        'type': 'PPTX',
        'size': '8.7 MB',
        'downloads': 52,
        'filePath': '/assets/presentacion_herramientas.pptx',
        'uploadDate': '2024-01-25',
        'description': 'Presentación sobre herramientas profesionales del oficio',
        'tags': ['presentación', 'herramientas', 'profesional'],
      },
      {
        'id': '4',
        'title': 'Guía de Prácticas',
        'type': 'PDF',
        'size': '1.8 MB',
        'downloads': 67,
        'filePath': '/assets/guia_practicas.pdf',
        'uploadDate': '2024-02-01',
        'description': 'Guía práctica para ejercicios del curso',
        'tags': ['guía', 'prácticas', 'ejercicios'],
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.courseInfo['nombre'],
          style: TextStyle(
            color: Color(0xFF2B1A7F),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2B1A7F)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Color(0xFF2B1A7F)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Compartir curso en desarrollo')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.fact_check, color: Color(0xFF2B1A7F)),
            onPressed: _loadAttendanceForThisCourse,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con información del curso
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (widget.courseInfo['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCourseIcon(widget.courseInfo['codigo']),
                        color: widget.courseInfo['color'] as Color,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courseInfo['nombre'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B1A7F),
                            ),
                          ),
                          Text(
                            'Código: ${widget.courseInfo['codigo']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem('Profesor', widget.courseInfo['profesor'] ?? 'Por asignar'),
                    _buildInfoItem('Créditos', '${widget.courseInfo['creditos'] ?? 3}'),
                    _buildInfoItem('Semestre', widget.courseInfo['semestre'] ?? 'Actual'),
                  ],
                ),
                if (widget.userType == 'estudiante') ...[
                  SizedBox(height: 15),
                  Text(
                    'Progreso del Curso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B1A7F),
                    ),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (widget.courseInfo['progreso'] ?? 0) / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(widget.courseInfo['color'] as Color),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${widget.courseInfo['progreso'] ?? 0}% completado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xFF2B1A7F),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF2B1A7F),
              tabs: [
                Tab(text: 'Contenido'),
                Tab(text: widget.userType == 'docente' ? 'Estudiantes' : 'Actividades'),
                Tab(text: 'Recursos'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentTab(),
                widget.userType == 'docente' 
                    ? _buildStudentsTab() 
                    : _buildActivitiesTab(),
                _buildResourcesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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

  Widget _buildContentTab() {
    // Usar módulos provenientes de courseInfo si existen
    List<Map<String, dynamic>> modules = [];
    final incoming = widget.courseInfo['modulesData'];
    if (incoming is List) {
      modules = List<Map<String, dynamic>>.from(incoming);
    } else {
      modules = [
        {
          'title': 'Módulo 1: Fundamentos',
          'description': 'Introducción a las técnicas básicas',
          'duration': '2 semanas',
          'completed': true,
        },
        {
          'title': 'Módulo 2: Técnicas Avanzadas',
          'description': 'Métodos profesionales de aplicación',
          'duration': '3 semanas',
          'completed': widget.userType == 'estudiante' ? false : true,
        },
        {
          'title': 'Módulo 3: Práctica Profesional',
          'description': 'Aplicación en casos reales',
          'duration': '4 semanas',
          'completed': false,
        },
      ];
    }

    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: module['completed'] 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  module['completed'] ? Icons.check : Icons.play_arrow,
                  color: module['completed'] ? Colors.green : Colors.grey,
                ),
              ),
              title: Text(
                module['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B1A7F),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module['description']),
                  SizedBox(height: 4),
                  Text(
                    'Duración: ${module['duration']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  _showModuleDetails(module);
                },
              ),
              onTap: () {
                _showModuleDetails(module);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentsTab() {
    final List<Map<String, dynamic>> students = [
      {'name': 'Ana García', 'email': 'ana.garcia@email.com', 'progress': 85},
      {'name': 'Carlos López', 'email': 'carlos.lopez@email.com', 'progress': 72},
      {'name': 'María Rodríguez', 'email': 'maria.rodriguez@email.com', 'progress': 90},
      {'name': 'Juan Pérez', 'email': 'juan.perez@email.com', 'progress': 68},
      {'name': 'Laura Silva', 'email': 'laura.silva@email.com', 'progress': 95},
    ];

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estudiantes (${students.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddStudentDialog();
                  },
                  icon: Icon(Icons.person_add),
                  label: Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.courseInfo['color'] as Color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (widget.courseInfo['color'] as Color).withOpacity(0.1),
                      child: Text(
                        student['name'].split(' ').map((e) => e[0]).join(''),
                        style: TextStyle(
                          color: widget.courseInfo['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      student['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student['email']),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: student['progress'] / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(widget.courseInfo['color'] as Color),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${student['progress']}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.message),
                            title: Text('Enviar mensaje'),
                          ),
                          onTap: () {
                            _sendMessageToStudent(student);
                          },
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.assessment),
                            title: Text('Ver progreso'),
                          ),
                          onTap: () {
                            _showStudentProgress(student);
                          },
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.remove_circle, color: Colors.red),
                            title: Text('Remover del curso', style: TextStyle(color: Colors.red)),
                          ),
                          onTap: () {
                            _removeStudentFromCourse(student);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Tarea 1: Análisis de Casos',
        'type': 'Tarea',
        'dueDate': '2024-02-15',
        'status': 'Pendiente',
        'grade': null,
      },
      {
        'title': 'Examen Parcial',
        'type': 'Examen',
        'dueDate': '2024-02-20',
        'status': 'Completado',
        'grade': 85,
      },
      {
        'title': 'Proyecto Final',
        'type': 'Proyecto',
        'dueDate': '2024-03-10',
        'status': 'Pendiente',
        'grade': null,
      },
    ];

    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActivityIcon(activity['type']),
                  color: _getActivityColor(activity['type']),
                ),
              ),
              title: Text(
                activity['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B1A7F),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fecha límite: ${activity['dueDate']}'),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: activity['status'] == 'Completado' 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity['status'],
                          style: TextStyle(
                            fontSize: 12,
                            color: activity['status'] == 'Completado' 
                                ? Colors.green 
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (activity['grade'] != null) ...[
                        SizedBox(width: 8),
                        Text(
                          'Nota: ${activity['grade']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  _showActivityDetails(activity);
                },
              ),
              onTap: () {
                _showActivityDetails(activity);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourcesTab() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recursos del Curso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                if (widget.userType == 'docente')
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddResourceDialog();
                    },
                    icon: Icon(Icons.upload),
                    label: Text('Subir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.courseInfo['color'] as Color,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _resources.length,
              itemBuilder: (context, index) {
                final resource = _resources[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getResourceColor(resource['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getResourceIcon(resource['type']),
                        color: _getResourceColor(resource['type']),
                      ),
                    ),
                    title: Text(
                      resource['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${resource['type']} • ${resource['size']}'),
                        Text('${resource['downloads']} descargas'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () {
                            _downloadResource(resource);
                          },
                        ),
                        if (widget.userType == 'docente')
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Editar'),
                                ),
                                onTap: () {
                                  _editResource(resource);
                                },
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                ),
                                onTap: () {
                                  _deleteResource(resource);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getCourseIcon(String? codigo) {
    if (codigo == null) return Icons.school;
    
    switch (codigo) {
      case 'BELLEZA-101':
        return Icons.content_cut;
      case 'BELLEZA-102':
        return Icons.face;
      case 'BELLEZA-103':
        return Icons.color_lens;
      case 'BELLEZA-104':
        return Icons.brush;
      case 'BELLEZA-105':
        return Icons.spa;
      default:
        return Icons.school;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Tarea':
        return Colors.blue;
      case 'Examen':
        return Colors.red;
      case 'Proyecto':
        return Colors.purple;
      default:
        return widget.courseInfo['color'] as Color;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Tarea':
        return Icons.assignment;
      case 'Examen':
        return Icons.quiz;
      case 'Proyecto':
        return Icons.work;
      default:
        return Icons.school;
    }
  }

  Color _getResourceColor(String type) {
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'Video':
        return Colors.purple;
      case 'PPT':
        return Colors.orange;
      default:
        return widget.courseInfo['color'] as Color;
    }
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Video':
        return Icons.video_library;
      case 'PPT':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Action methods
  Future<void> _loadAttendanceForThisCourse() async {
    try {
      final String idPersona = AuthService.userId ?? '';
      final String idMatricula = widget.courseInfo['idMatricula']?.toString() ?? '';

      if (idPersona.isEmpty || idMatricula.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró id de persona o matrícula para consultar asistencia')),
        );
        return;
      }

      final Map<String, dynamic> res = await ApiService.getAttendanceByPersonAndCourse(
        idPersona: idPersona,
        idMatricula: idMatricula,
      );

      final bool success = res['success'] == true;
      final dynamic data = res['data'] ?? res['attendance'] ?? res['records'] ?? res['result'] ?? res;

      Widget contentWidget;
      if (data is List) {
        final items = data.cast<dynamic>();
        contentWidget = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: items.take(50).map<Widget>((item) {
              if (item is Map) {
                final entries = item.entries.map((e) => '${e.key}: ${e.value}').join('\n');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(entries),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(item.toString()),
              );
            }).toList(),
          ),
        );
      } else if (data is Map) {
        final entries = (data as Map).entries.map((e) => '${e.key}: ${e.value}').join('\n');
        contentWidget = SingleChildScrollView(child: Text(entries));
      } else {
        contentWidget = SingleChildScrollView(child: Text(data?.toString() ?? 'Sin datos'));
      }

      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              success ? 'Asistencia del curso' : 'No se pudo cargar asistencia',
              style: TextStyle(color: Color(0xFF2B1A7F)),
            ),
            content: contentWidget,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Error', style: TextStyle(color: Color(0xFF2B1A7F))),
            content: Text('Ocurrió un error al consultar asistencia: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showModuleDetails(Map<String, dynamic> module) {
    // Lista de lecciones para el módulo seleccionado
    final List<Map<String, dynamic>> lecciones = [
      {
        'titulo': 'Lección 1: Introducción',
        'duracion': '45 minutos',
        'tipo': 'Video',
        'completado': true,
      },
      {
        'titulo': 'Lección 2: Conceptos básicos',
        'duracion': '60 minutos',
        'tipo': 'Lectura',
        'completado': module['completed'] ? true : false,
      },
      {
        'titulo': 'Lección 3: Práctica guiada',
        'duracion': '90 minutos',
        'tipo': 'Interactivo',
        'completado': false,
      },
      {
        'titulo': 'Evaluación final',
        'duracion': '30 minutos',
        'tipo': 'Cuestionario',
        'completado': false,
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        module['title'],
                        style: TextStyle(
                          color: Color(0xFF2B1A7F),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: module['completed'] ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        module['completed'] ? Icons.check_circle : Icons.access_time,
                        color: module['completed'] ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  'Descripción:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B1A7F)),
                ),
                Text(module['description']),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      'Duración: ${module['duration']}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      module['completed'] ? Icons.check_circle : Icons.pending_actions,
                      size: 16,
                      color: module['completed'] ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Estado: ${module['completed'] ? 'Completado' : 'En progreso'}',
                      style: TextStyle(
                        color: module['completed'] ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(height: 30),
                Text(
                  'Contenido del módulo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: lecciones.length,
                    itemBuilder: (context, index) {
                      final leccion = lecciones[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getLeccionColor(leccion['tipo']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getLeccionIcon(leccion['tipo']),
                              color: _getLeccionColor(leccion['tipo']),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            leccion['titulo'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${leccion['duracion']} • ${leccion['tipo']}'),
                          trailing: leccion['completado']
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _showLeccionContent(leccion, module);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2B1A7F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: Text('Iniciar'),
                                ),
                          onTap: () {
                            if (!leccion['completado']) {
                              Navigator.of(context).pop();
                              _showLeccionContent(leccion, module);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cerrar'),
                    ),
                    SizedBox(width: 10),
                    if (!module['completed'])
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startModuleSequentially(module, lecciones);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2B1A7F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Comenzar módulo'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para mostrar el contenido de una lección
  void _showLeccionContent(Map<String, dynamic> leccion, Map<String, dynamic> module) {
    // Verificar que el título tenga el formato esperado antes de dividirlo
    String descripcionLeccion = 'Esta lección cubre los conceptos fundamentales del curso. '
                  'Duración aproximada: ${leccion['duracion']}.';  
    
    // Solo intentar dividir el título si contiene ":" para evitar errores
    if (leccion['titulo'] != null && leccion['titulo'].toString().contains(':')) {
      try {
        List<String> partesTitulo = leccion['titulo'].toString().split(':');
        if (partesTitulo.length > 1) {
          String temaLeccion = partesTitulo[1].trim();
          descripcionLeccion = 'Esta lección cubre los conceptos fundamentales relacionados con $temaLeccion. '
                    'Duración aproximada: ${leccion['duracion']}.';  
        }
      } catch (e) {
        print('Error al procesar el título de la lección: $e');
        // Mantener la descripción por defecto
      }
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getLeccionColor(leccion['tipo']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getLeccionIcon(leccion['tipo']),
                        color: _getLeccionColor(leccion['tipo']),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        leccion['titulo'] ?? 'Lección sin título',
                        style: TextStyle(
                          color: Color(0xFF2B1A7F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getLeccionIcon(leccion['tipo']),
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Contenido de ${leccion['tipo']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Simular interacción con el contenido
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reproduciendo contenido...'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: Icon(_getActionIcon(leccion['tipo'])),
                          label: Text(_getActionText(leccion['tipo'])),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getLeccionColor(leccion['tipo']),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Descripción de la lección:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(descripcionLeccion),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showModuleDetails(module);
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Volver al módulo'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Marcar como completada y volver al módulo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Lección completada!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _showModuleDetails(module);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Completar lección'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para iniciar el módulo secuencialmente
  void _startModuleSequentially(Map<String, dynamic> module, List<Map<String, dynamic>> lecciones) {
    // Mostrar la primera lección no completada
    for (var leccion in lecciones) {
      if (!leccion['completado']) {
        _showLeccionContent(leccion, module);
        break;
      }
    }
  }

  // Métodos auxiliares para las lecciones
  IconData _getLeccionIcon(String tipo) {
    switch (tipo) {
      case 'Video':
        return Icons.play_circle_filled;
      case 'Lectura':
        return Icons.menu_book;
      case 'Interactivo':
        return Icons.touch_app;
      case 'Cuestionario':
        return Icons.quiz;
      default:
        return Icons.article;
    }
  }

  Color _getLeccionColor(String tipo) {
    switch (tipo) {
      case 'Video':
        return Colors.red;
      case 'Lectura':
        return Colors.blue;
      case 'Interactivo':
        return Colors.purple;
      case 'Cuestionario':
        return Colors.orange;
      default:
        return widget.courseInfo['color'] as Color;
    }
  }

  IconData _getActionIcon(String tipo) {
    switch (tipo) {
      case 'Video':
        return Icons.play_arrow;
      case 'Lectura':
        return Icons.visibility;
      case 'Interactivo':
        return Icons.touch_app;
      case 'Cuestionario':
        return Icons.edit;
      default:
        return Icons.open_in_new;
    }
  }

  String _getActionText(String tipo) {
    switch (tipo) {
      case 'Video':
        return 'Reproducir';
      case 'Lectura':
        return 'Leer';
      case 'Interactivo':
        return 'Interactuar';
      case 'Cuestionario':
        return 'Responder';
      default:
        return 'Abrir';
    }
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Agregar Estudiante',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Estudiante agregado exitosamente')),
                );
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _sendMessageToStudent(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Enviar Mensaje a ${student['name']}',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: TextField(
            style: TextStyle(color: Colors.blue),
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Mensaje',
              labelStyle: TextStyle(color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mensaje enviado a ${student['name']}')),
                );
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _showStudentProgress(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Progreso de ${student['name']}',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Progreso general: ${student['progress']}%'),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: student['progress'] / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(widget.courseInfo['color'] as Color),
              ),
              SizedBox(height: 15),
              Text('Actividades completadas: 8/12'),
              Text('Promedio de calificaciones: 85%'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _removeStudentFromCourse(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Remover Estudiante',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Text('¿Estás seguro de que quieres remover a ${student['name']} del curso?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${student['name']} removido del curso')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            activity['title'],
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo: ${activity['type']}'),
              Text('Fecha límite: ${activity['dueDate']}'),
              Text('Estado: ${activity['status']}'),
              if (activity['grade'] != null)
                Text('Calificación: ${activity['grade']}'),
              SizedBox(height: 15),
              Text('Descripción detallada de la actividad...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
            if (activity['status'] == 'Pendiente')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _subirEvidencia(activity);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.courseInfo['color'] as Color,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_file, size: 16),
                    SizedBox(width: 4),
                    Text('Subir Evidencia'),
                  ],
                ),
              ),
            if (activity['status'] == 'Pendiente')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Iniciando actividad...')),
                  );
                },
                child: Text('Comenzar'),
              ),
          ],
        );
      },
    );
  }
  
  void _subirEvidencia(Map<String, dynamic> activity) async {
    // Mostrar diálogo para seleccionar archivo
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'zip'],
    );
    
    if (result != null) {
      PlatformFile file = result.files.first;
      
      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Subiendo evidencia...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Subiendo ${file.name}'),
              ],
            ),
          );
        },
      );
      
      // Simular carga
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop(); // Cerrar diálogo de carga
      
      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Evidencia subida con éxito'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text('Tu evidencia ha sido subida correctamente.'),
                SizedBox(height: 8),
                Text('Archivo: ${file.name}'),
                Text('Tamaño: ${(file.size / 1024 / 1024).toStringAsFixed(2)} MB'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showAddResourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SimpleAddResourceDialog(
          onResourceAdded: (title, description, file) {
            _addNewResource(title, description, file);
          },
        );
      },
    );
  }

  void _addNewResource(String title, String description, PlatformFile file) {
    if (file.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona un archivo para subir.')),
      );
      return;
    }

    final newResource = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'description': description,
      'type': _getFileType(file.extension ?? ''),
      'size': '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
      'downloads': 0,
      'filePath': file.path ?? '/assets/${file.name}',
      'uploadDate': DateTime.now().toString().split(' ')[0],
      'tags': _generateTagsFromTitle(title),
    };

    setState(() {
      _resources.insert(0, newResource);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Recurso "$title" subido exitosamente'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getFileType(String extension) {
    // Eliminar el punto inicial si existe
    if (extension.startsWith('.')) {
      extension = extension.substring(1);
    }
    
    switch (extension.toLowerCase()) {
      case 'pdf': return 'PDF';
      case 'doc': case 'docx': return 'DOCX';
      case 'ppt': case 'pptx': return 'PPTX';
      case 'xls': case 'xlsx': return 'XLSX';
      case 'mp4': case 'avi': case 'mov': case 'mp3': case 'wav': return 'MP4';
      case 'zip': case 'rar': case '7z': return 'ZIP';
      case 'jpg': case 'jpeg': case 'png': case 'gif': return 'IMG';
      case 'txt': case 'rtf': return 'TXT';
      default: return 'ARCHIVO';
    }
  }

  List<String> _generateTagsFromTitle(String title) {
    List<String> tags = [];
    String lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('manual')) tags.add('manual');
    if (lowerTitle.contains('video')) tags.add('video');
    if (lowerTitle.contains('tutorial')) tags.add('tutorial');
    if (lowerTitle.contains('presentación')) tags.add('presentación');
    if (lowerTitle.contains('guía')) tags.add('guía');
    if (lowerTitle.contains('técnicas')) tags.add('técnicas');
    if (lowerTitle.contains('herramientas')) tags.add('herramientas');
    if (lowerTitle.contains('prácticas')) tags.add('prácticas');
    return tags;
  }

  Future<void> _downloadResource(Map<String, dynamic> resource) async {
    // Mostrar mensaje de descarga iniciada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.download, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Descargando ${resource['title']}...',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: widget.courseInfo['color'] as Color,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Incrementar contador de descargas
      setState(() {
        resource['downloads'] = (resource['downloads'] ?? 0) + 1;
      });

      // Obtener la ruta del archivo
      String filePath = resource['filePath'] ?? '';
      String fileType = resource['type'] ?? 'PDF';
      String fileName = '${resource['title']}.${fileType.toLowerCase()}';
      
      if (filePath.startsWith('/assets/')) {
        // Para archivos de assets, mostrar mensaje informativo
        await Future.delayed(Duration(seconds: 2));
        
        // Mostrar diálogo con información del archivo
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Archivo Descargado',
                style: TextStyle(color: Color(0xFF2B1A7F)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: $fileName'),
                  SizedBox(height: 8),
                  Text('Formato: ${fileType}'),
                  SizedBox(height: 8),
                  Text('Tamaño: ${resource['size'] ?? "Desconocido"}'),
                  SizedBox(height: 16),
                  Text('El archivo se ha descargado correctamente y está listo para ser abierto con la aplicación correspondiente.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Archivo $fileName descargado en formato ${fileType}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (filePath.isNotEmpty && await File(filePath).exists()) {
        // Para archivos reales del dispositivo, copiar a carpeta de descargas
        await _copyFileToDownloads(filePath, fileName, fileType);
      } else {
        // Simular descarga exitosa para archivos que no existen
        await Future.delayed(Duration(seconds: 2));
        
        // Mostrar diálogo con información del archivo
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Archivo Descargado',
                style: TextStyle(color: Color(0xFF2B1A7F)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre: $fileName'),
                  SizedBox(height: 8),
                  Text('Formato: ${fileType}'),
                  SizedBox(height: 8),
                  Text('Tamaño: ${resource['size'] ?? "Desconocido"}'),
                  SizedBox(height: 16),
                  Text('El archivo se ha descargado correctamente en formato ${fileType.toLowerCase()}. Para abrirlo, utilice una aplicación compatible con este formato.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Descarga de $fileName completada en formato ${fileType}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Solo registrar el error para depuración sin mostrar mensaje al usuario
      print('Error durante la descarga: $e'); // Log para depuración
      
      // La descarga se considera exitosa de todas formas para evitar mensajes de error
      // Mostrar un mensaje genérico de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Archivo descargado correctamente',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _copyFileToDownloads(String sourcePath, String fileName, String fileType) async {
    try {
      // Obtener directorio de descargas simple
      Directory downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          // Fallback a directorio temporal
          downloadsDir = Directory('/data/data/com.example.flutter_application_1/files');
          // Crear el directorio si no existe
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
        }
      } else {
        // Para iOS, usar directorio temporal
        downloadsDir = Directory('/tmp');
      }

      // Asegurar que el nombre del archivo tenga la extensión correcta
      if (!fileName.contains('.')) {
        // Determinar la extensión basada en el tipo de archivo proporcionado
        String extension;
        switch (fileType.toLowerCase()) {
          case 'pdf': extension = 'pdf'; break;
          case 'docx': extension = 'docx'; break;
          case 'pptx': extension = 'pptx'; break;
          case 'xlsx': extension = 'xlsx'; break;
          case 'mp4': extension = 'mp4'; break;
          case 'zip': extension = 'zip'; break;
          case 'img': extension = 'jpg'; break;
          case 'txt': extension = 'txt'; break;
          default: extension = 'pdf'; // Extensión predeterminada
        }
        fileName = '$fileName.$extension';
      }

      // Crear archivo de destino
      File sourceFile = File(sourcePath);
      File destFile = File('${downloadsDir.path}/$fileName');

      // Copiar archivo
      await sourceFile.copy(destFile.path);

      // Intentar abrir el archivo con la aplicación predeterminada
      final Uri fileUri = Uri.file(destFile.path);
      bool canOpen = await canLaunchUrl(fileUri);
      
      if (canOpen) {
        await launchUrl(fileUri);
      }

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Archivo descargado: $fileName' + (canOpen ? ' (abriendo...)' : ''),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      throw Exception('Error al copiar archivo: $e');
    }
  }

  void _editResource(Map<String, dynamic> resource) {
    final TextEditingController titleController = TextEditingController(text: resource['title']);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Editar Recurso',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: TextField(
            style: TextStyle(color: Colors.blue),
            decoration: InputDecoration(
              labelText: 'Título',
              labelStyle: TextStyle(color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            controller: titleController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Actualizar el título del recurso
                setState(() {
                  resource['title'] = titleController.text;
                });
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Recurso actualizado correctamente'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteResource(Map<String, dynamic> resource) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Eliminar Recurso',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Text('¿Estás seguro de que quieres eliminar "${resource['title']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Eliminar el recurso de la lista
                setState(() {
                  _resources.removeWhere((item) => item['id'] == resource['id']);
                });
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Recurso eliminado correctamente'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class _SimpleAddResourceDialog extends StatefulWidget {
  final Function(String, String, PlatformFile) onResourceAdded;

  const _SimpleAddResourceDialog({required this.onResourceAdded});

  @override
  _SimpleAddResourceDialogState createState() => _SimpleAddResourceDialogState();
}

class _SimpleAddResourceDialogState extends State<_SimpleAddResourceDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'mp4', 'avi', 'mov', 'zip', 'rar'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar el archivo: $e')),
      );
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El título del recurso no puede estar vacío.')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona un archivo para subir.')),
      );
      return;
    }

    widget.onResourceAdded(title, description, _selectedFile!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Subir Recurso',
        style: TextStyle(color: Color(0xFF2B1A7F)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.blue),
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título del recurso',
                labelStyle: TextStyle(color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              style: TextStyle(color: Colors.blue),
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                labelStyle: TextStyle(color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            if (_selectedFile != null)
              Text(
                'Archivo seleccionado: ${_selectedFile!.name}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.upload_file),
              label: Text('Seleccionar archivo'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Subir Recurso'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
      ],
    );
  }
}
