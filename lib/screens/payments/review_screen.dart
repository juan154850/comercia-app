// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/screens/payments/payment_success_screen.dart';
import 'package:myapp/services/transaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/auth_service.dart';

class ReviewScreen extends StatelessWidget {
  final String addressName;
  final String addressDetails;
  final String phoneNumber;
  final String paymentMethod;
  final double orderTotal;
  final TransactionService transactionService = TransactionService();
  final AuthService authService = AuthService();

  ReviewScreen({
    super.key,
    required this.addressName,
    required this.addressDetails,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.orderTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dirección de envío
            const Text(
              'Dirección de envío',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        addressDetails,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phoneNumber,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // Método de pago
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.credit_card, color: Colors.red, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      paymentMethod,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    // Acción para editar método de pago
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
            const Divider(height: 32),

            // Resumen de la orden
            const Text(
              'Orden:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 14)),
                Text(
                  '\$${orderTotal.toStringAsFixed(2)}', // Texto dinámico basado en el total
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gastos de envío', style: TextStyle(fontSize: 14)),
                Text('Gratis', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${orderTotal.toStringAsFixed(3)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),

            // Botón de pagar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final user = authService.getCurrentUser();
                    if (user == null) {
                      throw Exception('Usuario no autenticado');
                    }

                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final List<String> cart = prefs.getStringList('cart') ?? [];
                    print(
                        'Carrito cargado: $cart'); // Imprime el contenido del carrito

                    final List<Map<String, dynamic>> products = cart
                        .map((item) => jsonDecode(item) as Map<String, dynamic>)
                        .toList();
                    print(
                        'Productos decodificados: $products'); // Imprime los productos decodificados

                    // Validar que todos los productos tengan los campos necesarios
                    final List<String> productIds = products
                        .where((product) => product['id'] != null)
                        .map((product) => product['id'] as String)
                        .toList();
                    print(
                        'IDs de productos válidos: $productIds'); // Imprime los IDs de los productos

                    final List<String> sellerIds = products
                        .where((product) => product['userId'] != null)
                        .map((product) => product['userId'] as String)
                        .toSet()
                        .toList();
                    print(
                        'IDs de vendedores válidos: $sellerIds'); // Imprime los IDs de los vendedores

                    // Verificar si hay productos inválidos
                    if (productIds.isEmpty || sellerIds.isEmpty) {
                      throw Exception('Productos inválidos en el carrito');
                    }

                    // Crear la transacción
                    print('Preparando para crear transacción...');
                    print('Cliente ID: ${user.uid}');
                    print('Total de la orden: $orderTotal');

                    final orderId = await transactionService.createTransaction(
                      sellerIds:
                          sellerIds, // IDs de los vendedores de los productos
                      customerId: user.uid, // ID del usuario logueado
                      productIds: productIds, // IDs de los productos comprados
                      orderTotal: orderTotal,
                    );
                    
                    await prefs.clear();
                    print("Carrito de compras limpiado."); // Mensaje para confirmar limpieza

                    print(
                        'Transacción creada con éxito. ID de la orden: $orderId');

                    // Redirigir a la pantalla de éxito
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentSuccessScreen(orderId: orderId),
                      ),
                    );
                  } catch (e) {
                    print(
                        'Error capturado: $e'); // Imprime el error en consola para mayor detalle
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al procesar el pago: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pagar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
