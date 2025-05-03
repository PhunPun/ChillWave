import 'package:flutter/material.dart';
import 'custom_wave_clipper.dart';
import '../../../themes/colors/colors.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        Container(
          height: size.height,
          width: size.width,
          color: Color(MyColor.pr1),
        ),
        
        Positioned(
          top: 0,
          child: Container(
            height: 120,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(MyColor.se1),
                  Color(MyColor.se2),
                ],
              ),
            ),
          ),
        ),
        
        Positioned(
          top: size.height * 0.18,
          child: ClipPath(
            clipper: CustomWaveClipper(),
            child: Container(
              height: 70,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(MyColor.pr2),
                    Color(MyColor.pr4), 
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}