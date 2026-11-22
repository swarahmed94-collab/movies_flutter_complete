import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.providerIds = const [],
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<String> providerIds;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, providerIds];
}
