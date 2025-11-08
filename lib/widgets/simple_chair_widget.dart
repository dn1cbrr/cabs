import 'package:flutter/material.dart';

class SimpleChairWidget extends StatelessWidget {
  final String seatId;
  final bool isOccupied;
  final Function(bool)? onStatusChanged;

  const SimpleChairWidget({
    super.key,
    required this.seatId,
    required this.isOccupied,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStatusChanged != null ? () => onStatusChanged!(!isOccupied) : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isOccupied ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (isOccupied ? Colors.green : Colors.red).withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.chair,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
