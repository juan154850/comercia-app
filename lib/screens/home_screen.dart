// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;


  // Método para actualizar el índice cuando se selecciona una opción
  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    } else if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/cart');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/notifications');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla de inicio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Evita que las opciones se redimensionen
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mi Perfil',
          ),
        ],
        currentIndex: _selectedIndex, // Índice de la opción seleccionada
        selectedItemColor: Colors.blue, // Color del ítem seleccionado
        onTap: _onItemTapped, // Método que se llama al seleccionar una opción
      ),
    );
  }

  // Método auxiliar para obtener el título de la página seleccionada
  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Carrito';
      case 2:
        return 'Notificaciones';
      case 3:
        return 'Mi Perfil';
      default:
        return 'Inicio';
    }
  }
}
