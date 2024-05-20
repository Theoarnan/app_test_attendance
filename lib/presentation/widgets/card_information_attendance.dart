import 'package:flutter/material.dart';

class CardInformationAttendance extends StatelessWidget {
  final String title;
  final IconData icon;
  final String time;

  const CardInformationAttendance({
    super.key,
    required this.title,
    required this.icon,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        Icon(
          icon,
          color: Colors.grey.shade500,
          size: 34,
        ),
        // Time
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Title
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        )
      ],
    );
  }
}
