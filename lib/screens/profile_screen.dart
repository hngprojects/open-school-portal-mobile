import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/attendance_service.dart';
import '../widgets/logout_dialog.dart'; // <--- IMPORT THE DIALOG
// Admin Screens
import 'admin_dashboard.dart';
import 'admin_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userRole = 'student'; // Default safety role

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // Load the saved role (admin, teacher, gateman)
  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'student';
    });
  }

  // Handle Offline Sync
  void _handleSync() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Syncing offline records...")));

    final AttendanceService service = AttendanceService();
    String result = await service.syncOfflineRecords();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result.contains("Synced")
              ? Colors.green
              : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // User Avatar
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryRed,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),

          // Role Badge
          Center(
            child: Chip(
              label: Text(_userRole.toUpperCase()),
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 30),

          // --- STANDARD OPTIONS ---
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Attendance History"),
            onTap: () {
              // Placeholder for personal history if needed
            },
          ),

          // --- SYNC BUTTON (Visible to everyone) ---
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sync, color: Colors.blue),
            title: const Text("Sync Offline Data"),
            subtitle: const Text("Upload records saved while offline"),
            onTap: _handleSync,
          ),

          // --- ADMIN ONLY SECTION ---
          if (_userRole == 'admin') ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 10, bottom: 10),
              child: Text(
                "Admin Controls",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 1. Register Card
            ListTile(
              leading: const Icon(Icons.nfc, color: AppColors.primaryRed),
              title: const Text("Register NFC Cards"),
              subtitle: const Text("Link new cards to students/teachers"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboard(),
                  ),
                );
              },
            ),

            // 2. View History
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.purple),
              title: const Text("View Scan History"),
              subtitle: const Text("See who scanned recently"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminHistoryScreen(),
                  ),
                );
              },
            ),
          ],

          // ---------------------------
          const Divider(),

          // --- LOGOUT (With Confirmation) ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => showLogoutDialog(context), // <--- Calls the new Dialog
          ),
        ],
      ),
    );
  }
}
