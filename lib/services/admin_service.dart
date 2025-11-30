import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  final String baseUrl = "https://api.staging.borjigin.emerj.net";

  // Search
  Future<List<dynamic>> searchUsers(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return [];
    List<dynamic> allResults = [];

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final responses = await Future.wait([
        http.get(
          Uri.parse('$baseUrl/api/v1/students?search=$query'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$baseUrl/api/v1/teachers?search=$query'),
          headers: headers,
        ),
      ]);
      _processResponse(responses[0], 'student', allResults);
      _processResponse(responses[1], 'teacher', allResults);
      return allResults;
    } catch (e) {
      return [];
    }
  }

  // --- LINK CARD (The missing part) ---
  Future<String?> linkCardToUser(
    String userId,
    String nfcTagId,
    String userType,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    try {
      String endpoint = userType == 'teacher' ? 'teachers' : 'students';
      final response = await http.patch(
        Uri.parse('$baseUrl/api/v1/$endpoint/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nfc_id': nfcTagId}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) return null;
      return "Failed to link card.";
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  void _processResponse(
    http.Response response,
    String type,
    List<dynamic> list,
  ) {
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> raw = (decoded is Map && decoded['data'] != null)
          ? decoded['data']
          : (decoded is List ? decoded : []);
      for (var item in raw) {
        list.add({
          'id': item['id'],
          'name': item['first_name'] != null
              ? "${item['first_name']} ${item['last_name']}"
              : (item['name'] ?? 'Unknown'),
          'school_id': item['email'] ?? 'N/A',
          'type': type,
        });
      }
    }
  }
}
