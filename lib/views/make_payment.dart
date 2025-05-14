import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MakePaymentScreen extends StatefulWidget {
  final String serviceName;
  final String providerName;
  final double amount;

  const MakePaymentScreen({
    super.key,
    required this.serviceName,
    required this.providerName,
    required this.amount,
  });

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  String _selectedMethod = 'card';
  bool _isProcessing = false;
  bool _paymentSuccess = false;
  double _tipAmount = 0.0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'title': 'Card',
      'icon': Icons.credit_card,
      'color': Colors.blueAccent,
    },
    {
      'id': 'paypal',
      'title': 'PayPal',
      'icon': Icons.payment,
      'color': Colors.blue[800],
    },
    {
      'id': 'bank',
      'title': 'Bank',
      'icon': Icons.account_balance,
      'color': Colors.purple,
    },
  ];

  final List<double> _tipOptions = [0, 5, 10, 15, 20];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
    });
  }

  double get _totalAmount => widget.amount + _tipAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_paymentSuccess) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Info
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.home_repair_service, color: Colors.blueAccent),
                          const SizedBox(width: 12),
                          Expanded(child: Text(widget.serviceName)),
                          Text('\$${widget.amount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blueAccent),
                          const SizedBox(width: 12),
                          Text(widget.providerName),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = method['id']),
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.only(right: index == _paymentMethods.length - 1 ? 0 : 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedMethod == method['id'] 
                                ? method['color'] 
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(method['icon'], color: method['color']),
                            const SizedBox(height: 4),
                            Text(method['title']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Payment Form
              if (_selectedMethod == 'card') _buildCardForm(),
              if (_selectedMethod == 'paypal') _buildPaypalForm(),
              if (_selectedMethod == 'bank') _buildBankForm(),

              const SizedBox(height: 24),

              // Tip Selection
              const Text('Add Tip', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _tipOptions.map((tip) {
                  return ChoiceChip(
                    label: Text(tip == 0 ? 'No tip' : '$tip%'),
                    selected: _tipAmount == tip,
                    onSelected: (selected) => setState(() => _tipAmount = selected ? tip : 0),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '\$${_totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('PAY NOW'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Cardholder Name'),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(labelText: 'Card Number'),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberFormatter(),
          ],
          validator: (value) => value?.replaceAll(' ', '').length != 16 ? 'Invalid card' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(labelText: 'MM/YY'),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardExpiryFormatter(),
                ],
                validator: (value) => value?.length != 5 ? 'Invalid expiry' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) => value?.length != 3 ? 'Invalid CVV' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaypalForm() {
    return const Column(
      children: [
        SizedBox(height: 20),
        Text('You will be redirected to PayPal to complete your payment'),
        SizedBox(height: 20),
        Icon(Icons.payment, size: 50, color: Colors.blue),
      ],
    );
  }

  Widget _buildBankForm() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Account Number'),
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Bank Name'),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);
    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) formatted += ' ';
      formatted += text[i];
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);
    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) formatted += '/';
      formatted += text[i];
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}