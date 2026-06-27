# Ultraner Dart SDK

One API for payments across Africa: mobile money, cards, PayPal and wallets. Live in Tanzania and Rwanda, expanding across the continent. Works with Dart and Flutter.

- Docs: https://ultraner.com/docs
- OpenAPI: https://ultraner.com/openapi.json
- For AI: https://ultraner.com/ai

## Install

```yaml
dependencies:
  ultraner: ^0.1.0
```

## Usage

```dart
import 'package:ultraner/ultraner.dart';

void main() async {
  final ultraner = Ultraner('sk_live_...');

  // Charge a mobile-money wallet
  final payment = await ultraner.createMobileMoney({
    'amount': 5000,
    'currency': 'TZS',
    'provider': 'Vodacom',
    'accountNumber': '255700000000',
    'externalId': 'order_1001',
  });

  // Poll status
  final status = await ultraner.paymentStatus(payment['reference']);
  print(status['status']);

  await ultraner.wallet();
  await ultraner.transactions(page: 1, limit: 20);

  ultraner.close();
}
```

Errors throw `UltranerException` with `.status` and `.code`.

## License

MIT
