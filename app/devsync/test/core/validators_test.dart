import 'package:devsync/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppValidators.validateRequiredField', () {
    test('rejects empty and blank text', () {
      expect(AppValidators.validateRequiredField(null), isNotNull);
      expect(AppValidators.validateRequiredField('   '), isNotNull);
    });

    test('title needs 3 characters and says so', () {
      expect(AppValidators.validateRequiredField('ab'),
          'Must be at least 3 characters');
      expect(AppValidators.validateRequiredField('abc'), isNull);
    });

    test('description needs 10 characters', () {
      expect(AppValidators.validateRequiredField('too short', minLength: 10),
          'Must be at least 10 characters');
      expect(
          AppValidators.validateRequiredField('long enough!', minLength: 10),
          isNull);
    });
  });
}
