import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../utils/constants.dart';
import '../widgets/logout_dialog.dart';

class TeacherGateHistory extends StatefulWidget {
  const TeacherGateHistory({Key? key}) : super(key: key);

  @override
  State<TeacherGateHistory> createState() => _TeacherGateHistoryState();
}

class _TeacherGateHistoryState extends State<TeacherGateHistory> {
  final AttendanceService _service = AttendanceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gate Logs", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => showLogoutDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _service.getGateHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No attendance records found today."),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final record = snapshot.data![index];

              // Map API fields (adjust 'user'/'name' based on actual response)
              String name =
                  record['user']?['name'] ?? record['user_name'] ?? 'Student';
              String time = record['created_at'] ?? record['time'] ?? 'N/A';
              String type = record['type'] ?? 'ENTRY'; // IN or OUT

              bool isEntry = type.toString().toUpperCase().contains('IN');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isEntry
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Icon(
                      isEntry ? Icons.login : Icons.logout,
                      color: isEntry ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(time),
                  trailing: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isEntry ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
