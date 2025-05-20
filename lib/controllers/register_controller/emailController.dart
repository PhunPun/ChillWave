import 'dart:async';
import 'package:chillwave/models/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmailController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  bool isEmailValid = false;
  String? errorText;

  Timer? _debounce;

  EmailController() {
    emailController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _validateEmail(); // gọi async đúng cách
      });
    });
  }

  Future<void> _validateEmail() async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
    errorText = 'Email không được để trống';
    isEmailValid = false;
  } else if (!EmailValidator.isValid(email)) {
    errorText = 'Email không hợp lệ. Ví dụ: example@gmail.com';
    isEmailValid = false;
  } else {
    try {
      print('Đang kiểm tra email trong Firestore: "$email"');

      // Tìm trong collection "users" document nào có field "email" bằng email đã nhập
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        errorText = 'Email này đã được sử dụng';
        isEmailValid = false;
      } else {
        errorText = null;
        isEmailValid = true;
      }
    } catch (e) {
      errorText = 'Lỗi kiểm tra email: $e';
      isEmailValid = false;
    }
  }

  notifyListeners();
}


  @override
  void dispose() {
    _debounce?.cancel();
    emailController.dispose();
    super.dispose();
  }
}
