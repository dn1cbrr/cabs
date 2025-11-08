# WebSocket Service Integration TODO

## Phase 1: Replace Basic Service with Fixed Service
- [ ] Replace `lib/services/websocket_service.dart` with `lib/services/seat_websocket_service_fixed.dart`
- [ ] Update all imports to use the new service
- [ ] Update service initialization in main.dart

## Phase 2: Update UI Components
- [ ] Update `RealTimeSeatMonitoringWidget` to use `SeatWebSocketServiceFixed`
- [ ] Update `EnhancedRealTimeSeatMonitoringWidget` to use new service
- [ ] Update `ComprehensiveSeatDashboard` to use new service

## Phase 3: Message Handling Updates
- [ ] Update message parsing to use standardized protocol
- [ ] Implement proper error handling for connection issues
- [ ] Add connection status indicators

## Phase 4: Testing & Validation
- [ ] Test ESP32 WebSocket server integration
- [ ] Verify reconnection logic works correctly
- [ ] Test message flow between ESP32 and app
- [ ] Validate seat status updates are displayed correctly

## Phase 5: Cleanup
- [ ] Remove deprecated websocket_service.dart
- [ ] Remove unused improved_websocket_service.dart
- [ ] Update documentation
