import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Uses genuine Firebase Auth SDK calls. No mocked authentication.
class FirebaseAuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._auth);
  final FirebaseAuth _auth;
  bool _googleSessionActive = false;

  FirebaseAuth get instance => _auth;

  Future<User> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw FirebaseAuthException(code: 'missing-user');
    return user;
  }

  Future<User> signUp(String email, String password, String displayName) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw FirebaseAuthException(code: 'missing-user');
    await user.updateDisplayName(displayName.trim());
    await user.reload();
    return _auth.currentUser ?? user;
  }

  Future<User> signInWithGoogle() async {
    late final UserCredential result;
    if (kIsWeb) {
      result = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize();
      final account = await signIn.authenticate();
      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      result = await _auth.signInWithCredential(credential);
    }
    final user = result.user;
    if (user == null) throw FirebaseAuthException(code: 'missing-user');
    _googleSessionActive = true;
    return user;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> updateDisplayName(String value) async {
    final user=_auth.currentUser;
    if (user==null) throw FirebaseAuthException(code:'missing-user');
    await user.updateDisplayName(value.trim());
    await user.reload();
  }

  Future<void> reauthenticate({String? password}) async {
    final user=_auth.currentUser;
    if (user==null) throw FirebaseAuthException(code:'missing-user');
    final providers=user.providerData.map((p)=>p.providerId).toList();
    if(providers.contains('password')) {
      if(password==null || password.isEmpty || user.email==null){
        throw FirebaseAuthException(code:'requires-recent-login',
          message:'Enter your current password to delete the account.');
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email:user.email!,password:password));
    } else if(providers.contains('google.com')) {
      if (kIsWeb) {
        await user.reauthenticateWithPopup(GoogleAuthProvider());
      } else {
        final google=GoogleSignIn.instance;
        await google.initialize();
        final account=await google.authenticate();
        final auth=account.authentication;
        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(idToken:auth.idToken));
      }
    } else {
      throw FirebaseAuthException(code:'requires-recent-login',
        message:'Please sign in again before deleting this account.');
    }
  }

  Future<void> deleteAccount() async {
    final user=_auth.currentUser;
    if (user==null) throw FirebaseAuthException(code:'missing-user');
    await user.delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb && _googleSessionActive) {
      await GoogleSignIn.instance.signOut();
      _googleSessionActive = false;
    }
  }
}
