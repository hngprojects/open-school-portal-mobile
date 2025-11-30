import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/nfc_service.dart';
import '../services/attendance_service.dart';
import '../utils/constants.dart';
import 'admin_history_screen.dart';
import '../widgets/logout_dialog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.nfc, color: AppColors.primaryRed),
        title: const Text(
          "Admin Panel",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "SchoolBase Admin",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Manage NFC Tags & Records",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const Spacer(),

            // --- CENTER ICON ---
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryRed, width: 4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nfc,
                size: 80,
                color: AppColors.primaryRed,
              ),
            ),

            const Spacer(),

            // --- 1. REGISTER BUTTON (This starts the flow) ---
            _buildMenuButton(
              icon: Icons.app_registration,
              text: "Register NFC Card",
              onTap: () => _showUserSearchSheet(context),
            ),
            const SizedBox(height: 15),

            // --- 2. HISTORY ---
            _buildMenuButton(
              icon: Icons.history,
              text: "Attendance History",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminHistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 15),

            // --- 3. SYNC ---
            _buildMenuButton(
              icon: Icons.sync,
              text: "Sync Offline Data",
              onTap: () async {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Syncing...")));
                String res = await AttendanceService().syncOfflineRecords();
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(res)));
              },
            ),
            const SizedBox(height: 15),

            // --- 4. LOGOUT ---
            _buildMenuButton(
              icon: Icons.logout,
              text: "Logout",
              onTap: () => showLogoutDialog(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 20),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Opens the list of users
  void _showUserSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const UserSearchSheet(),
    );
  }
}

// --- USER SEARCH SHEET ---
class UserSearchSheet extends StatefulWidget {
  const UserSearchSheet({Key? key}) : super(key: key);
  @override
  State<UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<UserSearchSheet> {
  final AdminService _admin = AdminService();
  List<dynamic> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() async {
    setState(() => _isLoading = true);
    var res = await _admin.searchUsers(""); // Get all users
    if (mounted)
      setState(() {
        _users = res;
        _isLoading = false;
      });
  }

  void _showScanPopup(Map<String, dynamic> user) {
    Navigator.pop(context); // Close the list

    // Open the Registration Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ScanDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            "Select Person to Register",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  )
                : _users.isEmpty
                ? const Center(child: Text("No users found in database"))
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (ctx, i) {
                      final u = _users[i];
                      return Card(
                        color: Colors.grey[100],
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryRed,
                            child: Text(
                              (u['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            u['name'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${u['type'].toString().toUpperCase()} • ID: ${u['school_id']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () =>
                              _showScanPopup(u), // <--- CLICK TO REGISTER
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- THE REGISTRATION DIALOG ---
class ScanDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  const ScanDialog({Key? key, required this.user}) : super(key: key);
  @override
  State<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  String _status = "Tap Card to Register";
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _startRegistration();
  }

  void _startRegistration() {
    // 1. Start Scanning
    NfcService().startSession(
      onTagRead: (cardUid) async {
        setState(() => _status = "Card Detected! Linking to User...");

        // 2. Send to Backend: "Link Card UID to User ID"
        String? err = await AdminService().linkCardToUser(
          widget.user['id'].toString(),
          cardUid,
          widget.user['type'].toString(),
        );

        if (mounted) {
          if (err == null) {
            // 3. Success!
            setState(() {
              _success = true;
              _status = "Successfully Registered!";
            });
            Future.delayed(
              const Duration(seconds: 2),
              () => Navigator.pop(context),
            );
          } else {
            setState(() => _status = "Error: $err");
          }
        }
      },
      onError: (err) {
        if (mounted) setState(() => _status = "Scan Error. Try again.");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 350,
        child: Column(
          children: [
            Text(
              _success ? "Success" : "Registering Card",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Assigning to: ${widget.user['name']}",
              style: const TextStyle(color: Colors.grey),
            ),
            const Spacer(),

            // Visual
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _success ? Colors.green : AppColors.primaryRed,
                  width: 4,
                ),
              ),
              child: Icon(
                _success ? Icons.check : Icons.nfc,
                size: 60,
                color: _success ? Colors.green : AppColors.primaryRed,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
            ),
            const Spacer(),

            if (!_success)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    NfcService().stopSession();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
