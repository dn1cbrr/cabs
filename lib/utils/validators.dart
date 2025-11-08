class Validators {
  static String? validateRoute(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter route details';
    }
    if (value.length < 5) {
      return 'Route description must be at least 5 characters';
    }
    return null;
  }

  static String? validateVehicle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter vehicle details';
    }
    if (value.length < 3) {
      return 'Vehicle details must be at least 3 characters';
    }
    return null;
  }

  static String? validatePassengers(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter number of passengers';
    }
    final passengers = int.tryParse(value);
    if (passengers == null || passengers <= 0) {
      return 'Please enter a valid number of passengers';
    }
    if (passengers > 50) {
      return 'Maximum 50 passengers allowed';
    }
    return null;
  }

  static String? validateFare(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter fare amount';
    }
    final fare = double.tryParse(value);
    if (fare == null || fare <= 0) {
      return 'Please enter a valid fare amount';
    }
    if (fare > 10000) {
      return 'Fare amount seems too high';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a location';
    }
    if (value.length < 3) {
      return 'Location must be at least 3 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
