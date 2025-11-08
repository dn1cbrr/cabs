import 'package:flutter/material.dart';
import '../models/seat_device.dart';

class SeatMonitoringWidget extends StatelessWidget {
  final SeatDevice seatDevice;
  final Function(int seatNumber, bool isOccupied)? onSeatStatusChanged;

  const SeatMonitoringWidget({
    super.key,
    required this.seatDevice,
    this.onSeatStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  seatDevice.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: seatDevice.isFull ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    seatDevice.isFull ? 'FULL' : 'AVAILABLE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSeatButton(1, seatDevice.seat1 == 1),
                _buildSeatButton(2, seatDevice.seat2 == 1),
                _buildSeatButton(3, seatDevice.seat3 == 1),
                _buildSeatButton(4, seatDevice.seat4 == 1),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: seatDevice.occupiedSeats / 4,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                seatDevice.isFull ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${seatDevice.occupiedSeats}/4 seats occupied',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatButton(int seatNumber, bool isOccupied) {
    return GestureDetector(
      onTap: () => onSeatStatusChanged?.call(seatNumber, !isOccupied),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isOccupied ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (isOccupied ? Colors.red : Colors.green).withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chair, color: Colors.white, size: 20),
            Text(
              'S$seatNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
