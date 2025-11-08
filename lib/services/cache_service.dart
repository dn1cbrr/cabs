import 'dart:async';
import '../models/occupancy_data.dart';
import '../models/seat_device.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CachedData> _cache = {};
  static const Duration _defaultTTL = Duration(minutes: 5);
  Timer? _cleanupTimer;

  void init() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _cleanupExpired();
    });
  }

  void _cleanupExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => value.isExpired(now));
  }

  void put(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = CachedData(
      data: data,
      expiry: DateTime.now().add(ttl ?? _defaultTTL),
    );
  }

  T? get<T>(String key) {
    final cached = _cache[key];
    if (cached != null && !cached.isExpired(DateTime.now())) {
      return cached.data as T;
    }
    _cache.remove(key);
    return null;
  }

  bool hasValid(String key) {
    final cached = _cache[key];
    return cached != null && !cached.isExpired(DateTime.now());
  }

  void invalidate(String key) {
    _cache.remove(key);
  }

  void invalidateAll() {
    _cache.clear();
  }

  // Specific cache methods for seat data
  void cacheSeats(List<SeatDevice> seats) {
    put('seats', seats);
  }

  List<SeatDevice>? getCachedSeats() => get<List<SeatDevice>>('seats');

  void cacheOccupancy(List<OccupancyData> occupancy) {
    put('occupancy', occupancy);
  }

  List<OccupancyData>? getCachedOccupancy() =>
      get<List<OccupancyData>>('occupancy');

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

class CachedData {
  final dynamic data;
  final DateTime expiry;

  CachedData({required this.data, required this.expiry});

  bool isExpired(DateTime now) => now.isAfter(expiry);
}
