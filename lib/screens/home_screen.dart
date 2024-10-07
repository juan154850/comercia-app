// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Asegúrate de importar tu servicio de autenticación

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice seleccionado en el BottomNavigationBar
  int _selectedIndex = 0;

  final AuthService _authService = AuthService(); // Instancia del servicio de autenticación

  // Método para actualizar el índice cuando se selecciona una opción
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Método para cerrar sesión
  Future<void> _signOut() async {
    await _authService.signOut(); // Llamada para cerrar la sesión
    Navigator.pushReplacementNamed(context, '/login'); // Redirigir a la página de login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Ícono de cerrar sesión
            onPressed: _signOut, // Llama al método de cerrar sesión cuando se presiona
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20.0),
            Text(
              _getPageTitle(_selectedIndex),
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
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
