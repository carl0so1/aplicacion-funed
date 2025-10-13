import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  final String userName;
  final String userType;
  final Map<String, dynamic>? currentCourse;
  final Function(Map<String, dynamic>) onViewCourse;

  const HomeContent({
    Key? key,
    required this.userName,
    required this.userType,
    this.currentCourse,
    required this.onViewCourse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de bienvenida
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userType.toLowerCase() == 'estudiante' 
                        ? '¡Hola, $userName!' 
                        : '¡Bienvenido, Profesor $userName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B1A7F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        userType.toLowerCase() == 'estudiante' 
                            ? Icons.school 
                            : Icons.person_outline,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        userType.toLowerCase() == 'estudiante' 
                            ? 'Estudiante' 
                            : 'Docente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userType.toLowerCase() == 'estudiante'
                        ? 'Continúa con tu aprendizaje y revisa tus cursos.'
                        : 'Gestiona tus cursos y supervisa el progreso de tus estudiantes.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Acciones rápidas específicas por tipo de usuario
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userType.toLowerCase() == 'estudiante' ? 'Acciones Rápidas' : 'Panel de Control',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B1A7F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (userType.toLowerCase() == 'estudiante') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.assignment,
                          label: 'Tareas',
                          color: Colors.blue,
                          onTap: () {},
                        ),
                        _buildQuickActionButton(
                          icon: Icons.grade,
                          label: 'Calificaciones',
                          color: Colors.green,
                          onTap: () {},
                        ),
                        _buildQuickActionButton(
                          icon: Icons.schedule,
                          label: 'Horarios',
                          color: Colors.orange,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.people,
                          label: 'Estudiantes',
                          color: Colors.blue,
                          onTap: () {},
                        ),
                        _buildQuickActionButton(
                          icon: Icons.assessment,
                          label: 'Reportes',
                          color: Colors.green,
                          onTap: () {},
                        ),
                        _buildQuickActionButton(
                          icon: Icons.add_circle,
                          label: 'Nuevo Curso',
                          color: Colors.purple,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Curso actual (si existe)
          if (currentCourse != null) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Curso Actual',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B1A7F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentCourse!['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Código: ${currentCourse!['codigo'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => onViewCourse(currentCourse!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B1A7F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Ver todo sobre el curso'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}