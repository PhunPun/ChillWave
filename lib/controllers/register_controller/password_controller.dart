import 'package:chillwave/models/password_validator.dart';
import 'package:flutter/material.dart';

class PasswordController extends ChangeNotifier {
  final TextEditingController passwordController = TextEditingController();
  String? errorText;
  bool isPasswordValid = false;

  PasswordController() {
    passwordController.addListener(onPasswordChanged);
  }

  void onPasswordChanged(){
    final password = passwordController.text.trim();
    final error = PasswordValidator.getErrorText(password);
    errorText = error;
    isPasswordValid = error == null;
    notifyListeners();
  }
  void dispose() {
    passwordController.dispose();
    super.dispose();  
  }
}