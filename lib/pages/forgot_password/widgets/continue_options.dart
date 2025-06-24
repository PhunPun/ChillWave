import 'package:chillwave/apps/router/router_name.dart';
import 'package:chillwave/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../themes/colors/colors.dart';

class ContinueOptions extends StatelessWidget {
  const ContinueOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildContinueButton(
          imagePath: 'assets/icons/google.png',
          text: 'Tiếp tục bằng Google',
          backgroundColor: const Color(MyColor.white),
          textColor: const Color(MyColor.black),
          borderColor: Colors.grey[300]!,
          onTap: () async {
            final userCredential = await AuthService.signInWithGoogle();
            if (!context.mounted) return;

            if (userCredential != null) {
              final user = userCredential.user!;
              final uid = user.uid;

              final favoritesRef = FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('favorites')
                .where('categories', isEqualTo: 'artists');
              final snapshot = await favoritesRef.get();
              if (!context.mounted) return;
              if (snapshot.docs.isEmpty) {
                context.goNamed(RouterName.select);
              } else {
                context.goNamed(RouterName.home);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Đăng nhập thành công: ${user.email}"),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Đăng nhập thất bại hoặc bị hủy."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildContinueButton({
    required String imagePath,
    required String text,
    required Color backgroundColor,
    Color textColor = const Color(MyColor.white),
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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