import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final String? userType;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Inicio',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: 'Cursos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Calendario',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    // Se elimina la pestaña Admin para todos los tipos de usuario.
    // Si en el futuro se requiere mostrarla para un rol específico (p. ej. 'admin'),
    // se puede reintroducir aquí con la condición adecuada.

    return BottomNavigationBar(
      items: items,
      currentIndex: selectedIndex,
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: onItemTapped,
    );
  }
}