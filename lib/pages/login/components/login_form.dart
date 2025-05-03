import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chillwave/apps/router/router_name.dart';
import 'custom_text_field.dart';
import 'login_button.dart';
import '../../../themes/colors/colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username field
        CustomTextField(
          controller: _usernameController,
          hintText: 'Tên đăng nhập',
          icon: null,
          obscureText: false,
          onToggleVisibility: null,
        ),
        
        const SizedBox(height: 16),
        
        // Password field with visibility toggle
        CustomTextField(
          controller: _passwordController,
          hintText: 'Mật khẩu',
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Color(MyColor.pr5),
          ),
          obscureText: _obscureText,
          onToggleVisibility: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        
        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              context.goNamed(RouterName.forgotPassword);
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Quên mật khẩu',
              style: TextStyle(
                fontSize: 12,
                color: Color(MyColor.pr5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        
        // Login button
        const LoginButton(),
      ],
    );
  }
}