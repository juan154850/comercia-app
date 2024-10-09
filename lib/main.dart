import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:myapp/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import "package:myapp/screens/profile/profile_screen.dart";
import "package:myapp/screens/notifications/notifications_screen.dart";
import 'package:myapp/screens/cart/cart_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comercia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(), 
        '/forgotPassword': (context) => LoginScreen(),  //pendiente de implementación.
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
