// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    print("Intentando subir la imagen a la ruta: products/$userId/$timestamp.jpg");

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


}