import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

void main() {
  group('price', () {
    final price = AppValidators.price;

    test('should return error when value is null', () {
      expect(price(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(price(''), isNotNull);
    });

    test('should return error when value contains only spaces', () {
      expect(price('   '), isNotNull);
    });

    test('should return error when value is not a number', () {
      expect(price('abc'), isNotNull);
    });

    test('should return error when value is zero', () {
      expect(price('0'), isNotNull);
    });

    test('should return error when value is negative', () {
      expect(price('-10'), isNotNull);
    });

    test('should return null for positive integer', () {
      expect(price('100'), isNull);
    });

    test('should return null for positive decimal', () {
      expect(price('99.99'), isNull);
    });

    test('should accept surrounding spaces', () {
      expect(price(' 100 '), isNull);
    });
  });

  group('amount', () {
    final amount = AppValidators.amount;

    test('should return error when value is null', () {
      expect(amount(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(amount(''), isNotNull);
    });

    test('should return error when value contains only spaces', () {
      expect(amount('   '), isNotNull);
    });

    test('should return error when value is not a number', () {
      expect(amount('abc'), isNotNull);
    });

    test('should return error when value is negative', () {
      expect(amount('-10'), isNotNull);
    });

    test('should return null when value is zero', () {
      expect(amount('0'), isNull);
    });

    test('should return null when value is positive integer', () {
      expect(amount('100'), isNull);
    });

    test('should return null when value is positive decimal', () {
      expect(amount('99.99'), isNull);
    });

    test('should accept surrounding spaces', () {
      expect(amount(' 100 '), isNull);
    });
  });
}
