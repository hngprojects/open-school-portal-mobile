import 'package:flutter/material.dart';
import 'package:school_base/screens/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/logout_dialog.dart';
// Screens

import 'gateman_screen.dart'; // Gateman Scanner
import 'gateman_history_screen.dart'; // Gateman History
import 'teacher_dashboard.dart'; // Teacher Class List
import 'teacher_gate_history.dart'; // <--- NEW: Replaces Profile for Teacher
import 'profile_screen.dart'; // Admin Profile
import 'login_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isAuthorized = true;
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _setupScreens();
  }

  void _setupScreens() async {
    final prefs = await SharedPreferences.getInstance();
    String role = (prefs.getString('user_role') ?? '').toLowerCase();

    setState(() {
      if (role == 'admin') {
        _screens = [const AdminDashboard(), const ProfileScreen()];
        _navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Admin'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      } else if (role == 'gateman') {
        _screens = [const GatemanScreen(), const GatemanHistoryScreen()];
        _navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ];
      } else if (role == 'teacher') {
        // --- TEACHER NAVIGATION CHANGED HERE ---
        _screens = [
          const TeacherDashboard(),
          const TeacherGateHistory(), // <--- Shows Gate Logs instead of Profile
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'My Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Gate Logs',
          ), // <--- Label Changed
        ];
      } else {
        _isAuthorized = false;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_isAuthorized)
      return const Scaffold(body: Center(child: Text("Access Denied")));

    return Scaffold(
      // Only show AppBar on Teacher/Gateman screens to provide Logout button if needed there
      // (Though we added logout buttons inside the screens themselves)
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
    );
  }
}
