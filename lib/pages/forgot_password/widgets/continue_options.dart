import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class ContinueOptions extends StatelessWidget {
  const ContinueOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildContinueButton(
          imagePath: 'lib/assets/icons/email.png',
          text: 'Tiếp tục với email',
          backgroundColor: const Color(MyColor.pr5),
          onTap: () {
            // Handle email continue option
          },
        ),
        const SizedBox(height: 10),
        _buildContinueButton(
          imagePath: 'lib/assets/icons/google.png',
          text: 'Tiếp tục bằng Google',
          backgroundColor: const Color(MyColor.white),
          textColor: const Color(MyColor.black),
          borderColor: Colors.grey[300]!,
          onTap: () {
            // Handle Google continue option
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