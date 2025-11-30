import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "https://api.staging.borjigin.emerj.net";

  // --- LOGIN FUNCTION ---
  Future<String?> login(String email, String password) async {
    // ============================================================
    // 1. HARDCODED GATEMAN LOGIN (Use this to test immediately)
    // ============================================================
    if (email.trim() == 'gate@school.com' && password == 'gateman1') {
      final prefs = await SharedPreferences.getInstance();
      // We save a fake token and force the role to 'gateman'
      await prefs.setString('auth_token', 'fake-gateman-token-123');
      await prefs.setString('user_role', 'gateman');

      return null; // Return null means "Success!"
    }
    // ============================================================

    // 2. REAL SERVER LOGIN (For everyone else)
    try {
      final url = Uri.parse('$baseUrl/api/v1/auth/login');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Get Token
        String? token = data['access_token']?.toString();
        if (token == null && data['data'] != null) {
          token = data['data']['access_token']?.toString();
        }

        if (token == null) return "Login successful, but no token returned.";

        // Get Role (From API)
        String role = 'student';
        try {
          if (data['user'] != null && data['user']['role'] != null) {
            List<dynamic> roles = data['user']['role'];
            if (roles.isNotEmpty) {
              role = roles.first.toString().toLowerCase();
            }
          }
        } catch (e) {
          print("Error parsing role: $e");
        }

        // Save Data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', role);

        return null; // Success
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return errorData['message']?.toString() ?? 'Login failed.';
        } catch (_) {
          return 'Login failed (${response.statusCode})';
        }
      }
    } catch (e) {
      return 'Connection Error: $e';
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
