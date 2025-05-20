import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterFlowController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Tạo tài khoản Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) return 'Không thể lấy UID người dùng.';

      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'photoUrl': 'https://cdn-icons-png.freepik.com/512/3607/3607444.png',
        'role': 'user',
        'created_at': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Lỗi không xác định: $e';
    }
  }
}