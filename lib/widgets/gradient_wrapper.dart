import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class GradientWrapper extends StatelessWidget {
  final Widget child;

  const GradientWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(MyColor.pr3), Color(MyColor.se1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
