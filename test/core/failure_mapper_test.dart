import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/core/error/failure_mapper.dart';
import 'package:movies_app/core/error/failures.dart';

void main() {
  test('Invalid credentials are mapped to an AuthFailure', () {
    final failure = FailureMapper.from(
      FirebaseAuthException(code: 'invalid-credential'),
    );
    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Invalid email or password.');
  });
}
