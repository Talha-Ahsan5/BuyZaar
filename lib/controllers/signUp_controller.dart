import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/get_token_controller.dart';
import 'package:letsshop/models/user_models.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final GetTokenController tokenController = Get.put(GetTokenController());

  //Password Visibilty
  RxBool isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<UserCredential?> signUp(
    String userName,
    String userEmail,
    String userPhoneNum,
    String userCity,
    String userPassword,
    String userDiviceToken,
  ) async {
    try {
      EasyLoading.show(status: 'Please wait...');

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: userEmail,
            password: userPassword,
          );

      await userCredential.user!.sendEmailVerification();

      UserModel userModel = UserModel(
        uId: userCredential.user!.uid,
        username: userName,
        email: userEmail,
        phone: userPhoneNum,
        userImg: '',
        // userDeviceToken: tokenController.tokenId.toString(),
        userDeviceToken: userDiviceToken,
        country: '',
        userAddress: '',
        street: '',
        isAdmin: false,
        isActive: true,
        createdOn: DateTime.now(),
        city: userCity,
      );

      _firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());
      EasyLoading.dismiss();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // print(e);
      Get.snackbar(
        'Error',
        '$e',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      EasyLoading.dismiss();
      return null;
    }
  }
}
