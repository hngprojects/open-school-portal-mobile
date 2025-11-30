import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_helper.dart';

class AttendanceService {
  final String baseUrl = "https://api.staging.borjigin.emerj.net";

  // --- HELPER: CHECK INTERNET ---
  Future<bool> _isConnected() async {
    var result = await (Connectivity().checkConnectivity());
    return result != ConnectivityResult.none;
  }

  // --- 1. GET GATE HISTORY (For Teacher View) ---
  Future<List<dynamic>> getGateHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      // Fetch all attendance logs
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/attendance'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> logs = [];
        // Handle pagination wrapper
        if (data is Map && data['data'] != null)
          logs = data['data'];
        else if (data is List)
          logs = data;

        // OPTIONAL: Filter client-side for only 'GATE' type if API returns everything
        // For now, we return everything so the teacher sees all scans
        return logs;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 2. GET STUDENTS IN CLASS (For Manual List) ---
  Future<List<dynamic>> getStudentsByClass(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      // Endpoint to get students. Adjust if your API uses /classes/{id}/students
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/students?class_id=$classId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) return data['data'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 3. SUBMIT MANUAL ATTENDANCE (Single Student) ---
  Future<bool> markManualAttendance(
    String studentId,
    String classId,
    String status,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/attendance'), // General attendance endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'student_id': studentId,
          'class_id': classId,
          'status': status, // 'PRESENT', 'ABSENT', 'LATE'
          'type': 'MANUAL', // Flag to show it wasn't NFC
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // --- 4. TEACHER: GET CLASSES ---
  Future<List<dynamic>> getTeacherClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/classes'), // Or /classes/teacher
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- 5. GATEMAN: MARK GATE (Existing logic) ---
  Future<Map<String, dynamic>> markGateAttendance(
    String nfcTagId,
    String type,
  ) async {
    if (!(await _isConnected())) {
      await DatabaseHelper.instance.insertAttendance(nfcTagId, type);
      return {
        'success': true,
        'message': 'Saved Offline.',
        'user_name': 'Offline Record',
      };
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/attendance/gate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('auth_token')}',
        },
        body: jsonEncode({'nfc_tag': nfcTagId, 'type': type}),
      );
      final data = jsonDecode(response.body);
      return (response.statusCode == 200 || response.statusCode == 201)
          ? {
              'success': true,
              'message': data['message'],
              'user_name': data['user_name'],
            }
          : {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      await DatabaseHelper.instance.insertAttendance(nfcTagId, type);
      return {'success': true, 'message': 'Connection Failed. Saved Offline.'};
    }
  }

  // --- 6. SYNC ---
  Future<String> syncOfflineRecords() async {
    if (!(await _isConnected())) return "No Internet";
    List<Map<String, dynamic>> records = await DatabaseHelper.instance
        .getAllUnsynced();
    if (records.isEmpty) return "No records to sync";
    int count = 0;
    for (var record in records) {
      // Simple sync logic for gate logs
      var res = await markGateAttendance(record['nfc_tag'], record['type']);
      if (res['success'] && res['message'] != 'Saved Offline') {
        await DatabaseHelper.instance.deleteRecord(record['id']);
        count++;
      }
    }
    return "Synced $count records.";
  }

  Future<String?> markClassAttendance(String classId, String tagId) async {}
}
