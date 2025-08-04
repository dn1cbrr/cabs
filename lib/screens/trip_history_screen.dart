import 'package:flutter/material.dart';
import '../models/trip_history.dart';
import '../services/trip_service.dart';

class TripHistoryScreen extends StatefulWidget {
  final int? driverId;

  const TripHistoryScreen({super.key, this.driverId});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<TripHistory> trips = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadTripHistory();
  }

  Future<void> _loadTripHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final tripData = await TripService.getTripHistory(
        driverId: widget.driverId,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        trips = tripData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading trips: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _loadTripHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driverId != null ? 'Driver Trip History' : 'All Trip History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadTripHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No trips found'),
            if (startDate != null || endDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    startDate = null;
                    endDate = null;
                  });
                  _loadTripHistory();
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryCard(),
        Expanded(
          child: ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              return _buildTripCard(trips[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: TripService.getTripSummary(
        widget.driverId,
        startDate,
        endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) return const SizedBox.shrink();

        final summary = snapshot.data!;
        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Trip Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Total Trips', summary['total_trips'].toString()),
                    _buildSummaryItem('Passengers', summary['total_passengers'].toString()),
                    _buildSummaryItem('Duration', summary['total_duration']),
                  ],
                ),
                if (startDate != null || endDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Filtered: ${_getDateRangeText()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (startDate == null && endDate == null) {
      return 'All time';
    }
    
    String formatDate(DateTime date) {
      return '${date.month}/${date.day}/${date.year}';
    }
    
    if (startDate != null && endDate != null) {
      return '${formatDate(startDate!)} - ${formatDate(endDate!)}';
    } else if (startDate != null) {
      return 'From ${formatDate(startDate!)}';
    } else {
      return 'Until ${formatDate(endDate!)}';
    }
  }

  Widget _buildTripCard(TripHistory trip) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip.formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${trip.formattedStartTime} - ${trip.formattedEndTime}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${trip.routeDetails}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Passengers: ${trip.totalPassengers}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${trip.formattedDuration}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
