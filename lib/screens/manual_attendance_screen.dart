import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../utils/constants.dart';

class ManualAttendanceScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ManualAttendanceScreen({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final AttendanceService _service = AttendanceService();
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() async {
    var list = await _service.getStudentsByClass(widget.classId);
    if (mounted) {
      setState(() {
        _students = list;
        _isLoading = false;
      });
    }
  }

  void _markPresent(String studentId, int index) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Marking...")));

    bool success = await _service.markManualAttendance(
      studentId,
      widget.classId,
      'PRESENT',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        setState(() {
          _students[index]['marked'] = true; // Visual feedback
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to mark.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manual: ${widget.className}"),
        backgroundColor: AppColors.primaryRed,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
          ? const Center(child: Text("No students found in this class."))
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                bool isMarked = student['marked'] == true;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isMarked ? Colors.green : Colors.grey,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(student['name'] ?? 'Unknown'),
                  subtitle: Text("ID: ${student['school_id'] ?? 'N/A'}"),
                  trailing: isMarked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: () =>
                              _markPresent(student['id'].toString(), index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                          ),
                          child: const Text(
                            "Mark Present",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                );
              },
            ),
    );
  }
}
