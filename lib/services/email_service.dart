import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/email_model.dart';

class EmailService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Send OTP email via EmailJS with dynamic user name
  Future<bool> sendOTPEmail(
    String email,
    String otpCode,
    String userName,
  ) async {
    const serviceId = 'service_metro';
    const templateId = 'template_metro';
    const publicKey = 'CpNDc4BXcpqJV_2pU';

    try {
      print('Bắt đầu gửi email OTP đến: $email cho user: $userName');

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'user_name': userName,
            'to_email': email,
            'otp_code': otpCode,
            'from_name': 'Metro Pass',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Gửi email OTP thành công đến: $email');
        return true;
      } else {
        print('Gửi email OTP thất bại. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi khi gửi email OTP: $e');
      throw Exception('Lỗi gửi email: $e');
    }
  }

  // Send OTP code for password reset
  Future<OTPResult> sendOTPCode(String email) async {
    try {
      print('Kiểm tra email trong hệ thống: $email');
      final userQuery =
          await _db
              .collection("users")
              .where("email", isEqualTo: email)
              .limit(1)
              .get();

      if (userQuery.docs.isEmpty) {
        print('Email không tồn tại trong hệ thống: $email');
        return OTPResult.failure('Email không có trong hệ thống');
      }
      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      final userName = userData['username'] ?? 'Người dùng';

      print('Tìm thấy user: $userName với email: $email');
      print('Tạo mã OTP mới cho email: $email');

      final emailOTP = EmailModel.createNewOTP(email);
      await _db.collection("password_reset_otps").add(emailOTP.toMap());
      print('Lưu mã OTP vào Firestore thành công');
      final emailSent = await sendOTPEmail(email, emailOTP.otpCode, userName);

      if (emailSent) {
        print('Gửi mã OTP thành công đến email: $email');
        return OTPResult.success(
          'Mã OTP đã được gửi đến email của bạn (hết hạn sau 60 giây)',
        );
      } else {
        print('Gửi email OTP thất bại cho: $email');
        return OTPResult.failure('Không thể gửi email. Vui lòng thử lại');
      }
    } catch (e) {
      print('Lỗi khi gửi mã OTP: $e');
      return OTPResult.failure('Đã xảy ra lỗi: $e');
    }
  }

  /// Verify OTP code
  Future<OTPResult> verifyOTPCode(String email, String otpCode) async {
    try {
      print('Bắt đầu xác thực mã OTP cho email: $email');
      final otpQuery =
          await _db
              .collection("password_reset_otps")
              .where("email", isEqualTo: email)
              .where("otpCode", isEqualTo: otpCode)
              .where("isUsed", isEqualTo: false)
              .orderBy("createdAt", descending: true)
              .limit(1)
              .get();

      if (otpQuery.docs.isEmpty) {
        print(
          'Không tìm thấy mã OTP hợp lệ cho email: $email với mã: $otpCode',
        );
        return OTPResult.failure('Mã OTP không hợp lệ');
      }

      final otpDoc = otpQuery.docs.first;
      final emailModel = EmailModel.fromSnapshot(otpDoc);

      if (emailModel.isExpired) {
        print('Mã OTP đã hết hạn cho email: $email');
        return OTPResult.failure('Mã OTP đã hết hạn');
      }

      await otpDoc.reference.update({'isUsed': true});
      print('Đánh dấu mã OTP đã sử dụng thành công');

      return OTPResult.success('Xác thực mã OTP thành công');
    } catch (e) {
      print('Lỗi khi xác thực mã OTP: $e');
      return OTPResult.failure('Đã xảy ra lỗi: $e');
    }
  }

  /// Clean up expired OTP codes
  Future<void> cleanupExpiredOTPs() async {
    try {
      print('Bắt đầu dọn dẹp các mã OTP hết hạn');
      final now = DateTime.now();
      final expiredOTPs =
          await _db
              .collection("password_reset_otps")
              .where("expiresAt", isLessThan: Timestamp.fromDate(now))
              .get();

      print('Tìm thấy ${expiredOTPs.docs.length} mã OTP hết hạn cần xóa');
      for (final doc in expiredOTPs.docs) {
        await doc.reference.delete();
      }
      print('Dọn dẹp mã OTP hết hạn hoàn tất');
    } catch (e) {
      print('Lỗi khi dọn dẹp mã OTP hết hạn: $e');
      throw Exception('Lỗi dọn dẹp OTP hết hạn: $e');
    }
  }
}

/// Result wrapper for OTP operations
class OTPResult {
  final bool success;
  final String message;

  OTPResult._({required this.success, required this.message});

  factory OTPResult.success(String message) {
    return OTPResult._(success: true, message: message);
  }

  factory OTPResult.failure(String message) {
    return OTPResult._(success: false, message: message);
  }
}
