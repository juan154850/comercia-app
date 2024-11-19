// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/services/address_service.dart';
import 'package:myapp/services/payment_service.dart';
import 'package:myapp/screens/payments/review_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double orderTotal; // Recibir el total del carrito

  const PaymentScreen({super.key, required this.orderTotal});

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState(); // Implementa createState
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
        title: const Text('Pagar'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('MÉTODO DE ENVÍO'),
            _buildDeliveryMethod(context),
            const SizedBox(height: 16),
            _buildSectionTitle('DIRECCIÓN DE ENVÍO'),
            _buildAddressSection(context),
            const SizedBox(height: 16),
            _buildSectionTitle('FORMA DE PAGO'),
            _buildPaymentSection(context),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (_selectedAddress != null && _selectedPaymentMethod != null) {
              final selectedAddress = _addresses.firstWhere(
                (address) => address['direction'] == _selectedAddress,
                orElse: () => {},
              );

              final selectedPaymentMethod = _paymentMethods.firstWhere(
                (method) => method['cardNumber'] == _selectedPaymentMethod,
                orElse: () => {},
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewScreen(
                    addressName:
                        '${selectedAddress['name']} ${selectedAddress['lastName']}',
                    addressDetails:
                        '${selectedAddress['direction']}, ${selectedAddress['city']}, ${selectedAddress['state']} - ${selectedAddress['postalCode']}',
                    phoneNumber: selectedAddress['phoneNumber'] ?? '',
                    paymentMethod:
                        'Credit Card ending ****${selectedPaymentMethod['cardNumber'].substring(selectedPaymentMethod['cardNumber'].length - 4)}',
                    orderTotal:
                        widget.orderTotal, // Usa el valor dinámico del carrito
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecciona una dirección y un método de pago'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Pagar - \$${widget.orderTotal.toStringAsFixed(2)}', // Texto dinámico basado en el total
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDeliveryMethod(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Método de entrega',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'GRATIS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true, // Asegura que el menú ocupe todo el ancho
                    hint: const Text('Seleccionar dirección'),
                    value: _selectedAddress,
                    onChanged: (value) {
                      setState(() {
                        _selectedAddress = value;
                      });
                    },
                    items: _addresses.map((address) {
                      return DropdownMenuItem<String>(
                        value: address['direction'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address['direction'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${address['city']}, ${address['state']} - ${address['postalCode']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addAddress,
                tooltip: 'Agregar dirección',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true, // Asegura que el menú ocupe todo el ancho
                    hint: const Text('Seleccionar método de pago'),
                    value: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method['cardNumber'],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '**** **** **** ${method['cardNumber'].substring(method['cardNumber'].length - 4)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              method['cardHolderName'],
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addPaymentMethod,
                tooltip: 'Agregar método de pago',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddPaymentMethodDialog extends StatefulWidget {
  const _AddPaymentMethodDialog();

  @override
  State<_AddPaymentMethodDialog> createState() =>
      _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<_AddPaymentMethodDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Método de Pago'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                leading: Icon(Icons.credit_card, size: 32),
                title: Text(
                  'Tarjeta de crédito',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nombre del titular'),
                onSaved: (value) => _formData['cardHolderName'] = value!,
                validator: (value) => value!.isEmpty
                    ? 'Por favor ingresa el nombre del titular'
                    : null,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Fecha (MM/AA)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _formData['expiryDate'] = value!,
                      validator: (value) => value!.isEmpty
                          ? 'Por favor ingresa la fecha de expiración'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'CVV'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _formData['cvv'] = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Por favor ingresa el CVV' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() => _isLoading = true);
                          try {
                            await PaymentService().addPaymentMethod(
                              cardHolderName: _formData['cardHolderName']!,
                              cardNumber: _formData['cardNumber']!,
                              expiryDate: _formData['expiryDate']!,
                              cvv: _formData['cvv']!,
                            );
                            Navigator.pop(context, true); // Indicar éxito
                          } catch (e) {
                            print('Error al agregar método de pago: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Agregar tarjeta',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog();

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};
  bool _isLoading = false; // Para manejar el estado de carga

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Dirección'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      onSaved: (value) => _formData['name'] = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Por favor ingresa un nombre' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      onSaved: (value) => _formData['lastName'] = value!,
                      validator: (value) => value!.isEmpty
                          ? 'Por favor ingresa un apellido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección'),
                onSaved: (value) => _formData['direction'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa una dirección' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ciudad'),
                onSaved: (value) => _formData['city'] = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa una ciudad' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Estado'),
                      onSaved: (value) => _formData['state'] = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Por favor ingresa un estado' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Código postal'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _formData['postalCode'] = value!,
                      validator: (value) => value!.isEmpty
                          ? 'Por favor ingresa un código postal'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Número de teléfono'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSaved: (value) => _formData['phoneNumber'] = value!,
                validator: (value) => value!.isEmpty
                    ? 'Por favor ingresa un número de teléfono'
                    : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() => _isLoading = true);
                          try {
                            await AddressService().addAddress(
                              name: _formData['name']!,
                              lastName: _formData['lastName']!,
                              direction: _formData['direction']!,
                              city: _formData['city']!,
                              state: _formData['state']!,
                              postalCode: _formData['postalCode']!,
                              phoneNumber: _formData['phoneNumber']!,
                            );
                            Navigator.pop(context, true); // Retornar éxito
                          } catch (e) {
                            print('Error al agregar dirección: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Agregar dirección',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
