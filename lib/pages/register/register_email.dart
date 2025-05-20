import 'package:chillwave/controllers/register_controller/emailController.dart';
import 'package:chillwave/pages/register/register_password.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class RegisterEmail extends StatefulWidget {
  const RegisterEmail({super.key});

  @override
  State<RegisterEmail> createState() => _RegisterEmailState();
}

class _RegisterEmailState extends State<RegisterEmail> {
  final FocusNode focusNode = FocusNode();
  final EmailController _emailController = EmailController();
  bool isFocused = false;
  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
    _emailController.emailController.addListener(() {
      setState(() {
        // Cập nhật lại để hiển thị lỗi (errorText)
      });
    });
    _emailController.addListener((){
      setState(() {
        
      });
    });
  }
  @override
  void dispose() {
    focusNode.dispose();
    _emailController.dispose();
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
                'Email của bạn là gì?',
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
                  controller: _emailController.emailController,
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
              if (_emailController.errorText != null)
                Text(
                  _emailController.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              const SizedBox(height: 5,),
              Text(
                'Bạn cần xác nhận email này sau',
                style: TextStyle(
                  fontSize: 12
                ),
              ),
              const SizedBox(height: 28,),
              Center(
                child: ElevatedButton(
                  onPressed: _emailController.isEmailValid 
                    ? () {
                      final email = _emailController.emailController.text.trim();
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => RegisterPassword(
                            email: email,
                          )));
                      }: null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(127, 58),
                    backgroundColor: _emailController.isEmailValid ? Color(MyColor.pr6) : Color(MyColor.se1)
                  ),
                  child: Text(
                    'Tiếp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: _emailController.isEmailValid ? Color(MyColor.se1) : Color(MyColor.pr6)
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