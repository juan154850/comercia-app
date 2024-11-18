import 'package:flutter/material.dart';

class ProductFiltersPage extends StatefulWidget {
  const ProductFiltersPage({super.key});

  @override
  State<ProductFiltersPage> createState() => _ProductFiltersPageState();
}

class _ProductFiltersPageState extends State<ProductFiltersPage> {
  String? _status; // Filtro por estado
  RangeValues _priceRange = const RangeValues(0, 5000); // Rango de precios
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minPriceController.text = _priceRange.start.toInt().toString();
    _maxPriceController.text = _priceRange.end.toInt().toString();
  }

  void _updateRangeFromTextFields() {
    final double? minPrice = double.tryParse(_minPriceController.text);
    final double? maxPrice = double.tryParse(_maxPriceController.text);

    if (minPrice != null && maxPrice != null && minPrice <= maxPrice) {
      setState(() {
        _priceRange = RangeValues(minPrice, maxPrice);
      });
    }
  }

  void _updateTextFieldsFromRange() {
    _minPriceController.text = _priceRange.start.toInt().toString();
    _maxPriceController.text = _priceRange.end.toInt().toString();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros de productos'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null); // Limpiar filtros
            },
            child: const Text(
              'Limpiar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estado del producto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Ambos')),
                  DropdownMenuItem(value: 'Nuevo', child: Text('Nuevo')),
                  DropdownMenuItem(value: 'Usado', child: Text('Usado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Seleccione un estado',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rango de precios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mínimo',
                        prefixText: '\$',
                      ),
                      onChanged: (_) => _updateRangeFromTextFields(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Máximo',
                        prefixText: '\$',
                      ),
                      onChanged: (_) => _updateRangeFromTextFields(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 5000,
                divisions: 50,
                labels: RangeLabels(
                  '\$${_priceRange.start.toInt()}',
                  '\$${_priceRange.end.toInt()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                    _updateTextFieldsFromRange();
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'status': _status,
                      'priceRange': _priceRange,
                    });
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
