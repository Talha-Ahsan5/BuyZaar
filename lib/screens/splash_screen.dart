import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsshop/admin_panel/admin_screen.dart';
import 'package:letsshop/screens/login_screen.dart';
import 'package:letsshop/user_panel/main_screen.dart';
import 'package:letsshop/utils/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

@override
void initState() {
  super.initState();

  // final notificationServices = NotificationServices();

  // // ✅ Set up notifications as early as possible
  // notificationServices.requestNotificationPermission();
  // notificationServices.getDeviceToken();
  // notificationServices.firebaseInit(context);
  // notificationServices.setUpInteractMessage(context);

  // ✅ Safe navigation after splash delay
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _timer = Timer(const Duration(seconds: 5), () {
      _checkLoginStatus();
    });
  });
}


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in, let's check Firestore for user role
      try {
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .where('uId', isEqualTo: currentUser.uid)
            .get();

        if (userData.docs.isNotEmpty) {
          var userDoc = userData.docs.first;
          bool isAdmin = userDoc['isAdmin'] ?? false;

          // Debugging: Check user data and role
          print("User ID: ${currentUser.uid}, Admin: $isAdmin");

          if (isAdmin) {
            // If user is admin, navigate to AdminScreen
            Get.offAll(() => AdminScreen());
          } else {
            // Otherwise, navigate to MainScreen
            Get.offAll(() => MainScreen());
          }
        } else {
          // If no user data found, navigate to LoginScreen
          Get.offAll(() => LoginScreen());
        }
      } catch (e) {
        // In case of an error, log and navigate to LoginScreen
        print("Error fetching user data: $e");
        Get.offAll(() => LoginScreen());
      }
    } else {
      // If no user is logged in, navigate to LoginScreen
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Expanded(
              child: Center(
                child: Lottie.asset(
                  'lib/assets/images/splash_screen.json',
                  height: 400,
                  width: 400,
                  fit: BoxFit.contain,
                  onLoaded: (composition) => debugPrint('✅ Lottie loaded'),
                ),
              ),
            ),
            // Powered By Text
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                AppConstants.AppPoweredBy,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF074D86),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
