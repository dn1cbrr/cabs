/// Advanced logging system for WebSocket debugging and monitoring
library;

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

class Logger {
  static const String _name = 'WebSocket';
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  static void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < _currentLevel.index) return;

    final prefix = _getPrefix(level);
    final fullMessage = '[$_name] $prefix $message';

    switch (level) {
      case LogLevel.debug:
        developer.log(fullMessage, name: _name, level: 0);
        break;
      case LogLevel.info:
        developer.log(fullMessage, name: _name, level: 1);
        break;
      case LogLevel.warning:
        developer.log(fullMessage, name: _name, level: 2, error: error);
        break;
      case LogLevel.error:
        developer.log(
          fullMessage,
          name: _name,
          level: 3,
          error: error,
          stackTrace: stackTrace,
        );
        break;
      case LogLevel.critical:
        developer.log(
          fullMessage,
          name: _name,
          level: 4,
          error: error,
          stackTrace: stackTrace,
        );
        break;
    }

    if (!kReleaseMode) {
      debugPrint(fullMessage);
    }
  }

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return 'ℹ️ INFO';
      case LogLevel.warning:
        return '⚠️ WARN';
      case LogLevel.error:
        return '❌ ERROR';
      case LogLevel.critical:
        return '🚨 CRITICAL';
    }
  }

  static void debug(String message) => _log(LogLevel.debug, message);
  static void info(String message) => _log(LogLevel.info, message);
  static void warning(String message, [Object? error]) =>
      _log(LogLevel.warning, message, error);
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);
  static void critical(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) => _log(LogLevel.critical, message, error, stackTrace);
}

/// Performance metrics logger
class PerformanceLogger {
  static final Map<String, DateTime> _timers = {};

  static void startTimer(String operation) {
    _timers[operation] = DateTime.now();
  }

  static void endTimer(String operation) {
    final startTime = _timers[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      Logger.debug('Performance: $operation took ${duration.inMilliseconds}ms');
      _timers.remove(operation);
    }
  }

  static void logMemoryUsage() {
    if (kDebugMode) {
      Logger.debug('Memory usage: ${DateTime.now()}');
    }
  }
}
