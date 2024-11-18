// ignore_for_file: use_build_context_synchronously

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/screens/products/update_product.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  int _selectedIndex = 3;
  late Trace _buildTrace;

  // Variables para los datos del perfil
  String firstName = '';
  String lastName = '';
  String phone = '';
  String profileImageUrl = '';
  List<Map<String, dynamic>> userProducts =
      []; // Lista de productos del usuario
  bool _isLoadingProducts = true; // Controla el estado de carga de productos

  @override
  void initState() {
    super.initState();
    _buildTrace = FirebasePerformance.instance.newTrace('profile_screen_build');
    _buildTrace.start();
    _fetchUserData();
    _fetchUserProducts();
  }

  @override
  void dispose() {
    _buildTrace.stop();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final userData = await _userService.getUserData();
    if (userData != null) {
      setState(() {
        firstName = userData['firstName'] ?? '';
        lastName = userData['lastName'] ?? '';
        phone = userData['phone'] ?? '';
        profileImageUrl = userData['profile_image'] ?? '';
      });
    }
  }

  Future<void> _fetchUserProducts() async {
    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) {
        print('No user is logged in');
        return;
      }

      final products = await _productService.getAllProducts();

      setState(() {
        // Filtrar solo productos creados por el usuario actual
        userProducts = products.where((p) => p['userId'] == userId).toList();
        _isLoadingProducts = false;
      });
    } catch (e) {
      print('Error al cargar productos del usuario: $e');
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi cuenta'),
          toolbarHeight: 100.0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: 'Perfil'),
              Tab(text: 'Configuración'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Hola, $firstName',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Productos publicados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _isLoadingProducts
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : userProducts.isEmpty
                          ? const Center(
                              child: Text('No tienes productos publicados.'),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: userProducts.length,
                              itemBuilder: (context, index) {
                                final product = userProducts[index];
                                return GestureDetector(
                                  onTap: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProductPage(product: product),
                                      ),
                                    );
                                    if (updated == true) {
                                      _fetchUserProducts(); // Recarga los productos al regresar
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        Text(
                                          '\$${product['price'] ?? '0.0'}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Hola, $firstName',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('Historial de transacciones'),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.rate_review_outlined),
                    title: const Text('Reseñas'),
                    onTap: () {},
                  ),
                  const Divider(),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Color(0xFF007AFF)),
                      ),
                    ),
                    onPressed: () => _signOut(context),
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Color(0xFF007AFF)),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      ),
    );
  }
}
