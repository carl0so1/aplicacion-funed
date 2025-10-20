import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({Key? key}) : super(key: key);

  @override
  _AdminCoursesScreenState createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getAllCourses();
      if (result['success'] == true) {
        setState(() {
          _courses = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage(result['message'] ?? 'Error al cargar cursos');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error de conexión: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteCourse(String courseId, String courseName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Eliminar Curso',
            style: TextStyle(color: Color(0xFF2B1A7F)),
          ),
          content: Text('¿Estás seguro de que quieres eliminar el curso "$courseName"?\n\nEsta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final result = await ApiService.deleteCourse(courseId);
        if (result['success'] == true) {
          _showSuccessMessage('Curso eliminado exitosamente');
          _loadCourses(); // Recargar la lista
        } else {
          _showErrorMessage(result['message'] ?? 'Error al eliminar curso');
        }
      } catch (e) {
        _showErrorMessage('Error de conexión: $e');
      }
    }
  }

  void _showCourseForm({Map<String, dynamic>? course}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CourseFormDialog(
          course: course,
          onSaved: () {
            Navigator.of(context).pop();
            _loadCourses();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B1A7F),
      appBar: AppBar(
        title: Text(
          'Administración de Cursos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2B1A7F),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              children: [
                // Header con botón de agregar
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total de cursos: ${_courses.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showCourseForm(),
                        icon: Icon(Icons.add),
                        label: Text('Nuevo Curso'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF2B1A7F),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de cursos
                Expanded(
                  child: _courses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No hay cursos registrados',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Agrega el primer curso usando el botón "+"',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            final course = _courses[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFF2B1A7F),
                                  child: Icon(
                                    Icons.school,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  course['nombre_curso'] ?? 'Sin nombre',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text('Código: ${course['codigo'] ?? 'N/A'}'),
                                    Text('Duración: ${course['duracion'] ?? 'N/A'}'),
                                    Text('Precio: \$${course['precio'] ?? 'N/A'}'),
                                    Text('Cupos: ${course['cupos'] ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.edit, color: Colors.blue),
                                        title: Text('Editar'),
                                      ),
                                      onTap: () {
                                        Future.delayed(Duration.zero, () {
                                          _showCourseForm(course: course);
                                        });
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ),
                                      onTap: () {
                                        Future.delayed(Duration.zero, () {
                                          _deleteCourse(
                                            course['id'].toString(),
                                            course['nombre_curso'] ?? 'Sin nombre',
                                          );
                                        });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourseForm(),
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Color(0xFF2B1A7F)),
      ),
    );
  }
}

class CourseFormDialog extends StatefulWidget {
  final Map<String, dynamic>? course;
  final VoidCallback onSaved;

  const CourseFormDialog({
    Key? key,
    this.course,
    required this.onSaved,
  }) : super(key: key);

  @override
  _CourseFormDialogState createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _duracionController = TextEditingController();
  final _temarioController = TextEditingController();
  final _tipoCursoController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  final _horarioController = TextEditingController();
  final _precioController = TextEditingController();
  final _cuposController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _nombreController.text = widget.course!['nombre_curso'] ?? '';
      _codigoController.text = widget.course!['codigo'] ?? '';
      _duracionController.text = widget.course!['duracion'] ?? '';
      _temarioController.text = widget.course!['temario'] ?? '';
      _tipoCursoController.text = widget.course!['tipo_curso'] ?? '';
      _fechaInicioController.text = widget.course!['fechaInicio'] ?? '';
      _fechaFinController.text = widget.course!['fechaFin'] ?? '';
      _horarioController.text = widget.course!['horario'] ?? '';
      _precioController.text = widget.course!['precio']?.toString() ?? '';
      _cuposController.text = widget.course!['cupos']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _duracionController.dispose();
    _temarioController.dispose();
    _tipoCursoController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _horarioController.dispose();
    _precioController.dispose();
    _cuposController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final courseData = {
      'nombre_curso': _nombreController.text,
      'codigo': _codigoController.text,
      'duracion': _duracionController.text,
      'temario': _temarioController.text,
      'tipo_curso': _tipoCursoController.text,
      'fechaInicio': _fechaInicioController.text,
      'fechaFin': _fechaFinController.text,
      'horario': _horarioController.text,
      'precio': double.tryParse(_precioController.text) ?? 0,
      'cupos': int.tryParse(_cuposController.text) ?? 0,
    };

    try {
      Map<String, dynamic> result;
      if (widget.course != null) {
        // Actualizar curso existente
        result = await ApiService.updateCourse(
          widget.course!['id'].toString(),
          courseData,
        );
      } else {
        // Crear nuevo curso
        result = await ApiService.createCourse(courseData);
      }

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.course != null
                  ? 'Curso actualizado exitosamente'
                  : 'Curso creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al guardar curso'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.course != null ? 'Editar Curso' : 'Nuevo Curso',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B1A7F),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Divider(),
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Curso *',
                          labelStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.blue),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre del curso es requerido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _codigoController,
                        decoration: InputDecoration(
                          labelText: 'Código del Curso *',
                          labelStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.blue),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El código del curso es requerido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _duracionController,
                        decoration: InputDecoration(
                          labelText: 'Duración',
                          labelStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          hintText: 'Ej: 3 meses, 120 horas',
                        ),
                        style: TextStyle(color: Colors.blue),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _temarioController,
                        decoration: InputDecoration(
                          labelText: 'Temario',
                          labelStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.blue),
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _tipoCursoController,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Curso',
                          labelStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Presencial, Virtual, Híbrido',
                        ),
                        style: TextStyle(color: Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fechaInicioController,
                              decoration: InputDecoration(
                                labelText: 'Fecha de Inicio',
                                labelStyle: TextStyle(color: Colors.blue),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                hintText: 'YYYY-MM-DD',
                              ),
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _fechaFinController,
                              decoration: InputDecoration(
                                labelText: 'Fecha de Fin',
                                labelStyle: TextStyle(color: Colors.blue),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                hintText: 'YYYY-MM-DD',
                              ),
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _horarioController,
                        decoration: InputDecoration(
                          labelText: 'Horario',
                          labelStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Lunes a Viernes 9:00-12:00',
                        ),
                        style: TextStyle(color: Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _precioController,
                              decoration: InputDecoration(
                                labelText: 'Precio',
                                labelStyle: TextStyle(color: Colors.blue),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                                prefixText: '\$',
                              ),
                              style: TextStyle(color: Colors.blue),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cuposController,
                              decoration: InputDecoration(
                                labelText: 'Cupos',
                                labelStyle: TextStyle(color: Colors.blue),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(color: Colors.blue),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Buttons
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2B1A7F),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.course != null ? 'Actualizar' : 'Crear',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}