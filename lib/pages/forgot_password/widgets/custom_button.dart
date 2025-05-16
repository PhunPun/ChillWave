import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(MyColor.pr5),
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class TextLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final TextStyle? textStyle;

  const TextLinkButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor = const Color(MyColor.pr5),
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400).merge(textStyle)
      ),
    );
  }
}
