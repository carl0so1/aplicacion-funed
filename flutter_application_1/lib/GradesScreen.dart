import 'package:flutter/material.dart';

class GradesScreen extends StatefulWidget {
  final String userType;
  final String userName;

  const GradesScreen({
    Key? key,
    required this.userType,
    required this.userName,
  }) : super(key: key);

  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String _selectedCourse = 'Todos los cursos';
  String _selectedPeriod = 'Primer Semestre';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Calificaciones',
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
          if (widget.userType == 'docente')
            IconButton(
              icon: Icon(Icons.add, color: Color(0xFF2B1A7F)),
              onPressed: () {
                _showAddGradeDialog();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCourse,
                        style: TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                          labelText: 'Curso',
                          labelStyle: TextStyle(color: Colors.blue),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          'Todos los cursos',
                          'Corte y Peinado Profesional',
                          'Maquillaje Artístico',
                          'Coloración y Tintes',
                          'Manicure y Pedicure',
                          'Tratamientos Faciales',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCourse = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        style: TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                          labelText: 'Período',
                          labelStyle: TextStyle(color: Colors.blue),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          'Primer Semestre',
                          'Segundo Semestre',
                          'Verano',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPeriod = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (widget.userType == 'docente')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _exportGrades();
                          },
                          icon: Icon(Icons.download),
                          label: Text('Exportar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showGradeStatistics();
                          },
                          icon: Icon(Icons.analytics),
                          label: Text('Estadísticas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: widget.userType == 'docente' 
                ? _buildTeacherGradesView() 
                : _buildStudentGradesView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherGradesView() {
    final List<Map<String, dynamic>> students = [
      {
        'name': 'Ana García',
        'email': 'ana.garcia@email.com',
        'course': 'Corte y Peinado Profesional',
        'grades': {
          'Tarea 1': 85,
          'Examen Parcial': 92,
          'Proyecto Final': 88,
          'Participación': 90,
        },
        'average': 88.75,
      },
      {
        'name': 'Carlos López',
        'email': 'carlos.lopez@email.com',
        'course': 'Corte y Peinado Profesional',
        'grades': {
          'Tarea 1': 78,
          'Examen Parcial': 85,
          'Proyecto Final': 82,
          'Participación': 88,
        },
        'average': 83.25,
      },
      {
        'name': 'María Rodríguez',
        'email': 'maria.rodriguez@email.com',
        'course': 'Maquillaje Artístico',
        'grades': {
          'Tarea 1': 95,
          'Examen Parcial': 98,
          'Proyecto Final': 96,
          'Participación': 92,
        },
        'average': 95.25,
      },
    ];

    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.cyan.withOpacity(0.1),
                child: Text(
                  student['name'].split(' ').map((e) => e[0]).join(''),
                  style: TextStyle(
                    color: Colors.cyan,
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
                  Text(student['course']),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Promedio: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${student['average'].toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getGradeColor(student['average']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editStudentGrades(student);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.message),
                    onPressed: () {
                      _sendGradeNotification(student);
                    },
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...student['grades'].entries.map((entry) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Row(
                              children: [
                                Text(
                                  '${entry.value}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getGradeColor(entry.value.toDouble()),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.edit, size: 16),
                                  onPressed: () {
                                    _editSpecificGrade(student, entry.key, entry.value);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )).toList(),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Promedio Final',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${student['average'].toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _getGradeColor(student['average']),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentGradesView() {
    final List<Map<String, dynamic>> courses = [
      {
        'name': 'Corte y Peinado Profesional',
        'code': 'BELLEZA-101',
        'grades': {
          'Tarea 1': 85,
          'Examen Parcial': 92,
          'Proyecto Final': 88,
          'Participación': 90,
        },
        'average': 88.75,
        'status': 'En progreso',
      },
      {
        'name': 'Maquillaje Artístico',
        'code': 'BELLEZA-102',
        'grades': {
          'Tarea 1': 78,
          'Examen Parcial': 85,
          'Proyecto Final': 82,
          'Participación': 88,
        },
        'average': 83.25,
        'status': 'Completado',
      },
    ];

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Resumen general
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Resumen Académico',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Promedio General', '86.0%', Icons.trending_up),
                    _buildSummaryItem('Cursos Activos', '2', Icons.school),
                    _buildSummaryItem('Créditos', '7', Icons.credit_card),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de cursos
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.cyan,
                      ),
                    ),
                    title: Text(
                      course['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código: ${course['code']}'),
                        Row(
                          children: [
                            Text(
                              'Promedio: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${course['average'].toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: _getGradeColor(course['average']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: course['status'] == 'Completado' 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: course['status'] == 'Completado' 
                              ? Colors.green 
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ...course['grades'].entries.map((entry) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(
                                    '${entry.value}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getGradeColor(entry.value.toDouble()),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Promedio del Curso',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${course['average'].toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _getGradeColor(course['average']),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.cyan,
          size: 24,
        ),
        SizedBox(height: 4),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.blue;
    if (grade >= 70) return Colors.orange;
    return Colors.red;
  }

  // Action methods
  void _showAddGradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Agregar Calificación',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Estudiante',
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Ana García',
                  'Carlos López',
                  'María Rodríguez',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
              ),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Actividad',
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
                  labelText: 'Calificación (%)',
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                  SnackBar(content: Text('Calificación agregada exitosamente')),
                );
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _editStudentGrades(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Editar Calificaciones de ${student['name']}',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...student['grades'].entries.map((entry) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        style: TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        controller: TextEditingController(text: entry.value.toString()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              )).toList(),
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
                  SnackBar(content: Text('Calificaciones actualizadas')),
                );
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _editSpecificGrade(Map<String, dynamic> student, String activity, int currentGrade) {
    final TextEditingController gradeController = TextEditingController(text: currentGrade.toString());
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Editar Calificación',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estudiante: ${student['name']}'),
              Text('Actividad: $activity'),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Nueva calificación (%)',
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                controller: gradeController,
                keyboardType: TextInputType.number,
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
                  SnackBar(content: Text('Calificación actualizada')),
                );
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _sendGradeNotification(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Enviar Notificación a ${student['name']}',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Promedio actual: ${student['average'].toStringAsFixed(1)}%'),
              SizedBox(height: 10),
              TextField(
                maxLines: 3,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Mensaje (opcional)',
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
                  SnackBar(content: Text('Notificación enviada a ${student['name']}')),
                );
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _exportGrades() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Exportar Calificaciones',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Exportar como PDF'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exportando como PDF...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart),
                title: Text('Exportar como Excel'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exportando como Excel...')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showGradeStatistics() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Estadísticas de Calificaciones',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('Promedio General', '86.5%'),
              _buildStatItem('Calificación Más Alta', '98%'),
              _buildStatItem('Calificación Más Baja', '72%'),
              _buildStatItem('Total de Estudiantes', '25'),
              _buildStatItem('Aprobados', '23 (92%)'),
              _buildStatItem('Reprobados', '2 (8%)'),
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

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


