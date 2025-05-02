import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../../../themes/colors/colors.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final Function(String code) onContinue;
  final VoidCallback onChangeEmail;

  const VerificationScreen({
    Key? key,
    required this.email,
    required this.onContinue,
    required this.onChangeEmail,
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _verificationController = TextEditingController();

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // Dimmed background
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.05),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                
                // Logo Container - positioned at top right
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'lib/assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Forget Password text
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Forget Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(MyColor.pr6),
                      fontStyle: FontStyle.italic,
                      fontFamily: 'RobotoSlab',
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Verification Card - with more prominent border and color
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(MyColor.pr4).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Verification',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'RobotoSlab',
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Verification sent to email text - now black
                      const Center(
                        child: Text(
                          'a verification code has been sent to your email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Verification code input
                      CustomInput(
                        hintText: 'Verification code',
                        controller: _verificationController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Reset Password',
                        onPressed: () {
                          if (_verificationController.text.isNotEmpty) {
                            widget.onContinue(_verificationController.text);
                          }
                        },
                        backgroundColor: const Color(MyColor.pr5),
                      ),
                      
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextLinkButton(
                          text: 'Change Email',
                          onPressed: widget.onChangeEmail,
                          textColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100),
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildDisabledContinueButton(
                      imagePath: 'lib/assets/icons/email.png',
                      text: 'Tiếp tục với email',
                      backgroundColor: const Color(MyColor.pr5).withOpacity(0.5),
                    ),
                    const SizedBox(height: 10),
                    _buildDisabledContinueButton(
                      imagePath: 'lib/assets/icons/google.png',
                      text: 'Tiếp tục bằng Google',
                      backgroundColor: Colors.white.withOpacity(0.5),
                      textColor: Colors.black87.withOpacity(0.5),
                      borderColor: Colors.grey[300]!,
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDisabledContinueButton({
    required String imagePath,
    required String text,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Color? borderColor,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Opacity(
              opacity: 0.5,
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
              ),
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
    );
  }
}