// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instancia de Firestore

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

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String firstName, String lastName, String phone) async {
    try {
      // Registrar al usuario con Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Guardar información adicional del usuario en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(), // Agrega la fecha de creación
        });

        return user; // Retorna el usuario si el registro es exitoso
      }
      return null;
    } catch (e) {
      print('Error en el registro: $e');
      return null; // Retorna null si hay un error
    }
  }

  Future<bool> checkSession() async {
    await Future.delayed(const Duration(seconds: 1));
    bool isLoggedIn = _auth.currentUser != null;
    return isLoggedIn;
  }

  Future<void> signOut() async {
    await _auth.signOut(); // Cierra la sesión
  }
}
