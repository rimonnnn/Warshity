import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/helper/app_validators.dart';

void main() {
  group('dropdown', () {
    final dropdown = AppValidators.dropdown;

    test('should return message when value is null', () {
      expect(dropdown(null, 'Required'), 'Required');
    });

    test('should return null when value is not null', () {
      expect(dropdown('selected', 'Required'), isNull);
    });

    test('should work with integer value', () {
      expect(dropdown(1, 'Required'), isNull);
    });
  });

  group('terms', () {
    final terms = AppValidators.terms;

    test('should return error when terms are not accepted', () {
      expect(terms(false), isNotNull);
    });

    test('should return null when terms are accepted', () {
      expect(terms(true), isNull);
    });
  });
}
