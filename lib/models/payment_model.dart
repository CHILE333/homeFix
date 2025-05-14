// lib/models/payment_model.dart
class Payment {
  final String id;
  final String serviceId;
  final String serviceName;
  final String providerId;
  final String providerName;
  final String customerId;
  final String customerName;
  final double amount;
  final DateTime paymentDate;
  final String status; // 'pending', 'completed', 'failed'
  final String paymentMethod; // 'card', 'bank_transfer', 'mobile_money'
  final String? transactionId;
  final String? receiptUrl;

  Payment({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.providerId,
    required this.providerName,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.receiptUrl,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentDate: DateTime.parse(map['paymentDate']),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'card',
      transactionId: map['transactionId'],
      receiptUrl: map['receiptUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerId': providerId,
      'providerName': providerName,
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'receiptUrl': receiptUrl,
    };
  }
}