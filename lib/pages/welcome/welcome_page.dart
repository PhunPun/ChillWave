import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chillwave/apps/router/router_name.dart';
import '../../../themes/colors/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(MyColor.pr1),
              Color(MyColor.pr2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                const Text(
                  "Welcome to ChillWave",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(MyColor.pr5),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Your relaxing music and meditation app",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(MyColor.pr6),
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Login button
                _buildButton(
                  text: "Đăng nhập",
                  onPressed: () {
                    context.goNamed(RouterName.login);
                  },
                  backgroundColor: Color(MyColor.pr4),
                ),
                
                const SizedBox(height: 16),
                
                // Register button
                _buildButton(
                  text: "Tạo tài khoản",
                  onPressed: () {
                    context.goNamed(RouterName.register);
                  },
                  backgroundColor: Color(MyColor.se2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Container(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}