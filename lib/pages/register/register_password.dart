import 'package:chillwave/controllers/register_controller/password_controller.dart';
import 'package:chillwave/pages/register/register_username.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class RegisterPassword extends StatefulWidget {
  final String email;
  const RegisterPassword({
    super.key,
    required this.email
  });

  @override
  State<RegisterPassword> createState() => _RegisterPasswordState();
}

class _RegisterPasswordState extends State<RegisterPassword> {
  final FocusNode focusNode = FocusNode();
  final PasswordController _passwordController = PasswordController();
  bool isFocused = false;
  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
    _passwordController.passwordController.addListener((){
      setState(() {
        
      });
    });
  }
  @override
  void dispose() {
    focusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Tạo tào khoản', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80,),
              Text(
                'Tạo một mật khẩu',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.pr6)
                ),
              ),
              Container(
                height: 50,
                child: TextField(
                  focusNode: focusNode,
                  controller: _passwordController.passwordController,
                  style: TextStyle(color: Color(MyColor.pr6)),
                  cursorColor: Color(MyColor.pr6),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isFocused ? Color(MyColor.pr2) : Color(MyColor.se1),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none, 
                      borderRadius: BorderRadius.circular(8), 
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none, 
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (_passwordController.errorText != null)
                Text(
                  _passwordController.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              const SizedBox(height: 28,),
              Center(
                child: ElevatedButton(
                  onPressed: _passwordController.isPasswordValid 
                    ? () {
                      final password = _passwordController.passwordController.text.trim();
                      Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => RegisterUsername(
                          email: widget.email,
                          password: password,
                        )));}: null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(127, 58),
                    backgroundColor: _passwordController.isPasswordValid ? Color(MyColor.pr6) : Color(MyColor.se1)
                  ),
                  child: Text(
                    'Tiếp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: _passwordController.isPasswordValid ? Color(MyColor.se1) : Color(MyColor.pr6)
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}