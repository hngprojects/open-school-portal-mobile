import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AttendanceToggle extends StatelessWidget {
  final bool isCheckInSelected;
  final Function(bool) onToggle;

  const AttendanceToggle({
    Key? key,
    required this.isCheckInSelected,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildButton("Check In", true),
          _buildButton("Check Out", false),
        ],
      ),
    );
  }

  Widget _buildButton(String text, bool isCheckInBtn) {
    bool isActive = isCheckInSelected == isCheckInBtn;
    return Expanded(
      child: GestureDetector(
        onTap: () => onToggle(isCheckInBtn),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryRed : Colors.white,
            borderRadius: isCheckInBtn
                ? const BorderRadius.horizontal(left: Radius.circular(7))
                : const BorderRadius.horizontal(right: Radius.circular(7)),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
