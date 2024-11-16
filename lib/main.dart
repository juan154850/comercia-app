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
import 'package:flutter_dotenv/flutter_dotenv.dart';




void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FirebasePerformance performance = FirebasePerformance.instance;
  await performance.setPerformanceCollectionEnabled(true);
  runApp(const MyApp());
  // Simulacion de un error.
  // Future.delayed(const Duration(seconds: 2), () {
  //   FirebaseCrashlytics.instance.crash();
  // });
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
        '/addProduct': (context) => const AddProductScreen(),
      },
    );
  }
}
