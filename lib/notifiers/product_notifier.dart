import 'package:flutter/foundation.dart';

class ProductNotifier extends ValueNotifier<bool> {
  ProductNotifier() : super(false);

  void notify() {
    value = !value; // Cambia el valor para notificar a los listeners
  }
}

final productNotifier = ProductNotifier(); // Instancia global
