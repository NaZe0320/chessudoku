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

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not found');

      // Firebase Firestore에서 사용자 데이터 삭제
      final batch = _firestore.batch();

      // 사용자 기본 데이터 삭제
      batch.delete(_firestore.collection('users').doc(user.uid));

      // 게임 기록 삭제
      final recordsSnapshot = await _firestore.collection('users').doc(user.uid).collection('records').get();
      for (var doc in recordsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 게임 데이터 삭제
      final gameDataSnapshot = await _firestore.collection('users').doc(user.uid).collection('game_data').get();
      for (var doc in gameDataSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 배치 작업 실행
      await batch.commit();

      // Google 로그인 사용자인 경우 Google 연결 해제
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }

      // Firebase Auth 계정 삭제
      await user.delete();
    } catch (e) {
      print('Error during account deletion: $e');
      rethrow;
    }
  }
}
