import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // get current
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  //login

  Future<UserCredential> loginEmailPassword(String email, password) async {
    //attempt login
    try {
      final UserCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return UserCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //register

  Future<UserCredential> registerEmailPassword(String email, password) async {
    try {
      final UserCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
