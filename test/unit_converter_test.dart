import 'package:flutter_test/flutter_test.dart';
import 'package:gebeya/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter Tests', () {
    test('Calculates price per kg for Teff bought in Tassa', () {
      // 150 ETB paid for 1 Tassa of Teff (1 Tassa = 1.25 kg)
      final pricePerKg = UnitConverter.calculatePricePerStandardUnit(
        totalPrice: 150.0,
        quantity: 1.0,
        unitMultiplier: 1.25,
      );
      expect(pricePerKg, 120.0);
    });

    test('Calculates price per liter for 3L Jog of Cooking Oil', () {
      // 600 ETB paid for 1 Jog (3 Liters)
      final pricePerLiter = UnitConverter.calculatePricePerStandardUnit(
        totalPrice: 600.0,
        quantity: 1.0,
        unitMultiplier: 3.0,
      );
      expect(pricePerLiter, 200.0);
    });

    test('Handles zero or negative quantity gracefully', () {
      final price = UnitConverter.calculatePricePerStandardUnit(
        totalPrice: 100.0,
        quantity: 0.0,
        unitMultiplier: 1.0,
      );
      expect(price, 0.0);
    });
  });
}
