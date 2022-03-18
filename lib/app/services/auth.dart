import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._new();
  factory AuthService.getInstance() {
    _instance ??= AuthService._new();
    return _instance!;
  }
  static AuthService? _instance;

  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> loginWithGoogle() async {
    try {
      if (user != null) {
        return;
      }

      /// NOTE: can throw in debug mode https://github.com/flutter/flutter/issues/33427#issuecomment-504529413
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(authCredential);
    } catch (err) {
      // TODO(merelj): handle error
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
