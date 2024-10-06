// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            CustomButton(
              text: 'Registrar',
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;

                if (validateEmail(email) && validatePassword(password)) {
                  User? user = await _authService.registerWithEmailAndPassword(email, password);
                  
                  if (user != null) {
                    print('Registro exitoso');
                    Navigator.pop(context); // Vuelve a la pantalla de login
                  } else {
                    print('Error en el registro');
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('No se pudo completar el registro'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  print('Datos inválidos');
                }
              },
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Regresa a la pantalla de login
              },
              child: const Text("¿Ya tienes cuenta? Inicia sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
