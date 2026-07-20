/// Ultraner Dart SDK
/// One API for payments across Africa: mobile money, cards, PayPal, wallets.
/// Docs: https://ultraner.com/docs  ·  Spec: https://ultraner.com/openapi.json
library ultraner;

import 'dart:convert';
import 'dart:io';

/// Thrown for non-2xx API responses.
class UltranerException implements Exception {
  final String message;
  final String code;
  final int status;
  UltranerException(this.message, {this.code = 'ERROR', this.status = 0});
  @override
  String toString() => 'UltranerException: $message ($code, $status)';
}

/// Ultraner API client.
class Ultraner {
  final String apiKey;
  final String baseUrl;
  final Duration timeout;
  final HttpClient _http;

  Ultraner(
    this.apiKey, {
    this.baseUrl = 'https://api.ultraner.com',
    this.timeout = const Duration(seconds: 30),
    HttpClient? httpClient,
  }) : _http = httpClient ?? HttpClient() {
    if (apiKey.isEmpty) {
      throw ArgumentError('Ultraner: an API key is required.');
    }
  }

  Future<dynamic> request(String method, String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final req = await _http.openUrl(method, uri);
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    // Ultraner API keys authenticate via X-API-Key (Authorization: Bearer is
    // reserved for user JWTs and would be rejected for a uk_ key).
    req.headers.set('X-API-Key', apiKey);
    if (body != null) {
      req.add(utf8.encode(jsonEncode(body)));
    }
    final res = await req.close().timeout(timeout);
    final text = await res.transform(utf8.decoder).join();
    final dynamic json = text.isNotEmpty ? jsonDecode(text) : <String, dynamic>{};

    if (res.statusCode >= 300) {
      final map = json is Map ? json : const {};
      throw UltranerException(
        (map['message'] as String?) ?? 'Request failed',
        code: (map['code'] as String?) ?? 'ERROR',
        status: res.statusCode,
      );
    }
    if (json is Map && json.containsKey('data')) return json['data'];
    return json;
  }

  // Payments
  Future<dynamic> createMobileMoney(Map<String, dynamic> body) =>
      request('POST', '/v1/payments/express/mno', body);

  Future<dynamic> paymentStatus(String reference) =>
      request('GET', '/v1/payments/express/status/${Uri.encodeComponent(reference)}');

  // Disbursements
  Future<dynamic> createDisbursement(Map<String, dynamic> body) =>
      request('POST', '/v1/disbursements', body);

  // Wallet
  Future<dynamic> wallet() => request('GET', '/v1/wallet');
  Future<dynamic> transfer(Map<String, dynamic> body) => request('POST', '/v1/transfer', body);

  // Transactions
  Future<dynamic> transactions({int? page, int? limit}) {
    final q = <String, String>{};
    if (page != null) q['page'] = '$page';
    if (limit != null) q['limit'] = '$limit';
    final qs = q.isEmpty ? '' : '?${Uri(queryParameters: q).query}';
    return request('GET', '/v1/transactions$qs');
  }

  // Escrow
  Future<dynamic> createEscrow(Map<String, dynamic> body) => request('POST', '/v1/escrow', body);
  Future<dynamic> releaseEscrow(String escrowCode) =>
      request('POST', '/v1/escrow/${Uri.encodeComponent(escrowCode)}/release');

  // PayPal / Stripe
  Future<dynamic> createPaypalOrder(Map<String, dynamic> body) => request('POST', '/paypal/orders', body);
  Future<dynamic> createStripeSession(Map<String, dynamic> body) => request('POST', '/stripe/sessions', body);

  // Checkout sessions, mint a one-time, expiring checkout token (the Stripe
  // checkout.sessions.create parity) without touching the dashboard.
  Future<dynamic> createCheckoutSession(Map<String, dynamic> body) =>
      request('POST', '/v0/checkout/sessions', body);
  Future<dynamic> retrieveCheckoutSession(String token) =>
      request('GET', '/v0/pay/resolve/${Uri.encodeComponent(token)}');

  void close() => _http.close();
}
