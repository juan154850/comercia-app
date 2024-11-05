// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      String uid = _auth.currentUser?.uid ?? '';
      if (uid.isEmpty) return null;

      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }
}
