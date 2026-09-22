import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

void main() {
  group('shopName', () {
    final shopName = AppValidators.shopName;

    test('should return error when value is null', () {
      expect(shopName(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(shopName(''), isNotNull);
    });

    test('should return error when value contains only spaces', () {
      expect(shopName('   '), isNotNull);
    });

    test('should return null when value is valid', () {
      expect(shopName('My Shop'), isNull);
    });
  });

  group('accountName', () {
    final accountName = AppValidators.accountName;

    test('should return error when value is null', () {
      expect(accountName(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(accountName(''), isNotNull);
    });

    test('should return error when value contains only spaces', () {
      expect(accountName('   '), isNotNull);
    });

    test('should return null when value is valid', () {
      expect(accountName('Kirolos'), isNull);
    });
  });

  group('clientName', () {
    final clientName = AppValidators.clientName;

    test('should return error when value is null', () {
      expect(clientName(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(clientName(''), isNotNull);
    });

    test('should return error when value contains only spaces', () {
      expect(clientName('   '), isNotNull);
    });

    test('should return null when value is valid', () {
      expect(clientName('Ahmed'), isNull);
    });
  });
}
