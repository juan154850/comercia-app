// lib/screens/splash_screen.dart

// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () async {
      // Simula el chequeo de sesión activa o no
      bool isLoggedIn = await AuthService().checkSession(); // Este método sería parte de tu servicio de autenticación.
      
      // Redireccionar dependiendo del estado de sesión
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF84EAE1),
              Color(0xFF000000),
            ],
            stops: [0.0, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: Center(
          child: Image.asset(
            'assets/images/logo.webp', // Asegúrate de tener el logo en assets
            width: 350, // Ajusta el tamaño según tu necesidad
            height: 350,
          ),
        ),
      ),
    );
  }
}
