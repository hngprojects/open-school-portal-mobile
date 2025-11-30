import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminHistoryScreen extends StatelessWidget {
  const AdminHistoryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: const Center(child: Text("History Feature Coming Soon")),
    );
  }
}
