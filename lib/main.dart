import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './screens/splash_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
// Esta pantalla sería la de login
import './screens/home_screen.dart'; // Esta pantalla sería la home


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
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
