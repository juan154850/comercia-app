import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/cart/cart_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import "package:myapp/screens/notifications/notifications_screen.dart";
import "package:myapp/screens/profile/profile_screen.dart";
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/products/add_product_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activar App Check en modo debug
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Configurar Crashlytics para capturar errores
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Activar Performance Monitoring
  FirebasePerformance performance = FirebasePerformance.instance;
  await performance.setPerformanceCollectionEnabled(true);

  // Limpia SharedPreferences temporalmente
  await clearSharedPreferences(); // Llama a la función de limpieza aquí

  runApp(const MyApp());
}

// Función para limpiar SharedPreferences
Future<void> clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print("SharedPreferences limpiado."); // Mensaje para confirmar limpieza
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
        '/login': (context) => const LoginScreen(),
        '/forgotPassword': (context) =>
            const LoginScreen(), //pendiente de implementación.
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/addProduct': (context) => const AddProductScreen(),
      },
    );
  }
}
