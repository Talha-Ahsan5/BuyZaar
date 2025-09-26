// ignore_for_file: override_on_non_overriding_member, non_constant_identifier_names

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetTokenController extends GetxController {
  String? tokenId;

  @override
  void onInit() {
    super.onInit();
    GetToken();
  }

  Future<void> GetToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        tokenId = token;
        print('token:  $tokenId');
        update();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }
}
