import 'package:chessudoku/enums/login_type.dart';
import 'package:chessudoku/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) return null;
      return User.fromMap(userDoc.data()!);
    });
  }

  Future<User> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final user = credential.user!;

    final userData = User(uid: user.uid, loginType: LoginType.guest);

    await _firestore.collection('users').doc(user.uid).set(userData.toMap());

    return userData;
  }

  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userData = User(uid: user.uid, email: user.email, loginType: LoginType.google);

      await _firestore.collection('users').doc(user.uid).set(userData.toMap());

      return userData;
    } catch (e) {
      print('Error during Google sign in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
