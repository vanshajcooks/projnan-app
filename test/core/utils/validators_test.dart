import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('validateName accepts valid names', () {
      expect(Validators.validateName('Aryan Patel'), null);
      expect(Validators.validateName('Al'), null);
    });

    test('validateName rejects empty or too short/long names', () {
      expect(Validators.validateName(''), 'Full name is required');
      expect(Validators.validateName('   '), 'Full name is required');
      expect(Validators.validateName('A'), 'Full name must be between 2 and 100 characters');
      expect(Validators.validateName('A' * 101), 'Full name must be between 2 and 100 characters');
    });

    test('validateEmail accepts valid email formats', () {
      expect(Validators.validateEmail('user@example.com'), null);
      expect(Validators.validateEmail('john.doe+tag@sub.domain.edu'), null);
    });

    test('validateEmail rejects invalid email formats', () {
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('plainaddress'), 'Please enter a valid email address');
      expect(Validators.validateEmail('user@domain'), 'Please enter a valid email address');
      expect(Validators.validateEmail('@domain.com'), 'Please enter a valid email address');
    });

    test('validateUsername accepts valid usernames', () {
      expect(Validators.validateUsername('aryan_99'), null);
      expect(Validators.validateUsername('john-doe'), null);
      expect(Validators.validateUsername('dev'), null);
    });

    test('validateUsername rejects invalid usernames', () {
      expect(Validators.validateUsername(''), 'Username is required');
      expect(Validators.validateUsername('ab'), 'Username must be 3-30 characters (letters, numbers, _, -)');
      expect(Validators.validateUsername('user@invalid!'), 'Username must be 3-30 characters (letters, numbers, _, -)');
    });

    test('validatePassword accepts compliant password', () {
      expect(Validators.validatePassword('Password123!'), null);
      expect(Validators.validatePassword('Strong#Pass2026'), null);
    });

    test('validatePassword enforces complexity rules matching backend', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('Short1!'), 'Password must be at least 8 characters long');
      expect(Validators.validatePassword('nouppercase123!'), 'Must include at least one uppercase letter');
      expect(Validators.validatePassword('NOLOWERCASE123!'), 'Must include at least one lowercase letter');
      expect(Validators.validatePassword('NoNumbersHere!'), 'Must include at least one number');
      expect(Validators.validatePassword('NoSpecialChar123'), 'Must include at least one special character');
    });

    test('validateClassCode handles optional valid and invalid codes', () {
      expect(Validators.validateClassCode(''), null);
      expect(Validators.validateClassCode(null), null);
      expect(Validators.validateClassCode('CS101'), null);
      expect(Validators.validateClassCode('AB'), 'Class code is usually 4-12 characters');
    });
  });
}
