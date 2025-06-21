import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  /// Đăng nhập bằng Google và lưu thông tin người dùng vào Firestore nếu email chưa tồn tại
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      // ✅ Nếu đã đăng nhập trước đó → đăng xuất để chọn lại tài khoản
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        await FirebaseAuth.instance.signOut();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final isNew = await _checkEmailAlreadyExists(user.email ?? '');
        if (!isNew) {
          await _addUserToFirestore(
            uid: user.uid,
            email: user.email ?? '',
            username: user.displayName ?? 'No name',
            photoUrl: user.photoURL ?? '',
          );
        } else {
          print("⚠️ Email đã tồn tại → không thêm mới Firestore.");
        }
      }

      return userCredential;
    } catch (e) {
      print("Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  /// ✅ Kiểm tra email đã tồn tại trong Firestore chưa
  static Future<bool> _checkEmailAlreadyExists(String email) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final query = await usersRef.where('email', isEqualTo: email).get();
    return query.docs.isNotEmpty;
  }

  /// ✅ Thêm người dùng vào Firestore (khi chắc chắn chưa tồn tại)
  static Future<void> _addUserToFirestore({
    required String uid,
    required String email,
    required String username,
    required String photoUrl,
  }) async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    await usersRef.doc(uid).set({
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'role': 'user',
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}