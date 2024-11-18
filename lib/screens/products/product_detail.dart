import 'package:flutter/material.dart';
import 'package:myapp/services/comments_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product; // Recibe el producto como parámetro

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  final CommentsService _commentsService =
      CommentsService(); // Instancia del servicio
  List<Map<String, dynamic>> _comments = []; // Lista de comentarios
  bool _isLoadingComments = true; // Controla el estado de carga de comentarios
  int _currentImageIndex = 0; // Índice de la imagen actualmente mostrada

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

  @override
  Widget build(BuildContext context) {
    final product = widget.product; // Accede al producto pasado como parámetro
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
            // Imagen principal del producto
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Forma en la que se generan las estrellas dinamicas...
                      Row(
                        children: List.generate(
                          (() {
                            if (product['rateAverage'] != null) {
                              if (product['rateAverage'] is int) {
                                return product['rateAverage'];
                              } else if (product['rateAverage'] is double) {
                                return product['rateAverage'].round();
                              }
                            }
                            return 4; // Valor por defecto
                          })(),
                          (index) => const Icon(Icons.star,
                              color: Colors.amber, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (() {
                          if (product['rateAverage'] != null) {
                            if (product['rateAverage'] is int) {
                              return product['rateAverage'].toString();
                            } else if (product['rateAverage'] is double) {
                              return product['rateAverage'].toStringAsFixed(1);
                            }
                          }
                          return '0.0'; // Valor por defecto
                        })(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                        onPressed: stock > 0
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Añadido al carrito'),
                                  ),
                                );
                              }
                            : null,
                        child: const Text('Añadir al carrito', style: TextStyle(color: Color(0xFF007AFF)),),
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
                                            Row(
                                              children: List.generate(
                                                comment['rate'] ?? 0,
                                                (index) => const Icon(
                                                  Icons.star,
                                                  color: Colors.blue,
                                                  size: 16,
                                                ),
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
