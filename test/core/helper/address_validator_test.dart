import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

void main() {
  group('address', () {
    final address = AppValidators.address;

    test('should return error when value is null', () {
      expect(address(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(address(''), isNotNull);
    });

    test('should return error when value contains only spaces', () {
      expect(address('   '), isNotNull);
    });

    test('should return error when length is less than 3', () {
      expect(address('AB'), isNotNull);
    });

    test('should return null when length is exactly 3', () {
      expect(address('ABC'), isNull);
    });

    test('should return null when address is valid', () {
      expect(address('Beni Suef, Egypt'), isNull);
    });

    test('should trim spaces before checking length', () {
      expect(address('  ABC  '), isNull);
    });
  });
}
