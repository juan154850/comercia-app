// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/comments_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  final CommentsService _commentsService = CommentsService();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final List<dynamic> commentRefs = widget.product['comments'] ?? [];
    if (commentRefs.isEmpty) {
      setState(() {
        _isLoadingComments = false;
      });
      return;
    }

    try {
      List<Map<String, dynamic>> comments =
          await _commentsService.getComments(commentRefs);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      print('Error al cargar comentarios: $e');
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _addToCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Obtener el carrito actual como una lista de cadenas JSON
    List<String> cart = prefs.getStringList('cart') ?? [];

    // Buscar el producto existente
    int existingProductIndex = cart.indexWhere((item) {
      final decodedItem = jsonDecode(item); 
      return decodedItem['id'] == widget.product['id'];
    });

    if (existingProductIndex != -1) {
      // Incrementar la cantidad si el producto ya está en el carrito
      final existingProduct = jsonDecode(cart[existingProductIndex]);

      // Validar que no se exceda el stock disponible
      if ((existingProduct['quantity'] + _quantity) > widget.product['stock']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No puedes añadir más de ${widget.product['stock']} unidades al carrito'),
          ),
        );
        return;
      }

      existingProduct['quantity'] += _quantity;
      cart[existingProductIndex] = jsonEncode(existingProduct);
    } else {
      // Validar que no se exceda el stock disponible al añadir un nuevo producto
      if (_quantity > widget.product['stock']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No puedes añadir más de ${widget.product['stock']} unidades al carrito'),
          ),
        );
        return;
      }

      // Agregar el producto al carrito
      cart.add(jsonEncode({
        'id': widget.product['id'],
        'name': widget.product['name'],
        'price': widget.product['price'],
        'images': widget.product['images']?.isNotEmpty == true
            ? widget.product['images'][0]
            : null,
        'quantity': _quantity,
      }));
    }

    // Guardar el carrito actualizado como lista de cadenas JSON
    await prefs.setStringList('cart', cart);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto añadido al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final stock = product['stock'] ?? 0;
    final images = product['images'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Detalle del producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1} / ${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Nombre no disponible',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product['price'] ?? '0'}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            onPressed: _quantity < stock
                                ? () {
                                    setState(() {
                                      _quantity++;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: stock > 0 ? _addToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              stock > 0 ? const Color(0xFF007AFF) : Colors.grey,
                        ),
                        child: const Text(
                          'Añadir al carrito',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'] ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Comentarios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingComments
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _comments.isEmpty
                          ? const Text('No hay comentarios aún.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                final user = comment['user'] ?? {};
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          user['profile_image'] ??
                                              'https://via.placeholder.com/150',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['firstName'] ?? 'Usuario',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment['comment'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
