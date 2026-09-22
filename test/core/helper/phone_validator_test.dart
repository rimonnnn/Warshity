import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

void main() {
  group('phone', () {
    final phone = AppValidators.phone;

    test('should return error when value is null', () {
      expect(phone(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(phone(''), isNotNull);
    });

    test('should return error when value contains only spaces', () {
      expect(phone('   '), isNotNull);
    });

    test('should return null for valid Vodafone number', () {
      expect(phone('01012345678'), isNull);
    });

    test('should return null for valid Etisalat number', () {
      expect(phone('01112345678'), isNull);
    });

    test('should return null for valid Orange number', () {
      expect(phone('01212345678'), isNull);
    });

    test('should return null for valid WE number', () {
      expect(phone('01512345678'), isNull);
    });

    test('should return error for invalid prefix', () {
      expect(phone('01312345678'), isNotNull);
    });

    test('should return error when phone is too short', () {
      expect(phone('0101234567'), isNotNull);
    });

    test('should return error when phone is too long', () {
      expect(phone('010123456789'), isNotNull);
    });

    test('should return error when phone contains letters', () {
      expect(phone('01012345abc'), isNotNull);
    });

    test('should accept surrounding spaces', () {
      expect(phone(' 01012345678 '), isNull);
    });
  });
}
