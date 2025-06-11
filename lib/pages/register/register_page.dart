import 'package:chillwave/apps/router/router_name.dart';
import 'package:chillwave/pages/register/register_email.dart';
import 'package:chillwave/services/auth_service.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 150, height: 150,),
              const SizedBox(height: 65,),
              Text(
                'Đăng ký để bắt đầu nghe',
                style: TextStyle(
                  color: Color(MyColor.se4),
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 180,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 35),
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(MyColor.pr5)
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterEmail()));
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Icon(Icons.email_outlined, color: Color(MyColor.white), size: 20,),
                      ),
                      Expanded(
                        flex: 8,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Tiếp tục với Email',
                            style: TextStyle(
                              color: Color(MyColor.white),
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 35),
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Color(MyColor.white),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color(MyColor.pr6)
                      )
                    )
                  ),
                  onPressed: () async {
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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Image.asset('assets/images/google.png'),
                      ),
                      Expanded(
                        flex: 8,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Tiếp tục Bằng Google',
                            style: TextStyle(
                              color: Color(MyColor.pr6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 45,),
              Text(
                'Bạn đã có tài khoản?'
              ),
              InkWell(
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Color(MyColor.se4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}