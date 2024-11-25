import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {

  Future<String> createTransaction({
    required List<String> sellerIds,
    required String customerId,
    required List<String> productIds,
    required double orderTotal,
  }) async {
    try {
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      final transactionData = {
        'sellerIds': sellerIds, // Lista de vendedores involucrados
        'customerId': customerId, // ID del cliente
        'productIds': productIds, // Lista de IDs de productos
        'orderTotal': orderTotal, // Total de la orden
        'createdAt': FieldValue.serverTimestamp(),
        'orderId': orderId,
      };

      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transactionData);

      return orderId;
    } catch (e) {
      throw Exception('Error al crear la transacción: $e');
    }
  }
}
