import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final String userName;
  final String userType;
  final String userEmail;
  final Function() onLogout;
  final Function()? onAbout;

  const ProfileSection({
    Key? key,
    required this.userName,
    required this.userType,
    required this.userEmail,
    required this.onLogout,
    this.onAbout,
  }) : super(key: key);

  void _showNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Avatar y información del usuario
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2B1A7F),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B1A7F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userType,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Opciones del perfil
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
                    'Opciones',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B1A7F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.settings, color: Color(0xFF2B1A7F)),
                    title: const Text('Configuración'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showNotImplemented(context, 'Configuración'),
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.notifications, color: Color(0xFF2B1A7F)),
                    title: const Text('Notificaciones'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showNotImplemented(context, 'Notificaciones'),
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.lock, color: Color(0xFF2B1A7F)),
                    title: const Text('Cambiar Contraseña'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showNotImplemented(context, 'Cambiar Contraseña'),
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.help, color: Color(0xFF2B1A7F)),
                    title: const Text('Ayuda y Soporte'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showNotImplemented(context, 'Ayuda y Soporte'),
                  ),
                  
                  if (onAbout != null) ...[                  
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info, color: Color(0xFF2B1A7F)),
                      title: const Text('Acerca de FUNED'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: onAbout,
                    ),
                  ],
                  
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}