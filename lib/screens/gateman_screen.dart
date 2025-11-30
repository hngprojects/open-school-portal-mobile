import 'package:flutter/material.dart';
import '../services/nfc_service.dart';
import '../services/attendance_service.dart';
import '../utils/constants.dart';
import '../widgets/attendance_toggle.dart'; // Your Figma Toggle
import '../widgets/nfc_visual.dart'; // Your Figma Ripple Visual

class GatemanScreen extends StatefulWidget {
  const GatemanScreen({Key? key}) : super(key: key);

  @override
  State<GatemanScreen> createState() => _GatemanScreenState();
}

class _GatemanScreenState extends State<GatemanScreen> {
  // Services
  final NfcService _nfcService = NfcService();
  final AttendanceService _attendanceService = AttendanceService();

  // State Variables
  bool _isCheckIn = true; // true = Check In, false = Check Out

  // Status State
  String _headlineText = "Ready to Scan";
  String _subText = "Tap card to check-in.";
  bool? _isSuccess; // null = idle (show ripples), true = success, false = error
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startNfcSession();
  }

  void _startNfcSession() async {
    bool isAvailable = await _nfcService.isAvailable();
    if (!isAvailable) {
      if (mounted) setState(() => _headlineText = "NFC not supported");
      return;
    }

    _nfcService.startSession(
      onTagRead: (tagId) async {
        if (_isProcessing) return;

        // 1. Show Processing State
        setState(() {
          _isProcessing = true;
          _headlineText = "Processing...";
          _subText = "Verifying Identity...";
        });

        // 2. Call API (Offline handled inside service)
        final result = await _attendanceService.markGateAttendance(
          tagId,
          _isCheckIn ? 'in' : 'out',
        );

        if (!mounted) return;

        // 3. Show Result (Success or Failure)
        setState(() {
          _isProcessing = false;

          if (result['success'] == true) {
            // SUCCESS
            _isSuccess = true;
            _headlineText = "Successful";
            _subText = _isCheckIn
                ? "Welcome, ${result['user_name']}"
                : "Goodbye, ${result['user_name']}";
          } else {
            // FAILURE (Not Registered)
            _isSuccess = false;
            _headlineText = "Not Registered"; // Or "Was Not"
            _subText = result['message'] ?? "Card not recognized";
          }
        });

        // 4. Auto Reset after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isSuccess = null; // Go back to Ripples
              _headlineText = "Ready to Scan";
              _subText = "Tap card to check-in.";
            });
          }
        });
      },
      onError: (err) {},
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
      backgroundColor: Colors.white, // Figma background is white
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // --- 1. FIGMA HEADER ---
              const Text("Record Attendance", style: AppTextStyles.header),
              const SizedBox(height: 10),
              Text(
                "Select 'Check-in' Hold your device near the NFC tag to check-in.",
                textAlign: TextAlign.center,
                style: AppTextStyles.subHeader,
              ),

              const SizedBox(height: 30),

              // --- 2. FIGMA TOGGLE ---
              AttendanceToggle(
                isCheckInSelected: _isCheckIn,
                onToggle: (val) {
                  setState(() {
                    _isCheckIn = val;
                    // Reset UI when toggling
                    _isSuccess = null;
                    _headlineText = "Ready to Scan";
                  });
                },
              ),

              const Spacer(),

              // --- 3. CENTER VISUAL (Dynamic) ---
              // If Idle: Show Figma Ripple Widget
              // If Success: Show Green Check
              // If Fail: Show Red X
              SizedBox(height: 200, width: 200, child: _buildCenterVisual()),

              const SizedBox(height: 20),

              // --- 4. STATUS TEXT ---
              Text(
                _headlineText, // "Ready to Scan" or "Successful"
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subText,
                textAlign: TextAlign.center,
                style: AppTextStyles.subHeader,
              ),

              const Spacer(),

              // --- 5. FIGMA FOOTER BUTTON ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Logic for manual code
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Enter Code Instead",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Logic to switch between Ripple, Checkmark, and X
  Widget _buildCenterVisual() {
    if (_isProcessing) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    if (_isSuccess == true) {
      // SUCCESS STATE
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withOpacity(0.1),
        ),
        child: const Icon(Icons.check_circle, size: 100, color: Colors.green),
      );
    } else if (_isSuccess == false) {
      // FAILURE STATE
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(0.1),
        ),
        child: const Icon(Icons.cancel, size: 100, color: Colors.red),
      );
    } else {
      // IDLE STATE (Figma Ripple)
      return const NfcVisual();
    }
  }
}
