import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart';
import '../widgets/logout_dialog.dart'; // Import the dialog we just made

class GatemanHistoryScreen extends StatefulWidget {
  const GatemanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<GatemanHistoryScreen> createState() => _GatemanHistoryScreenState();
}

class _GatemanHistoryScreenState extends State<GatemanHistoryScreen> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Load offline scans from the local database
  void _loadHistory() async {
    final data = await DatabaseHelper.instance.getAllUnsynced();
    setState(() {
      // Show newest first (reversed)
      _records = data.reversed.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan History (Offline)",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // LOGOUT BUTTON IN APP BAR
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => showLogoutDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? const Center(child: Text("No scanned records yet."))
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                bool isCheckIn = record['type'] == 'in';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCheckIn
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      child: Icon(
                        isCheckIn ? Icons.login : Icons.logout,
                        color: isCheckIn ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text("NFC ID: ${record['nfc_tag']}"),
                    subtitle: Text(
                      "Time: ${record['timestamp'].toString().split('.')[0]}",
                    ),
                    trailing: const Icon(
                      Icons.cloud_off,
                      color: Colors.grey,
                    ), // Icon showing it's offline
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHistory, // Refresh list
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
