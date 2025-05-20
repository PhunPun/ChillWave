import 'package:chillwave/models/username_validator.dart';
import 'package:flutter/widgets.dart';

class UsernameController extends ChangeNotifier{
  final TextEditingController usernameController = TextEditingController();
  bool isUsernameValid = false;
  String? errorText;

  UsernameController(){
    usernameController.addListener(onUsernameChanged);
  }

  void onUsernameChanged(){
    final username = usernameController.text.trim();
    final error = UsernameValidator.getErrorText(username);
    errorText = error;
    isUsernameValid = error == null;
    notifyListeners();
  }
  void dispose(){
    usernameController.dispose();
    super.dispose();
  }
}