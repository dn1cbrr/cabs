import 'package:flutter/material.dart';
import '../models/trip_history.dart';
import '../services/trip_service.dart';

class AdminRoutesScreen extends StatefulWidget {
  const AdminRoutesScreen({super.key});

  @override
  State<AdminRoutesScreen> createState() => _AdminRoutesScreenState();
}

class _AdminRoutesScreenState extends State<AdminRoutesScreen> {
  List<TripHistory> trips = [];
  List<TripHistory> filteredTrips = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = '';
  String? selectedDriverFilter;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRoutes() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Fetch all trips (no driverId specified means get all)
      final tripData = await TripService.getTripHistory(
        startDate: startDate,
        endDate: endDate,
        limit: 1000, // Get more trips for admin view
      );

      setState(() {
        trips = tripData;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading routes: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredTrips = trips.where((trip) {
      // Search filter
      bool matchesSearch = searchQuery.isEmpty ||
          trip.routeDetails.toLowerCase().contains(searchQuery.toLowerCase()) ||
          trip.driverName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          trip.plateNumber.toLowerCase().contains(searchQuery.toLowerCase());

      // Driver filter
      bool matchesDriver = selectedDriverFilter == null ||
          trip.driverName == selectedDriverFilter;

      return matchesSearch && matchesDriver;
    }).toList();

    // Sort by most recent first
    filteredTrips.sort((a, b) => b.tripDate.compareTo(a.tripDate));
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
      _loadAllRoutes();
    }
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      searchQuery = '';
      selectedDriverFilter = null;
      _searchController.clear();
      _applyFilters();
    });
  }

  List<String> _getUniqueDrivers() {
    return trips.map((trip) => trip.driverName).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - View All Routes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _selectDateRange,
            tooltip: 'Filter by date range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllRoutes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildStatsCard(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search routes, drivers, or plate numbers',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Driver filter dropdown
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDriverFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Driver',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Drivers'),
                      ),
                      ..._getUniqueDrivers().map((driver) => DropdownMenuItem<String>(
                        value: driver,
                        child: Text(driver),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedDriverFilter = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                ),
              ],
            ),
            
            // Active filters display
            if (startDate != null || endDate != null || searchQuery.isNotEmpty || selectedDriverFilter != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (startDate != null || endDate != null)
                      Chip(
                        label: Text('Date: ${_getDateRangeText()}'),
                        onDeleted: () {
                          setState(() {
                            startDate = null;
                            endDate = null;
                          });
                          _loadAllRoutes();
                        },
                      ),
                    if (searchQuery.isNotEmpty)
                      Chip(
                        label: Text('Search: "$searchQuery"'),
                        onDeleted: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                            _applyFilters();
                          });
                        },
                      ),
                    if (selectedDriverFilter != null)
                      Chip(
                        label: Text('Driver: $selectedDriverFilter'),
                        onDeleted: () {
                          setState(() {
                            selectedDriverFilter = null;
                            _applyFilters();
                          });
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    if (isLoading || trips.isEmpty) return const SizedBox.shrink();

    final totalTrips = filteredTrips.length;
    final totalDrivers = filteredTrips.map((trip) => trip.driverName).toSet().length;
    final totalPassengers = filteredTrips.fold<int>(0, (sum, trip) => sum + trip.totalPassengers);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Routes', totalTrips.toString(), Icons.route),
            _buildStatItem('Drivers', totalDrivers.toString(), Icons.person),
            _buildStatItem('Passengers', totalPassengers.toString(), Icons.people),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAllRoutes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.route_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              trips.isEmpty ? 'No routes found' : 'No routes match your filters',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (trips.isNotEmpty)
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear filters'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTrips.length,
      itemBuilder: (context, index) {
        return _buildRouteCard(filteredTrips[index]);
      },
    );
  }

  Widget _buildRouteCard(TripHistory trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trip.endTime != null ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trip.endTime != null ? 'Completed' : 'In Progress',
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
            
            // Driver information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${trip.vehicleType} - ${trip.plateNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Route details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.route, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.routeDetails,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Trip details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.access_time,
                    'Time',
                    '${trip.formattedStartTime} - ${trip.formattedEndTime}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.people,
                    'Passengers',
                    trip.totalPassengers.toString(),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.timer,
                    'Duration',
                    trip.formattedDuration,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
}
