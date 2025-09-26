// controllers/notification_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  User? user = FirebaseAuth.instance.currentUser;
  var notificationCount = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchNotificationCount();
  }

  void fetchNotificationCount() {
    FirebaseFirestore.instance
        .collection('Order Notifications')
        .doc(user!.uid)
        .collection('Notifications')
        .where('isSeen', isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
          notificationCount.value = querySnapshot.docs.length;
          print('Notification Count => ${notificationCount.value}');
          update();
        });
  }
}
