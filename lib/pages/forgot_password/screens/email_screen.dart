import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/continue_options.dart';
import '../../../themes/colors/colors.dart';

class EmailScreen extends StatefulWidget {
  final Function(String email) onContinue;

  const EmailScreen({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            
            // Logo Container
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 80, 
                height: 80, 
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('lib/assets/logo.png', fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Forgot Password Text
            const Center(
              child: Text(
                'Forget Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.pr6),
                  fontFamily: 'RobotoSlab',
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Email Input
            CustomInput(
              hintText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // Send Code Button
            CustomButton(
              text: 'Send Code',
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  widget.onContinue(_emailController.text);
                }
              },
              backgroundColor: const Color(MyColor.pr5), 
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextLinkButton(
                text: 'Try anotherway ?',
                onPressed: () {
                },
                textColor: Color(MyColor.pr5),
                textStyle: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 100),

            const ContinueOptions(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}