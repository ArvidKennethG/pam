import 'dart:convert';
import 'package:http/http.dart' as http;

class WorldTimeService {
  static Future<String> getTime(String timeZone) async {
    final url = Uri.parse("https://timeapi.io/api/Time/current/zone?timeZone=$timeZone");

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['dateTime']; // example: 2024-02-08T18:21:12
      } else {
        return DateTime.now().toIso8601String();
      }
    } catch (e) {
      return DateTime.now().toIso8601String(); // fallback
    }
  }
}
