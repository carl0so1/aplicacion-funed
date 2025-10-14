import 'package:flutter/material.dart';

class CoursesSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                      child: Icon(
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
                        // Información específica para estudiantes
                        if (userType.toLowerCase() == 'estudiante') ...[
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
                        // Información específica para docentes
                        if (userType.toLowerCase() == 'docente') ...[
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
                      onPressed: () => onViewCourse(course),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: course['color'] ?? Colors.cyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        userType.toLowerCase() == 'estudiante' ? 'Ver curso' : 'Gestionar',
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
}