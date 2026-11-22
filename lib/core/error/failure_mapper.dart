import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'failures.dart';

abstract final class FailureMapper {
  static Failure from(Object error) {
    if (error is Failure) return error;
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return const AuthFailure('Please enter a valid email address.');
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return const AuthFailure('Invalid email or password.');
        case 'email-already-in-use':
          return const AuthFailure('This email is already registered.');
        case 'weak-password':
          return const AuthFailure('Please choose a stronger password.');
        case 'network-request-failed':
          return const NetworkFailure('Network connection failed.');
        case 'requires-recent-login':
          return const AuthFailure('Recent sign-in required. Please sign in again.');
        case 'too-many-requests':
          return const AuthFailure('Too many attempts. Try again later.');
        default:
          return AuthFailure(error.message ?? 'Authentication failed.');
      }
    }
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return const AuthFailure('You are not authorized to access this data.');
      }
      return ApiFailure(error.message ?? 'Cloud data operation failed.');
    }
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure('Unable to connect. Check your network.');
        case DioExceptionType.badResponse:
          return ApiFailure(
            'Server returned HTTP ${error.response?.statusCode ?? 'error'}.',
          );
        default:
          return const NetworkFailure('Request could not be completed.');
      }
    }
    if (error is HiveError) return const CacheFailure('Local cache failed.');
    return const UnknownFailure('An unexpected error occurred.');
  }
}
