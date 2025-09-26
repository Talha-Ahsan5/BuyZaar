import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/forget_password_controller.dart';
import 'package:letsshop/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgetPasswordController forgetPasswordController = Get.put(
    ForgetPasswordController(),
  );

  TextEditingController userEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 120),
              _buildHeader(),
              const SizedBox(height: 50),
              _buildTextFieldSection(
                controller: userEmail,
                label: 'Email Address',
                hintText: 'hello@example.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              _buildForgotPasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return ElevatedButton(
      onPressed: () async {
        String emailUser = userEmail.text.trim();
        if (emailUser.isEmpty) {
          Get.snackbar(
            'Incomplete Details',
            'Please fill the fields completely',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue[400],
            colorText: Colors.white,
          );
        } else {
          // Trigger your forget password logic here
          String email = userEmail.text.trim();
          forgetPasswordController.ForgotPassword(email);
          
          Get.offAll(LoginScreen());
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 122, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text('Reset Password'),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: Get.width,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Password',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 5,),
          Text(
            'Enter the email where you want to receive the reset password link.',
            style: TextStyle(fontSize: 14,),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSection({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }
}
