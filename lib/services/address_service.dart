// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      QuerySnapshot query = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener direcciones: $e');
      return [];
    }
  }

  Future<void> addAddress({
    required String name,
    required String lastName,
    required String direction,
    required String city,
    required String state,
    required String postalCode,
    required String phoneNumber,
  }) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('Usuario no autenticado');

      await _firestore.collection('addresses').add({
        'userId': userId,
        'name': name,
        'lastName': lastName,
        'direction': direction,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al agregar dirección: $e');
    }
  }
}
