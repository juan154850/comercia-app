// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/notifiers/product_notifier.dart';
import 'package:myapp/screens/products/product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = []; // Lista de productos
  bool _isLoading = true; // Estado de carga
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    productNotifier.addListener(() {
      _fetchProducts();
    });
  }

  @override
  void dispose() {
    productNotifier.removeListener(() {
      _fetchProducts();
    });
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      List<Map<String, dynamic>> products =
          await _productService.getAllProducts();
      setState(() {
        _products = products;
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar los productos: $e';
      });
    }
  }

  // Método para manejar la navegación desde el BottomNavigationBar
  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    } else if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/cart');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/notifications');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos publicados'),
        centerTitle: true,
        toolbarHeight: 100.0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Indicador de carga
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: product['images'] != null &&
                                        product['images'].isNotEmpty
                                    ? Image.network(
                                        product['images'][0],
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Text('Sin imagen'),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product['name'] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${product['price'] ?? '0'}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: product['status'] == 'Nuevo'
                                          ? Colors.blue[100]
                                          : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      product['status'] ?? 'Desconocido',
                                      style: TextStyle(
                                        color: product['status'] == 'Nuevo'
                                            ? Colors.blue[800]
                                            : Colors.orange[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addProduct');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mi Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
