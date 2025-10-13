import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  final String userType;
  final String userName;

  const AttendanceScreen({
    Key? key,
    required this.userType,
    required this.userName,
  }) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedCourse = 'Corte y Peinado Profesional';
  String _selectedDate = '2024-02-15';
  bool _isMarkingAttendance = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Asistencia',
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
                _showAddAttendanceDialog();
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
                      child: TextFormField(
                        style: TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          labelStyle: TextStyle(color: Colors.blue),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(text: _selectedDate),
                        onTap: () {
                          _selectDate(context);
                        },
                        readOnly: true,
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
                            _exportAttendance();
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
                            _showAttendanceStatistics();
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
                ? _buildTeacherAttendanceView() 
                : _buildStudentAttendanceView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherAttendanceView() {
    final List<Map<String, dynamic>> students = [
      {
        'name': 'Ana García',
        'email': 'ana.garcia@email.com',
        'attendance': true,
        'time': '09:00',
        'notes': '',
      },
      {
        'name': 'Carlos López',
        'email': 'carlos.lopez@email.com',
        'attendance': false,
        'time': '',
        'notes': 'Justificado - Cita médica',
      },
      {
        'name': 'María Rodríguez',
        'email': 'maria.rodriguez@email.com',
        'attendance': true,
        'time': '08:55',
        'notes': '',
      },
      {
        'name': 'Juan Pérez',
        'email': 'juan.perez@email.com',
        'attendance': true,
        'time': '09:15',
        'notes': 'Llegó tarde',
      },
      {
        'name': 'Laura Silva',
        'email': 'laura.silva@email.com',
        'attendance': false,
        'time': '',
        'notes': 'Sin justificación',
      },
    ];

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Resumen de asistencia
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttendanceSummary('Presentes', '3', Colors.green),
                _buildAttendanceSummary('Ausentes', '2', Colors.red),
                _buildAttendanceSummary('Porcentaje', '60%', Colors.blue),
              ],
            ),
          ),
          
          // Lista de estudiantes
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
                      backgroundColor: student['attendance'] 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      child: Icon(
                        student['attendance'] ? Icons.check : Icons.close,
                        color: student['attendance'] ? Colors.green : Colors.red,
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
                        if (student['attendance'] && student['time'].isNotEmpty)
                          Text('Hora de llegada: ${student['time']}'),
                        if (student['notes'].isNotEmpty)
                          Text(
                            'Nota: ${student['notes']}',
                            style: TextStyle(
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editAttendance(student);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () {
                            _sendAttendanceNotification(student);
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

  Widget _buildStudentAttendanceView() {
    final List<Map<String, dynamic>> attendanceRecords = [
      {
        'date': '2024-02-15',
        'course': 'Corte y Peinado Profesional',
        'status': 'Presente',
        'time': '09:00',
        'notes': '',
      },
      {
        'date': '2024-02-14',
        'course': 'Corte y Peinado Profesional',
        'status': 'Presente',
        'time': '08:55',
        'notes': '',
      },
      {
        'date': '2024-02-13',
        'course': 'Corte y Peinado Profesional',
        'status': 'Ausente',
        'time': '',
        'notes': 'Justificado - Cita médica',
      },
      {
        'date': '2024-02-12',
        'course': 'Corte y Peinado Profesional',
        'status': 'Presente',
        'time': '09:15',
        'notes': 'Llegó tarde',
      },
      {
        'date': '2024-02-11',
        'course': 'Corte y Peinado Profesional',
        'status': 'Presente',
        'time': '08:50',
        'notes': '',
      },
    ];

    // Calcular estadísticas
    int totalClasses = attendanceRecords.length;
    int presentCount = attendanceRecords.where((record) => record['status'] == 'Presente').length;
    double attendancePercentage = (presentCount / totalClasses) * 100;

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Resumen personal
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
                  'Mi Asistencia',
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
                    _buildAttendanceSummary('Presentes', presentCount.toString(), Colors.green),
                    _buildAttendanceSummary('Ausentes', (totalClasses - presentCount).toString(), Colors.red),
                    _buildAttendanceSummary('Porcentaje', '${attendancePercentage.toStringAsFixed(1)}%', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de registros
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = attendanceRecords[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: record['status'] == 'Presente' 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        record['status'] == 'Presente' ? Icons.check : Icons.close,
                        color: record['status'] == 'Presente' ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      record['date'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record['course']),
                        Text('Estado: ${record['status']}'),
                        if (record['time'].isNotEmpty)
                          Text('Hora: ${record['time']}'),
                        if (record['notes'].isNotEmpty)
                          Text(
                            'Nota: ${record['notes']}',
                            style: TextStyle(
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
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

  Widget _buildAttendanceSummary(String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          Icons.person,
          color: color,
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

  // Action methods
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showAddAttendanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Registrar Asistencia',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Curso: $_selectedCourse'),
              Text('Fecha: $_selectedDate'),
              SizedBox(height: 10),
              Text('¿Deseas marcar la asistencia para todos los estudiantes?'),
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
                setState(() {
                  _isMarkingAttendance = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Iniciando registro de asistencia...')),
                );
              },
              child: Text('Iniciar'),
            ),
          ],
        );
      },
    );
  }

  void _editAttendance(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Editar Asistencia de ${student['name']}',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Asistencia: '),
                  Switch(
                    value: student['attendance'],
                    onChanged: (bool value) {
                      setState(() {
                        student['attendance'] = value;
                      });
                    },
                  ),
                  Text(student['attendance'] ? 'Presente' : 'Ausente'),
                ],
              ),
              if (student['attendance']) ...[
                SizedBox(height: 10),
                TextField(
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Hora de llegada',
                    labelStyle: TextStyle(color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: student['time']),
                ),
              ],
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Notas',
                  labelStyle: TextStyle(color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: student['notes']),
                maxLines: 2,
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
                  SnackBar(content: Text('Asistencia actualizada')),
                );
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _sendAttendanceNotification(Map<String, dynamic> student) {
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
              Text('Estado: ${student['attendance'] ? 'Presente' : 'Ausente'}'),
              if (!student['attendance'])
                Text('Fecha: $_selectedDate'),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.blue),
                maxLines: 3,
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

  void _exportAttendance() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Exportar Asistencia',
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
                    SnackBar(content: Text('Exportando asistencia como PDF...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart),
                title: Text('Exportar como Excel'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exportando asistencia como Excel...')),
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

  void _showAttendanceStatistics() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Estadísticas de Asistencia',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('Total de Estudiantes', '25'),
              _buildStatItem('Presentes', '15 (60%)'),
              _buildStatItem('Ausentes', '10 (40%)'),
              _buildStatItem('Justificados', '3 (12%)'),
              _buildStatItem('Sin Justificación', '7 (28%)'),
              _buildStatItem('Promedio de Asistencia', '60%'),
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


