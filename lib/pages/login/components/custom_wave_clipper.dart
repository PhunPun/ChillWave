import 'package:flutter/material.dart';

class CustomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, 0);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height / 2);
    path.quadraticBezierTo(
      firstControlPoint.dx, 
      firstControlPoint.dy, 
      firstEndPoint.dx, 
      firstEndPoint.dy
    );
    
    var secondControlPoint = Offset(size.width - (size.width / 4), 0);
    var secondEndPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(
      secondControlPoint.dx, 
      secondControlPoint.dy, 
      secondEndPoint.dx, 
      secondEndPoint.dy
    );
    
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}