/// Utility class for form validation
class Validators {
  /// Validates if the input is not empty
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }
  
  /// Validates if the input is a valid email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Check if the phone number has at least 10 digits
    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid ZIP/Postal code
  static String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'ZIP code is required';
    }
    
    // US ZIP code pattern (5 digits or 5+4 format)
    final usZipRegex = RegExp(r'^\d{5}(-\d{4})?$');
    
    // Canadian postal code pattern (A1A 1A1 format)
    final canadianPostalRegex = RegExp(
      r'^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$',
    );
    
    // UK postcode pattern
    final ukPostcodeRegex = RegExp(
      r'^[A-Z]{1,2}[0-9][A-Z0-9]? ?[0-9][A-Z]{2}$',
      caseSensitive: false,
    );
    
    // General international postal code (3-10 alphanumeric characters)
    final generalPostalRegex = RegExp(r'^[a-zA-Z0-9]{3,10}$');
    
    if (!usZipRegex.hasMatch(value) && 
        !canadianPostalRegex.hasMatch(value) && 
        !ukPostcodeRegex.hasMatch(value) && 
        !generalPostalRegex.hasMatch(value)) {
      return 'Please enter a valid ZIP/Postal code';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid credit card number
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }
    
    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Check if the card number has between 13 and 19 digits
    if (digitsOnly.length < 13 || digitsOnly.length > 19) {
      return 'Credit card number must have between 13 and 19 digits';
    }
    
    // Luhn algorithm for credit card validation
    int sum = 0;
    bool alternate = false;
    
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      int digit = int.parse(digitsOnly[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'Please enter a valid credit card number';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid CVV code
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    
    // CVV should be 3 or 4 digits
    final cvvRegex = RegExp(r'^\d{3,4}$');
    
    if (!cvvRegex.hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid expiry date (MM/YY format)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    
    // Check format (MM/YY)
    final expiryRegex = RegExp(r'^\d{2}/\d{2}$');
    
    if (!expiryRegex.hasMatch(value)) {
      return 'Expiry date must be in MM/YY format';
    }
    
    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return 'Invalid expiry date';
    }
    
    if (month < 1 || month > 12) {
      return 'Month must be between 1 and 12';
    }
    
    // Get current date
    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last 2 digits of year
    final currentMonth = now.month;
    
    // Check if card is expired
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    // Check if name contains only letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 5) {
      return 'Address must be at least 5 characters';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid city name
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    
    if (value.length < 2) {
      return 'City must be at least 2 characters';
    }
    
    // Check if city contains only letters, spaces, hyphens, and apostrophes
    final cityRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    
    if (!cityRegex.hasMatch(value)) {
      return 'City can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  /// Validates if the input is a valid state/province
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State/Province is required';
    }
    
    if (value.length < 2) {
      return 'State/Province must be at least 2 characters';
    }
    
    return null;
  }
}
