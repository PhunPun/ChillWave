import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/continue_options.dart';
import '../../../themes/colors/colors.dart';

class NewPasswordScreen extends StatefulWidget {
  final Function(String password, String confirmPassword) onSubmit;

  const NewPasswordScreen({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            
            // Logo Container - positioned at top right
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 80, // Slightly larger
                height: 80, // Slightly larger
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
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
            
            const SizedBox(height: 30),
            
            // Password requirements text
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 30),
              child: const Center(
                child: Text(
                  'Your password must be at-least 8 characters long',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(MyColor.black),
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            
            // New Password Input
            CustomInput(
              hintText: 'Enter new password',
              controller: _passwordController,
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Confirm Password Input
            CustomInput(
              hintText: 'Reconfirm new password',
              controller: _confirmPasswordController,
              obscureText: !_confirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Change Password Button
            CustomButton(
              text: 'Change password',
              onPressed: () {
                final password = _passwordController.text;
                final confirmPassword = _confirmPasswordController.text;
                
                if (password.length < 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 8 characters long'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                widget.onSubmit(password, confirmPassword);
              },
            ),
            
            const SizedBox(height: 100),
            
            // Continue Options
            const ContinueOptions(),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}