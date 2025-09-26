import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/google_signIn_controller.dart';
import 'package:letsshop/controllers/signUp_controller.dart';
import 'package:letsshop/screens/login_screen.dart';
import 'package:letsshop/services/notification_services.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FocusNode _focusNode = FocusNode();

  final SignUpController signUpController = Get.put(SignUpController());
  final GoogleSigninController _googleSigninController = Get.put(GoogleSigninController());

  // TextEditingControllers
  final TextEditingController userName = TextEditingController();
  final TextEditingController userEmail = TextEditingController();
  final TextEditingController userPassword = TextEditingController();
  final TextEditingController userCity = TextEditingController();
  final TextEditingController userPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    userName.dispose();
    userEmail.dispose();
    userPassword.dispose();
    userCity.dispose();
    userPhone.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 50),
              _buildHeader(),
              SizedBox(height: 15),
              _buildTextFieldSection(
                controller: userName,
                label: 'Full Name',
                hintText: 'John Doe',
                icon: Icons.person,
                keyboardType: TextInputType.name,
                focusNode: _focusNode,
              ),
              SizedBox(height: 10),
              _buildTextFieldSection(
                controller: userEmail,
                label: 'Email Address',
                hintText: 'hello@example.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              _buildTextFieldSection(
                controller: userPhone,
                label: 'Phone Number',
                hintText: '03012345679',
                icon: Icons.phone,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              _buildTextFieldSection(
                controller: userCity,
                label: 'City',
                hintText: 'Karachi',
                icon: Icons.location_city,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 10),
              _buildPasswordField(), // This line is updated to use the custom password field
              SizedBox(height: 10),
              _buildPolicyText(),
              SizedBox(height: 20),
              _buildSignUpButton(),
              SizedBox(height: 10),
              _buildDivider(),
              SizedBox(height: 10),
              _buildGoogleSignInButton(),
              SizedBox(height: 20),
              _buildFooterText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create an account',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
    bool obscureText = false,
    IconData? suffixIcon,
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }

  // This is the password field with password visibility toggle
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 5),
        Obx(
          () => TextFormField(
            controller: userPassword,
            obscureText: signUpController.isPasswordHidden.value,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.password_rounded),
              suffixIcon: GestureDetector(
                onTap: () => signUpController.togglePasswordVisibility(),
                child: Icon(
                  signUpController.isPasswordHidden.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyText() {
    return SizedBox(
      width: Get.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By continuing, you agree to our ',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
          SizedBox(width: 3),
          GestureDetector(
            onTap: () {},
            child: Text(
              'terms of service.',
              style: TextStyle(
                color: Colors.blue[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    double screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: () async {
        // print('Sign Up tapped!');
        // print('Name: ${userName.text}');
        // print('Email: ${userEmail.text}');
        // print('Phone: ${userPhone.text}');
        // print('City: ${userCity.text}');
        // print('Password: ${userPassword.text}');
        NotificationServices notificationServices = NotificationServices();
        String name = userName.text.trim();
        String email = userEmail.text.trim();
        String password = userPassword.text.trim();
        String city = userCity.text.trim();
        String phoneNum = userPhone.text.trim();
        String deviceToken = await notificationServices.getDeviceToken();

        if (name.isEmpty ||
            email.isEmpty ||
            password.isEmpty ||
            city.isEmpty ||
            phoneNum.isEmpty) {
          Get.snackbar(
            'Incomplete Details',
            'Please enter all details',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue[400],
            colorText: Colors.white,
          );
        } else {
          UserCredential? userCredential = await signUpController.signUp(
            name,
            email,
            phoneNum,
            city,
            password,
            deviceToken,
          );
          if (userCredential != null) {
            Get.snackbar(
              'Verification Email Sent',
              'Please check your email to proceed',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue[400],
              colorText: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10),
            );
            FirebaseAuth.instance.signOut();
            Get.offAll(() => LoginScreen());
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.3,
          vertical: 14,
        ),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sign Up',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade500, thickness: 1)),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('or', style: TextStyle(color: Colors.grey.shade500)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade500, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton(
      onPressed: () {
        _googleSigninController.SignInWithGoogle();
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
        backgroundColor: Colors.grey.shade400,
        foregroundColor: Colors.black.withOpacity(0.5),
      ),
      child: Row(
        children: [
          SizedBox(width: 40),
          Image.asset(
            'lib/assets/images/google-logo.png',
            height: 25,
            width: 25,
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterText() {
    return SizedBox(
      width: Get.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
            child: Text(
              'Sign in here',
              style: TextStyle(
                color: Colors.blue[400],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
