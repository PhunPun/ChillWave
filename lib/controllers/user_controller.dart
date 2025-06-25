import 'package:chillwave/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Đăng nhập bằng email và mật khẩu (password chưa mã hóa)
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        return UserModel.fromSnapshot(userDoc);
      } else {
        return null; // Không tìm thấy tài khoản
      }
    } catch (e) {
      print('Đăng nhập thất bại: $e');
      return null;
    }
  }
}
