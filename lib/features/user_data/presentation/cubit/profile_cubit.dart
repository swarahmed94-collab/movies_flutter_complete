import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_document_repository.dart';

enum ProfileStatus { initial, loading, ready, saving, failed }
class ProfileState extends Equatable {
  const ProfileState({this.status=ProfileStatus.initial,this.document,
    this.failure,this.uid});
  final ProfileStatus status;
  final Map<String,dynamic>? document;
  final Failure? failure;
  final String? uid;
  String get phone => document?['phoneNumber'] is String ? document!['phoneNumber'] as String : '';
  int get avatar => document?['avatarIndex'] is int ? document!['avatarIndex'] as int : 7;
  @override
  List<Object?> get props=>[status,document,failure,uid];
}
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._documents,this._auth):super(const ProfileState());
  final UserDocumentRepository _documents;
  final AuthRepository _auth;
  StreamSubscription? _subscription;
  Future<void> bindUser(String? uid) async {
    await _subscription?.cancel();
    if (isClosed) return;
    if (uid==null) { emit(const ProfileState());return; }
    emit(ProfileState(status:ProfileStatus.loading,uid:uid));
    _subscription=_documents.watch(uid).listen((result){
      if (isClosed || state.uid!=uid) return;
      result.fold((f)=>emit(ProfileState(status:ProfileStatus.failed,uid:uid,
        failure:f,document:state.document)),
        (doc)=>emit(ProfileState(status:ProfileStatus.ready,uid:uid,document:doc)));
    });
  }
  Future<bool> update({required String name, required String phone,required int avatar}) async {
    final user=_auth.currentUser;
    if (user==null) return false;
    emit(ProfileState(status:ProfileStatus.saving,uid:user.uid,document:state.document));
    final authResult=await _auth.updateDisplayName(name);
    if (isClosed) return false;
    final authFailure=authResult.fold((f)=>f,(_)=>null);
    if (authFailure!=null) {
      emit(ProfileState(status:ProfileStatus.failed,uid:user.uid,
        document:state.document,failure:authFailure));return false;
    }
    final response=await _documents.merge(user.uid,{
      'displayName': name.trim(),'phoneNumber':phone.trim(),
      'avatarIndex':avatar,'email':user.email ?? '',
    });
    if (isClosed) return false;
    return response.fold((f){
      emit(ProfileState(status:ProfileStatus.failed,uid:user.uid,
        document:state.document,failure:f));return false;
    },(_){emit(ProfileState(status:ProfileStatus.ready,uid:user.uid,
       document:{...?state.document,'displayName':name.trim(),
       'phoneNumber':phone.trim(),'avatarIndex':avatar}));return true;});
  }
  @override
  Future<void> close() async { await _subscription?.cancel();await super.close(); }
}
