import 'package:chillwave/apps/router/router_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../themes/colors/colors.dart';
import '../forgot_password/widgets/continue_options.dart';
import '../forgot_password/widgets/custom_button.dart';
import '../forgot_password/widgets/custom_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(MyColor.pr1), 
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                // Top wave image
                Image.asset(
                  'assets/images/login_top.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                
                // Login Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Username field
                      CustomInput(
                        hintText: 'Tên đăng nhập',
                        controller: _usernameController,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password field
                      CustomInput(
                        hintText: 'Mật khẩu',
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Color(MyColor.pr5),
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      
                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextLinkButton(
                          text: 'Quên mật khẩu',
                          onPressed: () {
                            context.goNamed(RouterName.forgotPassword);
                          },
                          textColor: Color(MyColor.pr5),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      
                      // Login button
                      CustomButton(
                        text: 'Đăng nhập',
                        onPressed: () {
                          if (_usernameController.text.isNotEmpty && 
                              _passwordController.text.isNotEmpty) {
                            context.goNamed(RouterName.profile);
                          } else {
                            // Show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                            );
                          }
                        },
                        backgroundColor: Color(MyColor.pr4),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Create account text
                      GestureDetector(
                        onTap: () {
                          context.goNamed(RouterName.register);
                        },
                        child: Text(
                          'Tạo tài khoản',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(MyColor.pr5),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Continue options (with email and Google)
                      const ContinueOptions(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}