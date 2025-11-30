import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NfcVisual extends StatelessWidget {
  const NfcVisual({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220, // Total width of the ripple effect
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Outer Ring (Faintest Red)
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryRed.withOpacity(0.05),
            ),
          ),

          // 2. Middle Ring (Lighter Red)
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryRed.withOpacity(0.15),
            ),
          ),

          // 3. Center Button (White with Shadow)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                // The Icon
                Icon(
                  Icons.wifi, // This looks like the radio waves in your design
                  size: 45,
                  color: AppColors.primaryRed,
                ),
                SizedBox(height: 4),
                // The Text
                Text(
                  "NFC",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
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
