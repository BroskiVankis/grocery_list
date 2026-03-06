import 'package:grocery_list/state/units_preference.dart';

class ConvertedMeasurement {
  const ConvertedMeasurement({required this.value, required this.unit});

  final double value;
  final String unit;

  String format({int maxFractionDigits = 2}) {
    final rounded = value.toStringAsFixed(maxFractionDigits);
    final cleaned = rounded.contains('.')
        ? rounded
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
        : rounded;
    return '$cleaned $unit';
  }
}

class UnitConverter {
  static double gramsToOunces(double grams) => grams * 0.0352739619;
  static double ouncesToGrams(double ounces) => ounces / 0.0352739619;

  static double kilogramsToPounds(double kilograms) => kilograms * 2.2046226218;
  static double poundsToKilograms(double pounds) => pounds / 2.2046226218;

  static double millilitersToCups(double milliliters) =>
      milliliters / 236.5882365;
  static double cupsToMilliliters(double cups) => cups * 236.5882365;

  static double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;
  static double fahrenheitToCelsius(double fahrenheit) =>
      (fahrenheit - 32) * 5 / 9;

  static ConvertedMeasurement convertWeightOrVolumeForDisplay({
    required double metricValue,
    required String metricUnit,
    required UnitsPreference preference,
  }) {
    if (preference == UnitsPreference.metric) {
      return ConvertedMeasurement(value: metricValue, unit: metricUnit);
    }

    switch (metricUnit.toLowerCase()) {
      case 'g':
      case 'gram':
      case 'grams':
        return ConvertedMeasurement(
          value: gramsToOunces(metricValue),
          unit: 'oz',
        );
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return ConvertedMeasurement(
          value: kilogramsToPounds(metricValue),
          unit: 'lb',
        );
      case 'ml':
      case 'milliliter':
      case 'milliliters':
        return ConvertedMeasurement(
          value: millilitersToCups(metricValue),
          unit: 'cups',
        );
      default:
        return ConvertedMeasurement(value: metricValue, unit: metricUnit);
    }
  }

  static String convertTemperatureTextForDisplay({
    required double metricCelsius,
    required UnitsPreference preference,
  }) {
    if (preference == UnitsPreference.metric) {
      return '${metricCelsius.toStringAsFixed(0)}°C';
    }
    final fahrenheit = celsiusToFahrenheit(metricCelsius);
    return '${fahrenheit.toStringAsFixed(0)}°F';
  }

  static String convertIngredientTextForDisplay(
    String ingredient,
    UnitsPreference preference,
  ) {
    if (preference == UnitsPreference.metric) {
      return ingredient;
    }

    final match = RegExp(
      r'^(\d+(?:\.\d+)?)\s*(kg|g|ml)\b',
      caseSensitive: false,
    ).firstMatch(ingredient.trim());

    if (match == null) {
      return ingredient;
    }

    final rawValue = double.tryParse(match.group(1) ?? '');
    final rawUnit = match.group(2);

    if (rawValue == null || rawUnit == null) {
      return ingredient;
    }

    final converted = convertWeightOrVolumeForDisplay(
      metricValue: rawValue,
      metricUnit: rawUnit,
      preference: preference,
    );

    final convertedPrefix = converted.format(maxFractionDigits: 2);
    final originalPrefixLength = match.group(0)!.length;
    final suffix = ingredient.trim().substring(originalPrefixLength).trimLeft();

    if (suffix.isEmpty) {
      return convertedPrefix;
    }
    return '$convertedPrefix $suffix';
  }
}
