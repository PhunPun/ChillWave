import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? icon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.obscureText,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color(MyColor.white),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(MyColor.grey).withValues(alpha: 0.7),
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: InputBorder.none,
          suffixIcon: icon != null
              ? IconButton(
                  icon: icon!,
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}