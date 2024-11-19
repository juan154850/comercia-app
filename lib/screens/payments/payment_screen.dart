import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/services/address_service.dart';
import 'package:myapp/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final AddressService _addressService = AddressService();
  final PaymentService _paymentService = PaymentService();

  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  String? _selectedAddress;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _loadPaymentMethods();
  }

  Future<void> _loadAddresses() async {
    List<Map<String, dynamic>> addresses =
        await _addressService.getUserAddresses();
    setState(() {
      _addresses = addresses;
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.first['direction'];
      }
    });
  }

  Future<void> _loadPaymentMethods() async {
    List<Map<String, dynamic>> methods =
        await _paymentService.getUserPaymentMethods();
    setState(() {
      _paymentMethods = methods;
      if (_paymentMethods.isNotEmpty) {
        _selectedPaymentMethod = _paymentMethods.first['cardNumber'];
      }
    });
  }

  Future<void> _addAddress() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const _AddAddressDialog(),
    );

    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _addPaymentMethod() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const _AddPaymentMethodDialog(),
    );

    if (result == true) {
      _loadPaymentMethods();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proceso de pago'),
      ),
      body: SingleChildScrollView(
        // Permite el scroll al abrir el teclado
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Método de entrega',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text('Entrega: Gratis', style: TextStyle(fontSize: 16)),
              const Divider(),
              const Text(
                'Dirección de envío',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              if (_addresses.isEmpty)
                const Text('No tienes direcciones guardadas.'),
              if (_addresses.isNotEmpty)
                Column(
                  children: _addresses.map((address) {
                    return RadioListTile(
                      title: Text(address['direction']),
                      subtitle: Text(
                          '${address['city']}, ${address['state']} - ${address['postalCode']}'),
                      value: address['direction'],
                      groupValue: _selectedAddress,
                      onChanged: (value) {
                        setState(() {
                          _selectedAddress = value as String;
                        });
                      },
                    );
                  }).toList(),
                ),
              TextButton.icon(
                onPressed: _addAddress,
                icon: const Icon(Icons.add),
                label: const Text('Agregar nueva dirección'),
              ),
              const Divider(),
              const Text(
                'Método de pago',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              if (_paymentMethods.isEmpty)
                const Text('No tienes métodos de pago guardados.'),
              if (_paymentMethods.isNotEmpty)
                Column(
                  children: _paymentMethods.map((method) {
                    return RadioListTile(
                      title: Text(
                          '**** **** **** ${method['cardNumber'].substring(method['cardNumber'].length - 4)}'),
                      subtitle: Text('${method['cardHolderName']}'),
                      value: method['cardNumber'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value as String;
                        });
                      },
                    );
                  }).toList(),
                ),
              TextButton.icon(
                onPressed: _addPaymentMethod,
                icon: const Icon(Icons.add),
                label: const Text('Agregar nuevo método de pago'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Procesar pago o continuar al siguiente paso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pago realizado con éxito')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: const Color(0xFF007AFF),
                ),
                child:
                    const Text('Pagar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPaymentMethodDialog extends StatefulWidget {
  const _AddPaymentMethodDialog({super.key});

  @override
  State<_AddPaymentMethodDialog> createState() =>
      _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<_AddPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};
  late TextEditingController _expiryDateController;

  @override
  void initState() {
    super.initState();
    _expiryDateController = TextEditingController();
    _expiryDateController.addListener(() {
      final text = _expiryDateController.text.replaceAll('/', '');

      // Si el texto tiene más de 4 caracteres, limitamos la entrada
      if (text.length > 4) {
        _expiryDateController.text = text.substring(0, 4);
        _expiryDateController.selection = TextSelection.collapsed(offset: 4);
        return;
      }

      // Formatear el texto como MM/AA
      String formattedText;
      if (text.length <= 2) {
        formattedText = text; // Solo mes
      } else {
        formattedText =
            '${text.substring(0, 2)}/${text.substring(2)}'; // Mes/Año
      }

      // Actualizar el controlador sin romper la selección del cursor
      _expiryDateController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    });
  }

  @override
  void dispose() {
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo método de pago'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nombre del titular'),
                onSaved: (value) => _formData['cardHolderName'] = value!,
                validator: (value) => value!.isEmpty
                    ? 'Por favor ingresa el nombre del titular'
                    : null,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Número de tarjeta'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (value) => _formData['cardNumber'] = value!,
                validator: (value) => value!.isEmpty
                    ? 'Por favor ingresa el número de tarjeta'
                    : null,
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                    labelText: 'Fecha de expiración (MM/AA)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (value) => _formData['expiryDate'] = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la fecha de expiración';
                  }
                  final regex = RegExp(r'^\d{2}/\d{2}$');
                  if (!regex.hasMatch(value)) {
                    return 'Formato inválido. Usa MM/AA';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (value) => _formData['cvv'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa el CVV' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await PaymentService().addPaymentMethod(
                cardHolderName: _formData['cardHolderName']!,
                cardNumber: _formData['cardNumber']!,
                expiryDate: _formData['expiryDate']!,
                cvv: _formData['cvv']!,
              );
              Navigator.pop(context, true);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog({super.key});

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva dirección'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => _formData['name'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un nombre' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido'),
                onSaved: (value) => _formData['lastName'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un apellido' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección'),
                onSaved: (value) => _formData['direction'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa una dirección' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ciudad'),
                onSaved: (value) => _formData['city'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa una ciudad' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Estado'),
                onSaved: (value) => _formData['state'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un estado' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Código Postal'),
                onSaved: (value) => _formData['postalCode'] = value!,
                validator: (value) => value!.isEmpty
                    ? 'Por favor ingresa un código postal'
                    : null,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Número de teléfono'),
                onSaved: (value) => _formData['phoneNumber'] = value!,
                validator: (value) => value!.isEmpty
                    ? 'Por favor ingresa un número de teléfono'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await AddressService().addAddress(
                name: _formData['name']!,
                lastName: _formData['lastName']!,
                direction: _formData['direction']!,
                city: _formData['city']!,
                state: _formData['state']!,
                postalCode: _formData['postalCode']!,
                phoneNumber: _formData['phoneNumber']!,
              );
              Navigator.pop(context, true);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
