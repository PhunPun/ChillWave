import 'package:chillwave/controllers/register_controller/register_flow_controller.dart';
import 'package:chillwave/controllers/register_controller/username_controller.dart';
import 'package:chillwave/pages/login/login_page.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';


class RegisterUsername extends StatefulWidget {
  final String email;
  final String password;
  const RegisterUsername({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterUsername> createState() => _RegisterUsernameState();
}

class _RegisterUsernameState extends State<RegisterUsername> {
  final FocusNode focusNode = FocusNode();
  final UsernameController _usernameController = UsernameController();
  bool isFocused = false;
  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
    _usernameController.addListener(() {
      setState(() {
        
      });
    });
  }
  @override
  void dispose() {
    focusNode.dispose();
    _usernameController.dispose();
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
                'Tên của bạn là gì?',
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
                  controller: _usernameController.usernameController,
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
              if (_usernameController.errorText != null)
                Text(
                  _usernameController.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              const SizedBox(height: 28,),
              Center(
                child: ElevatedButton(
                  onPressed: _usernameController.isUsernameValid ? () async {
                    final username = _usernameController.usernameController.text.trim();                    
                    final registerFlow = RegisterFlowController();
                    final error = await registerFlow.registerUser(
                      email: widget.email,
                      password: widget.password,
                      username: username,
                    );
                    if (error == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Color(MyColor.pr2),
                          title: const Text('Thành công', style: TextStyle(color: Color(MyColor.pr6)),),
                          content: const Text('Tài khoản đã được tạo thành công. \n Chuyển đến màng hình đăng nhập'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => LoginPage())
                                );
                              },
                              child: const Text('OK', style: TextStyle(color: Color(MyColor.pr6)),),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Color(MyColor.se1),
                          title: const Text('Lỗi', style: TextStyle(color: Color(MyColor.se3)),),
                          content: Text(error),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Thử lại', style: TextStyle(color: Color(MyColor.se4)),),
                            ),
                          ],
                        ),
                      );
                    }
                  }: null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(127, 50),
                    backgroundColor: _usernameController.isUsernameValid ? Color(MyColor.pr6) : Color(MyColor.se1)
                  ),
                  child: Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: _usernameController.isUsernameValid ? Color(MyColor.se1) : Color(MyColor.pr6)
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