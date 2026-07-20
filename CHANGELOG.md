# Changelog

## 0.2.0

- Add checkout sessions: createCheckoutSession / retrieveCheckoutSession (POST /v0/checkout/sessions).
- Fix authentication: send the API key as X-API-Key (was Authorization: Bearer, which the gateway rejects for API keys).

## 0.1.0

- Initial release: Ultraner Dart SDK for payments across Africa (mobile money, cards, PayPal, wallets).
