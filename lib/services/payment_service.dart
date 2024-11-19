// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> getUserPaymentMethods() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return [];

      QuerySnapshot query = await _firestore
          .collection('payment_methods')
          .where('userId', isEqualTo: userId)
          .get();

      return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error al obtener métodos de pago: $e');
      return [];
    }
  }

  Future<void> addPaymentMethod({
    required String cardHolderName,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('Usuario no autenticado');

      await _firestore.collection('payment_methods').add({
        'userId': userId,
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cvv': cvv,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al agregar método de pago: $e');
    }
  }
}
