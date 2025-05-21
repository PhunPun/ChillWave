import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chillwave/apps/router/router_name.dart';
import '../../../themes/colors/colors.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: () {
          context.goNamed(RouterName.profile);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(MyColor.pr4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Đăng nhập',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}