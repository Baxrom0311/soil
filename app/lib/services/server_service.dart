import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/soil_reading.dart';

class ServerService {
  final String baseUrl;
  ServerService(this.baseUrl);

  Future<bool> send(SoilReading reading) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/readings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reading.toJson()),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
