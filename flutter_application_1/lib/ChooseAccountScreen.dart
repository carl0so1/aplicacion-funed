import 'package:flutter/material.dart';
import 'dart:async';

class ChooseAccountScreen extends StatefulWidget {
  @override
  _ChooseAccountScreenState createState() => _ChooseAccountScreenState();
}

class _ChooseAccountScreenState extends State<ChooseAccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  String saludo = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    _setSaludo();
  }

  void _setSaludo() {
    final hora = DateTime.now().hour;
    if (hora >= 6 && hora < 12) {
      saludo = '¡Buenos días!';
    } else if (hora >= 12 && hora < 18) {
      saludo = '¡Buenas tardes!';
    } else {
      saludo = '¡Buenas noches!';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B1A7F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ---------- Animación del logo ----------
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
                child: Image.asset(
                  'assets/logo.png',
                  height: 180,
                ),
              ),
              const SizedBox(height: 20),

              // ---------- Saludo dinámico ----------
              Text(
                saludo,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // ---------- Botón Docente ----------
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.school),
                label: const Text('Soy Docente'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/',
                    arguments: 'docente',
                  );
                },
              ),
              const SizedBox(height: 20),

              // ---------- Botón Estudiante ----------
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.person),
                label: const Text('Soy Estudiante'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/',
                    arguments: 'estudiante',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
