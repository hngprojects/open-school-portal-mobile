import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../services/nfc_service.dart';
import '../utils/constants.dart';
import '../widgets/logout_dialog.dart';
import 'manual_attendance_screen.dart'; // Ensure this file exists

// ==================================================
// SCREEN 1: THE DASHBOARD (List of Classes)
// ==================================================
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final AttendanceService _service = AttendanceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Classes", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => showLogoutDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _service.getTeacherClasses(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            );
          }

          // 2. Empty or Error State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.class_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No classes assigned.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 3. List of Classes
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, i) {
              final item = snapshot.data![i];

              // Extract data safely
              final String className =
                  item['subject_name'] ?? item['name'] ?? 'Class ${i + 1}';
              final String classCode = item['class_code'] ?? 'CODE';
              final String classId = item['id'].toString();

              return Card(
                elevation: 0,
                color: Colors.grey[100],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryRed,
                    child: Text(
                      className.isNotEmpty ? className[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    className,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text("Code: $classCode"),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // Navigate to Scanning Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClassAttendanceScreen(
                          classId: classId,
                          className: className,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================================================
// SCREEN 2: THE SCANNER (Mark Attendance)
// ==================================================
class ClassAttendanceScreen extends StatefulWidget {
  final String classId;
  final String className;
  const ClassAttendanceScreen({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  State<ClassAttendanceScreen> createState() => _ClassAttendanceScreenState();
}

class _ClassAttendanceScreenState extends State<ClassAttendanceScreen> {
  final NfcService _nfcService = NfcService();
  final AttendanceService _service = AttendanceService();

  String _status = "Ready to Scan";
  Color _statusColor = Colors.black;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() async {
    bool available = await _nfcService.isAvailable();
    if (!available) {
      if (mounted) setState(() => _status = "NFC not available on device");
      return;
    }

    _nfcService.startSession(
      onTagRead: (tagId) async {
        if (_isProcessing) return;

        // 1. Update UI
        setState(() {
          _isProcessing = true;
          _status = "Marking Present...";
          _statusColor = Colors.orange;
        });

        // 2. Call the Service Method
        String? error = await _service.markClassAttendance(
          widget.classId,
          tagId,
        );

        // 3. Handle Result
        if (mounted) {
          setState(() {
            if (error == null) {
              _status = "Success!";
              _statusColor = Colors.green;
            } else {
              _status = error;
              _statusColor = Colors.red;
            }
          });

          // 4. Auto Reset
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _status = "Ready to Scan Next";
                _statusColor = Colors.black;
                _isProcessing = false;
              });
            }
          });
        }
      },
      onError: (e) {
        // Silent error handling for read failures
      },
    );
  }

  @override
  void dispose() {
    _nfcService.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Spacer(),

          // --- SCANNER VISUAL ---
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _statusColor, width: 4),
            ),
            child: Icon(
              _statusColor == Colors.green ? Icons.check : Icons.nfc,
              size: 80,
              color: _statusColor,
            ),
          ),
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Tap student card to mark attendance",
            style: TextStyle(color: Colors.grey),
          ),

          const Spacer(),

          // --- MANUAL FALLBACK ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.grey[50],
            child: Column(
              children: [
                const Text(
                  "Student forgot card?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text("Open Manual List"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(color: AppColors.primaryRed),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualAttendanceScreen(
                            classId: widget.classId,
                            className: widget.className,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
