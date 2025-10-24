import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsshop/admin_panel/admin_screen.dart';
import 'package:letsshop/controllers/get_userdata_controller.dart';
import 'package:letsshop/controllers/google_signin_controller.dart';
import 'package:letsshop/controllers/signIn_controller.dart';
import 'package:letsshop/screens/forgot_password_screen.dart';

import 'package:letsshop/screens/sign_up.dart';
import 'package:letsshop/user_panel/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSigninController _googleSigninController = Get.put(
    GoogleSigninController(),
  );

  final GetUserdataController getUserdataController = Get.put(
    GetUserdataController(),
  );

  final SignInController signInController = Get.put(SignInController());
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPass = TextEditingController();

  bool keepMeSignedIn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the body in a scroll view to handle overflow
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 120),
              _buildHeader(),
              SizedBox(height: 65),
              _buildTextFieldSection(
                controller: userEmail,
                label: 'Email Address',
                hintText: 'hello@example.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              // _buildTextFieldSection(
              //   controller: userPass,
              //   label: 'Password',
              //   hintText: 'Password',
              //   icon: Icons.password_rounded,
              //   keyboardType: TextInputType.text,
              //   obscureText: true,
              //   suffixIcon: Icons.visibility_off,
              // ),
              _buildPasswordField(),
              SizedBox(height: 15),
              _buildCheckbox(),
              SizedBox(height: 2),
              _buildLoginButton(),
              SizedBox(height: 45),
              _buildDivider(),
              SizedBox(height: 50),
              _buildGoogleSignInButton(),
              SizedBox(height: 50),
              _buildSignUpLink(),
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
            'Login',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
          ),
          Text('Getting started with your account'),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row for "Password" and "Forgot Password?"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password', style: TextStyle(fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: () {
                // Navigate to Forgot Password screen
                Get.to(ForgotPasswordScreen()); // Or your route
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Password field
        Obx(
          () => TextFormField(
            controller: userPass,
            obscureText: signInController.isPasswordHidden.value,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.password_rounded),
              suffixIcon: GestureDetector(
                onTap: () => signInController.togglePasswordVisibility(),
                child: Icon(
                  signInController.isPasswordHidden.value
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

  Widget _buildCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: keepMeSignedIn,
          onChanged: (bool? value) {
            setState(() {
              keepMeSignedIn = value ?? false;
            });
          },
          activeColor: Colors.blue,
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.5),
          child: Text(
            'Keep me signed in',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.normal,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildLoginButton() {
  return ElevatedButton(
    onPressed: () async {
      String EmailUser = userEmail.text.trim();
      String PassUser = userPass.text.trim();

      if (EmailUser.isEmpty || PassUser.isEmpty) {
        Get.snackbar(
          'Incomplete Details',
          'Please fill the fields completely',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue[400],
          colorText: Colors.white,
        );
      } else {
        UserCredential? userCredential = await signInController.SignIn(
          EmailUser,
          PassUser,
        );

        if (userCredential != null) {
          var userdata = await getUserdataController.userData(
            userCredential.user!.uid,
          );

          if (userCredential.user!.emailVerified) {
            if (keepMeSignedIn) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              await prefs.setString('uid', userCredential.user!.uid);
            }

            if (userdata[0]['isAdmin'] == true) {
              Get.snackbar(
                'Successfully Logged In as ADMIN',
                'You are being redirected to the admin screen',
                snackPosition: SnackPosition.BOTTOM,
                colorText: Colors.white,
                backgroundColor: Colors.blue[400],
              );
              Get.offAll(() => AdminScreen());
            } else {
              Get.snackbar(
                'Successfully Logged In as USER',
                'You are being redirected to the user screen',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue[400],
                colorText: Colors.white,
              );
              Get.offAll(() => MainScreen());
            }
          } else {
            Get.snackbar(
              'Sign Up Required',
              'Please Sign up or verify your email before logging in',
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.white,
              backgroundColor: Colors.blue[400],
            );
          }
        }
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 161, vertical: 14),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: Text('Login'),
  );
}


  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('or sign in with', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
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
      ),
      child: Row(
        children: [
          SizedBox(width: 45),
          Image.asset(
            'lib/assets/images/google-logo.png',
            height: 24,
            width: 24,
          ),
          SizedBox(width: 10),
          Text(
            'Continue with Google',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUp()),
        );
      },
      child: Text(
        'Create an account',
        style: TextStyle(
          color: Colors.blue[400],
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
