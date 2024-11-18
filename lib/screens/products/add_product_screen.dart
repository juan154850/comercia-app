// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/notifiers/product_notifier.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final ProductService _productService = ProductService();

  String? _status;
  final List<File> _selectedImages = [];
  final List<String> _imageUrls = [];

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Subir cada imagen seleccionada a Firebase Storage
      for (File image in _selectedImages) {
        try {
          String imageUrl = await _productService.uploadImage(image);
          _imageUrls.add(imageUrl);
        } catch (e) {
          print('Error al subir la imagen: $e');
        }
      }

      // Si no hay URLs de imágenes, no se envía el producto
      if (_imageUrls.isEmpty) {
        print('No se pudo subir ninguna imagen.');
        return;
      }

      // Agregar el producto a Firestore con las URLs de imágenes
      final name = _nameController.text;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final stock = int.tryParse(_stockController.text) ?? 0;
      final description = _descriptionController.text;
      final status = _status ?? 'Nuevo';

      await _productService.addProduct(
          name: name,
          price: price,
          description: description,
          images: _imageUrls,
          status: status,
          stock: stock);
      productNotifier.notify();
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _selectedImages.add(imageFile); // Guardar solo el archivo local
      });
    } else {
      print("No se seleccionó ninguna imagen.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creación de nuevo producto'),
        centerTitle: true,
        //hacer que tenga un margen top
        toolbarHeight: 100.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    labelStyle: TextStyle(fontSize: 20)),
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es requerido'
                    : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                    labelText: 'Estado del producto',
                    labelStyle: TextStyle(fontSize: 20)),
                items: const [
                  DropdownMenuItem(value: 'Nuevo', child: Text('Nuevo')),
                  DropdownMenuItem(value: 'Usado', child: Text('Usado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es requerido'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(fontSize: 20)),
                maxLines: null,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es requerido'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        labelStyle: TextStyle(fontSize: 20),
                        hintText:
                            '\$500', // Texto de fondo para indicar el formato esperado
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Este campo es requerido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16), // Espacio entre los dos campos
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        labelStyle: TextStyle(fontSize: 20),
                        hintText:
                            '2', // Texto de fondo para indicar el formato esperado
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Este campo es requerido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Color(0xFF007AFF)),
                  ),
                ),
                onPressed: _pickImage,
                child: const Text(
                  'Seleccionar Imagenes',
                  style: TextStyle(color: Color(0xFF007AFF)),
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages
                      .map((file) => Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ))
                      .toList(),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Color(0xFF007AFF)),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Crear Producto',
                  style: TextStyle(color: Color(0xFF007AFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
