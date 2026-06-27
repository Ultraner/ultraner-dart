import 'package:ultraner/ultraner.dart';

/// Minimal example of charging a mobile-money wallet with the Ultraner SDK.
Future<void> main() async {
  final ultraner = Ultraner('sk_live_...');

  final payment = await ultraner.createMobileMoney({
    'amount': 5000,
    'currency': 'TZS',
    'provider': 'Vodacom',
    'accountNumber': '255700000000',
    'externalId': 'order_1001',
  });
  print('reference: ${payment['reference']}  status: ${payment['status']}');

  final status = await ultraner.paymentStatus(payment['reference'] as String);
  print('status: ${status['status']}');

  ultraner.close();
}
