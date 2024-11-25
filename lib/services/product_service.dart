// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addProduct(
      {required String name,
      required double price,
      required String description,
      required List<String> images,
      required String status,
      required int stock}) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('products').add({
        'comments': [],
        'createdAt': FieldValue.serverTimestamp(),
        'description': description,
        'images': images,
        'name': name,
        'price': price,
        'rateAverage': 0.0,
        'status': status,
        'stock': stock,
        'userId': userId,
      });
    }
  }

  Future<String> uploadImage(File image) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not logged in");
    }

    // Genera un nombre de archivo único basado en el tiempo actual
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = _storage.ref().child('products/$userId/$timestamp.jpg');

    try {
      print(
          "Intentando subir la imagen a la ruta: products/$userId/$timestamp.jpg");

      // Verifica que el archivo realmente existe
      if (!image.existsSync()) {
        throw Exception("El archivo de imagen no existe en el dispositivo.");
      }

      // Sube el archivo a Firebase Storage
      await storageRef.putFile(image);

      // Obtén la URL de descarga
      final downloadURL = await storageRef.getDownloadURL();

      print("Subida exitosa. URL de descarga: $downloadURL");
      return downloadURL;
    } catch (e) {
      print('Error al subir la imagen: $e');
      throw Exception("Error al subir la imagen: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllProducts(
      {Map<String, dynamic>? filters}) async {
    try {
      Query query = _firestore.collection('products');

      // Aplica filtros
      if (filters != null) {
        if (filters['status'] != null) {
          query = query.where('status', isEqualTo: filters['status']);
        }
        if (filters['priceRange'] != null) {
          RangeValues range = filters['priceRange'];
          query = query
              .where('price', isGreaterThanOrEqualTo: range.start)
              .where('price', isLessThanOrEqualTo: range.end);
        }
      }

      final QuerySnapshot snapshot = await query.get();

      final products = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      print('Productos filtrados obtenidos exitosamente: $products');
      return products;
    } catch (e) {
      print('Error al obtener productos filtrados: $e');
      throw Exception('Error al obtener productos filtrados: $e');
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required double price,
    required int stock,
    required String description,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'name': name,
        'price': price,
        'stock': stock,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Producto actualizado exitosamente.');
    } catch (e) {
      print('Error al actualizar el producto: $e');
      throw Exception('Error al actualizar el producto: $e');
    }
  }

  Future<void> updateProductImages({
    required String productId,
    required List<String> images,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'images': images,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Imágenes del producto actualizadas exitosamente.');
    } catch (e) {
      print('Error al actualizar las imágenes del producto: $e');
      throw Exception('Error al actualizar las imágenes del producto: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
  try {
    await _firestore.collection('products').doc(productId).delete();
    print('Producto eliminado exitosamente.');
  } catch (e) {
    print('Error al eliminar el producto: $e');
    throw Exception('Error al eliminar el producto: $e');
  }
}


}
