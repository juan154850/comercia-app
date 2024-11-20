// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final userId =
          _auth.currentUser?.uid; // Usamos _auth para obtener el userId
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('customerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final transactions = querySnapshot.docs.map((doc) {
        return {
          'orderId': doc['orderId'],
          'orderTotal': doc['orderTotal'],
          'createdAt': doc['createdAt']?.toDate(),
          'productIds': doc['productIds'],
          'sellerIds': doc['sellerIds'],
        };
      }).toList();

      setState(() {
        _transactions =
            transactions; // Almacenar las transacciones en el estado
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar transacciones: $e');
      setState(() {
        _error = 'Error al cargar transacciones: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Transacciones'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _transactions.isEmpty
                  ? const Center(
                      child: Text('No tienes transacciones realizadas.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              'Orden ID: ${transaction['orderId']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fecha: ${transaction['createdAt'] ?? 'Sin fecha'}',
                                ),
                                Text(
                                  'Total: \$${transaction['orderTotal'] ?? 0.0}',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Productos (${transaction['productIds']?.length ?? 0}):',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                ...transaction['productIds']
                                    .map<Widget>((id) => Text('• $id'))
                                    .toList(),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
}
