import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/user_document_repository.dart';
import 'user_document_state.dart';

class UserDocumentCubit extends Cubit<UserDocumentState> {
  UserDocumentCubit(this._repo)
      : super(const UserDocumentState(status: UserDocumentStatus.initial));

  final UserDocumentRepository _repo;
  StreamSubscription? _subscription;

  Future<void> watch(String uid) async {
    await _subscription?.cancel();
    emit(const UserDocumentState(status: UserDocumentStatus.loading));
    _subscription = _repo.watch(uid).listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => emit(UserDocumentState(
          status: UserDocumentStatus.failed,
          failure: failure,
        )),
        (document) => emit(UserDocumentState(
          status: UserDocumentStatus.loaded,
          document: document,
        )),
      );
    });
  }

  Future<bool> merge(String uid, Map<String, dynamic> fields) async {
    final result = await _repo.merge(uid, fields);
    if (isClosed) return false;
    return result.fold((failure) {
      emit(UserDocumentState(
        status: UserDocumentStatus.failed,
        document: state.document,
        failure: failure,
      ));
      return false;
    }, (_) => true);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
