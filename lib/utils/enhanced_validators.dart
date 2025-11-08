import 'dart:async';
import 'package:flutter/material.dart';

/// Enhanced validation system with real-time feedback
class EnhancedValidators {
  /// Debounced validation to prevent excessive validation calls
  static Timer? _debounceTimer;
  
  static String? Function(String?) debouncedValidation(
    String? Function(String?) validator, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    return (String? value) {
      _debounceTimer?.cancel();
      String? result;
      
      _debounceTimer = Timer(delay, () {
        result = validator(value);
      });
      
      return result;
    };
  }

  /// Enhanced email validation with better regex
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
      caseSensitive: false,
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address (e.g., user@example.com)';
    }
    
    return null;
  }

  /// Enhanced phone validation with international support
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-numeric characters
    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanNumber.length < 10 || cleanNumber.length > 15) {
      return 'Phone number must be between 10-15 digits';
    }
    
    return null;
  }

  /// Enhanced password validation with strength indicator
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Enhanced route validation
  static String? validateRoute(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Route details are required';
    }
    
    if (value.length < 5) {
      return 'Route description must be at least 5 characters';
    }
    
    if (value.length > 200) {
      return 'Route description must be less than 200 characters';
    }
    
    return null;
  }

  /// Enhanced vehicle validation
  static String? validateVehicle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle details are required';
    }
    
    if (value.length < 3) {
      return 'Vehicle details must be at least 3 characters';
    }
    
    if (value.length > 100) {
      return 'Vehicle details must be less than 100 characters';
    }
    
    return null;
  }

  /// Enhanced passenger validation
  static String? validatePassengers(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Number of passengers is required';
    }
    
    final passengers = int.tryParse(value.trim());
    if (passengers == null) {
      return 'Please enter a valid number';
    }
    
    if (passengers <= 0) {
      return 'Number of passengers must be greater than 0';
    }
    
    if (passengers > 50) {
      return 'Maximum 50 passengers allowed';
    }
    
    return null;
  }

  /// Enhanced fare validation
  static String? validateFare(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Fare amount is required';
    }
    
    final fare = double.tryParse(value.trim());
    if (fare == null) {
      return 'Please enter a valid amount';
    }
    
    if (fare <= 0) {
      return 'Fare must be greater than 0';
    }
    
    if (fare > 10000) {
      return 'Fare amount exceeds maximum limit';
    }
    
    return null;
  }

  /// Enhanced location validation
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    
    if (value.length < 3) {
      return 'Location must be at least 3 characters';
    }
    
    if (value.length > 100) {
      return 'Location must be less than 100 characters';
    }
    
    return null;
  }

  /// Real-time validation wrapper
  static String? Function(String?) withRealTimeFeedback(
    String? Function(String?) validator, {
    void Function(String?)? onValidationChanged,
  }) {
    return (String? value) {
      final result = validator(value);
      onValidationChanged?.call(result);
      return result;
    };
  }
}

/// Validation state manager for form fields
class ValidationState {
  final String? error;
  final bool isValidating;
  final bool isValid;
  final String? helperText;

  const ValidationState({
    this.error,
    this.isValidating = false,
    this.isValid = false,
    this.helperText,
  });

  ValidationState copyWith({
    String? error,
    bool? isValidating,
    bool? isValid,
    String? helperText,
  }) {
    return ValidationState(
      error: error,
      isValidating: isValidating ?? this.isValidating,
      isValid: isValid ?? this.isValid,
      helperText: helperText ?? this.helperText,
    );
  }
}

/// Validation controller for managing field validation state
class FieldValidationController extends ChangeNotifier {
  ValidationState _state = const ValidationState();
  
  ValidationState get state => _state;
  
  void updateValidation(String? error, {bool isValidating = false}) {
    _state = _state.copyWith(
      error: error,
      isValidating: isValidating,
      isValid: error == null,
    );
    notifyListeners();
  }
  
  void setHelperText(String? text) {
    _state = _state.copyWith(helperText: text);
    notifyListeners();
  }
  
  void reset() {
    _state = const ValidationState();
    notifyListeners();
  }
}
