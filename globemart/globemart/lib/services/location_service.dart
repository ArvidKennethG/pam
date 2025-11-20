import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  // Ambil posisi user (lat,lng) — meminta permission jika perlu
  static Future<Position?> getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return pos;
    } catch (e) {
      return null;
    }
  }

  // Reverse geocode via Nominatim (OpenStreetMap) to get an address/city
  static Future<String> reverseGeocode(Position pos) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${pos.latitude}&lon=${pos.longitude}&accept-language=en');
      final resp = await http.get(url, headers: {'User-Agent': 'GlobeMartApp/1.0'});

      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(resp.body);
        final address = body['address'] as Map<String, dynamic>?;
        if (address != null) {
          // Try various fields to produce a friendly location string
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'] ??
              address['state'];
          final country = address['country'];
          if (city != null && country != null) {
            return '$city, $country';
          } else if (country != null) {
            return country;
          }
        }
      }
      // fallback: return coordinates
      return 'Lat:${pos.latitude.toStringAsFixed(4)}, Lng:${pos.longitude.toStringAsFixed(4)}';
    } catch (e) {
      return 'Lat:${pos.latitude.toStringAsFixed(4)}, Lng:${pos.longitude.toStringAsFixed(4)}';
    }
  }

  // Convenience: get friendly location or "Unknown Location"
  static Future<String> getFriendlyLocation() async {
    final pos = await getPosition();
    if (pos == null) return 'Unknown Location';
    return await reverseGeocode(pos);
  }
}
