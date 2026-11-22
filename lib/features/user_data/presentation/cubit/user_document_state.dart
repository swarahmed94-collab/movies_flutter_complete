import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

enum UserDocumentStatus { initial, loading, loaded, failed }

class UserDocumentState extends Equatable {
  const UserDocumentState({
    required this.status,
    this.document,
    this.failure,
  });

  final UserDocumentStatus status;
  final Map<String, dynamic>? document;
  final Failure? failure;

  @override
  List<Object?> get props => [status, document, failure];
}
