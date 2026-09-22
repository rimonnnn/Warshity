import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

void main() {
  group('email', () {
    final email = AppValidators.email;

    test('should return error when value is null', () {
      expect(email(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(email(''), isNotNull);
    });

    test('should return null when value is provided', () {
      expect(email('test@gmail.com'), isNull);
    });
  });

  group('password', () {
    final password = AppValidators.password;

    test('should return error when value is null', () {
      expect(password(null), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(password(''), isNotNull);
    });

    test('should return error when length is less than 8', () {
      expect(password('1234567'), isNotNull);
    });

    test('should return null when length is 8', () {
      expect(password('12345678'), isNull);
    });

    test('should return null when length is greater than 8', () {
      expect(password('123456789'), isNull);
    });
  });

  group('confirmPassword', () {
    final confirmPassword = AppValidators.confirmPassword;

    test('should return error when value is null', () {
      expect(confirmPassword(null, '12345678'), isNotNull);
    });

    test('should return error when value is empty', () {
      expect(confirmPassword('', '12345678'), isNotNull);
    });

    test('should return error when passwords do not match', () {
      expect(confirmPassword('123456789', '12345678'), isNotNull);
    });

    test('should return null when passwords match', () {
      expect(confirmPassword('12345678', '12345678'), isNull);
    });
  });
}
