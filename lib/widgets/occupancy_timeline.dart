import 'package:flutter/material.dart';
import '../models/occupancy_data.dart';
import 'package:intl/intl.dart';

class OccupancyTimeline extends StatelessWidget {
  final List<OccupancyData> data;

  const OccupancyTimeline({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No timeline data available'));
    }

    // Sort data by last update time
    final sortedData = List<OccupancyData>.from(data)
      ..sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedData.length,
      itemBuilder: (context, index) {
        final occupancyData = sortedData[index];
        return _buildTimelineItem(occupancyData, context);
      },
    );
  }

  Widget _buildTimelineItem(OccupancyData data, BuildContext context) {
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('MMM dd');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(data.occupancyPercentage),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.deviceId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.occupiedSeats}/${data.totalSeats} seats occupied',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${data.occupancyPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(data.occupancyPercentage),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormat.format(data.lastUpdate),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                Text(
                  dateFormat.format(data.lastUpdate),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(double occupancy) {
    if (occupancy >= 80) return Colors.red;
    if (occupancy >= 60) return Colors.orange;
    if (occupancy >= 40) return Colors.yellow;
    return Colors.green;
  }
}
