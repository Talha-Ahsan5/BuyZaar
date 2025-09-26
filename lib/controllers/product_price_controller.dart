import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProductPriceController extends GetxController {
  RxDouble totalPrice = 0.0.obs;
  final User? user = FirebaseAuth.instance.currentUser;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('cartOrders')
        .snapshots()
        .listen((snapshot) {
      double sum = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('productTotalPrice')) {
          sum += (data['productTotalPrice'] as num).toDouble();
        }
      }
      totalPrice.value = sum;
    });
  }

  /// Call this to manually reset the price to zero (e.g., after placing order)
  void reset() {
    totalPrice.value = 0.0;
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
