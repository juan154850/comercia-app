// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Retorna el usuario si el login es exitoso
    } catch (e) {
      print('Error en la autenticación: $e');
      return null; // Retorna null si hay un error
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Retorna el usuario si el registro es exitoso
    } catch (e) {
      print('Error en el registro: $e');
      return null; // Retorna null si hay un error
    }
  }

  Future<void> signOut() async {
    await _auth.signOut(); // Cierra la sesión
  }
}
