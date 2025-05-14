import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentController with ChangeNotifier {
  bool _isLoading = false;
  List<Payment> _payments = [];
  String _filter = 'all'; // 'all', 'completed', 'failed'

  bool get isLoading => _isLoading;
  List<Payment> get payments => _filter == 'all' 
      ? _payments 
      : _payments.where((p) => p.status == _filter).toList();
  String get filter => _filter;

  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - replace with actual API call
    _payments = [
      Payment(
        id: 'pay_1',
        serviceId: 'svc_1',
        serviceName: 'Plumbing Repair',
        providerId: 'prov_1',
        providerName: 'John Plumbing',
        customerId: 'cust_1',
        customerName: 'Alice Johnson',
        amount: 120.50,
        paymentDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'completed',
        paymentMethod: 'card',
        transactionId: 'txn_12345',
        receiptUrl: 'https://example.com/receipts/12345',
      ),
      Payment(
        id: 'pay_2',
        serviceId: 'svc_2',
        serviceName: 'Electrical Wiring',
        providerId: 'prov_2',
        providerName: 'ElectroFix',
        customerId: 'cust_1',
        customerName: 'Alice Johnson',
        amount: 85.75,
        paymentDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        paymentMethod: 'bank_transfer',
        transactionId: 'txn_12346',
        receiptUrl: 'https://example.com/receipts/12346',
      ),
      Payment(
        id: 'pay_3',
        serviceId: 'svc_3',
        serviceName: 'Painting Service',
        providerId: 'prov_3',
        providerName: 'Color Masters',
        customerId: 'cust_1',
        customerName: 'Alice Johnson',
        amount: 200.00,
        paymentDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'failed',
        paymentMethod: 'mobile_money',
        transactionId: 'txn_12347',
        receiptUrl: null,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<Payment> processPayment({
    required String serviceId,
    required String serviceName,
    required String providerId,
    required String providerName,
    required double amount,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        serviceId: serviceId,
        serviceName: serviceName,
        providerId: providerId,
        providerName: providerName,
        customerId: 'current_user_id',
        customerName: 'Current User',
        amount: amount,
        paymentDate: DateTime.now(),
        status: 'completed',
        paymentMethod: paymentMethod,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        receiptUrl: 'https://example.com/receipts/${DateTime.now().millisecondsSinceEpoch}',
      );

      _payments.insert(0, payment);
      _isLoading = false;
      notifyListeners();
      return payment;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setFilter(String status) {
    _filter = status;
    notifyListeners();
  }
}