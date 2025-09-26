// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> ForgotPassword(String userEmail) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      await _auth.sendPasswordResetEmail(email: userEmail);
      Get.snackbar(
        'Reset Password Link sent successfully',
        'Please check $userEmail to proceed!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[400],
        colorText: Colors.white,
      );
      EasyLoading.dismiss();
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[400],
        colorText: Colors.blue[400],
      );
    }
  }
}
