import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Endpoint yang kamu berikan (API key sudah ada di URL)
  static const String _base = 'https://v6.exchangerate-api.com/v6/9ee514d7374850d1999c8c1a/latest/USD';

  // Cache kecil untuk menghindari panggilan berulang dalam 1 session
  static Map<String, double>? _ratesCache;
  static DateTime? _cacheTime;

  // Ambil rates (USD base)
  static Future<Map<String, double>> fetchRates() async {
    // simple cache selama 10 menit
    if (_ratesCache != null && _cacheTime != null) {
      final diff = DateTime.now().difference(_cacheTime!);
      if (diff.inMinutes < 10) {
        return _ratesCache!;
      }
    }

    final uri = Uri.parse(_base);
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(resp.body);
      final Map<String, dynamic> rates = body['conversion_rates'] ?? {};
      final Map<String, double> parsed = {};
      rates.forEach((k, v) {
        parsed[k] = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
      });

      _ratesCache = parsed;
      _cacheTime = DateTime.now();
      return parsed;
    } else {
      throw Exception('Failed to fetch exchange rates (${resp.statusCode})');
    }
  }

  // Konversi dari amount (diasumsikan USD) ke currency target
  static Future<double> convertFromUSD(double amountUsd, String toCurrency) async {
    final rates = await fetchRates();
    if (!rates.containsKey(toCurrency)) {
      throw Exception('Currency $toCurrency not available in rates');
    }
    final rate = rates[toCurrency]!;
    return amountUsd * rate;
  }
}
