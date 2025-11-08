import 'package:flutter/material.dart';

class SeatLogoWidget extends StatelessWidget {
  final int seatNumber;
  final bool isOccupied;
  final Function(bool isOccupied)? onStatusChanged;

  const SeatLogoWidget({
    super.key,
    required this.seatNumber,
    required this.isOccupied,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onStatusChanged?.call(!isOccupied),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isOccupied ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isOccupied ? Colors.red : Colors.green).withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chair, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'S$seatNumber',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
