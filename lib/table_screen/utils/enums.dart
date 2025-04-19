// Note: We've already defined all our enums in table_model.dart, but this file is kept
// for potential future enums that might be needed.

// Helper to get display names for any enum
String enumToDisplayName(Object enumValue) {
  final String enumString = enumValue.toString();
  final int dotIndex = enumString.indexOf('.');
  if (dotIndex < 0) return enumString;
  
  final String name = enumString.substring(dotIndex + 1);
  return name.substring(0, 1).toUpperCase() + 
         name.substring(1).toLowerCase();
}

// Helper to convert status string to enum value safely
T? enumFromString<T>(List<T> enumValues, String value) {
  try {
    return enumValues.firstWhere(
      (type) => type.toString().split('.').last == value,
    );
  } catch (e) {
    return null;
  }
}