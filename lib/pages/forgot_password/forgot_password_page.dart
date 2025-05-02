import 'package:flutter/material.dart';
import 'screens/email_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/new_password_screen.dart';
import 'package:go_router/go_router.dart';
import '../../themes/colors/colors.dart';

enum ForgotPasswordStep {
  email,
  verification,
  newPassword,
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.email;
  String _email = '';
  String _verificationCode = '';
  
  void _handleEmailSubmit(String email) {
    setState(() {
      _email = email;
      _currentStep = ForgotPasswordStep.verification;
    });
  }
  
  void _handleVerificationSubmit(String code) {
    setState(() {
      _verificationCode = code;
      _currentStep = ForgotPasswordStep.newPassword;
    });
  }
  
  void _handleBackToEmail() {
    setState(() {
      _currentStep = ForgotPasswordStep.email;
    });
  }
  
  void _handlePasswordSubmit(String password, String confirmPassword) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password successfully changed!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back to login page
    context.go('/login');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(MyColor.pr3),
                  Color(MyColor.se1), 
                ],
                stops: [0.3, 1.0], 
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                if (_currentStep == ForgotPasswordStep.email) {
                  context.go('/login');
                } else if (_currentStep == ForgotPasswordStep.verification) {
                  setState(() {
                    _currentStep = ForgotPasswordStep.email;
                  });
                } else if (_currentStep == ForgotPasswordStep.newPassword) {
                  setState(() {
                    _currentStep = ForgotPasswordStep.verification;
                  });
                }
              },
            ),
          ),

          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case ForgotPasswordStep.email:
        return EmailScreen(
          onContinue: _handleEmailSubmit,
        );
      case ForgotPasswordStep.verification:
        return VerificationScreen(
          email: _email,
          onContinue: _handleVerificationSubmit,
          onChangeEmail: _handleBackToEmail,
        );
      case ForgotPasswordStep.newPassword:
        return NewPasswordScreen(
          onSubmit: _handlePasswordSubmit,
        );
    }
  }
}