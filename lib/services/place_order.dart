import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:letsshop/models/order_model.dart';
import 'package:letsshop/services/generate_order_Id.dart';
import 'package:letsshop/services/get_notifications.dart';
import 'package:letsshop/user_panel/main_screen.dart';

void placeOrder({
  required BuildContext context,
  required String customerName,
  required String customerPhone,
  required String customerAddress,
  required String customerDeviceToken,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  EasyLoading.show(status: 'Please wait...');
  if (user != null) {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('cart')
              .doc(user.uid)
              .collection('cartOrders')
              .get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      for (final docs in documents) {
        Map<String, dynamic>? data = docs.data() as Map<String, dynamic>;

        String orderId = generateOrderId();

        OrderModel orderModel = OrderModel(
          productId: data['productId'],
          categoryId: data['categoryId'],
          productName: data['productName'],
          categoryName: data['categoryName'],
          salePrice: data['salePrice'],
          fullPrice: data['fullPrice'],
          productImages: data['productImages'],
          deliveryTime: data['deliveryTime'],
          isSale: data['isSale'],
          productDescription: data['productDescription'],
          createdAt: DateTime.now(),
          updatedAt: data['updatedAt'],
          productQuantity: data['productQuantity'],
          productTotalPrice: double.parse(data['productTotalPrice'].toString()),
          customerId: user.uid,
          status: true,
          customerName: customerName,
          customerPhone: customerPhone,
          customerAddress: customerAddress,
          customerDeviceToken: customerDeviceToken,
        );

        //creatig orders Collection
        for (var x = 0; x < documents.length; x++) {
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'customerName': customerName,
                'customerPhone': customerPhone,
                'customerAddress': customerAddress,
                'customerDeviceToken': customerDeviceToken,
                'orderStatus': false,
                'createdAt': DateTime.now(),
              });

          //Uploading orders
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(user.uid)
              .collection('confirmedOrders')
              .doc(orderId)
              .set(orderModel.toMap());

          //Delete Orders
          await FirebaseFirestore.instance
              .collection('cart')
              .doc(user.uid)
              .collection('cartOrders')
              .doc(orderModel.productId.toString())
              .delete()
              .then(
                (value) => print(
                  'Product Deleted From Cart => $orderModel.productId.toString()',
                ),
              );
        }
        //send notification once order is placed
        //notification data saved to firebasefirestore
        await FirebaseFirestore.instance
            .collection('Order Notifications')
            .doc(user.uid)
            .collection('Notifications')
            .doc()
            .set({
              'title': 'Order Scuccessfully placed! ${orderModel.productName}',
              'body': orderModel.productDescription,
              'isSeen': false,
              'createdAt': DateTime.now(),
              'image': orderModel.productImages,
              'fullPrice': orderModel.fullPrice,
              'salePrice': orderModel.salePrice,
              'isSale': orderModel.isSale,
              'productId': orderModel.productId,
            });
      }
      print('Order Confirmed!!');
      // Get.snackbar(
      //   'Order Confirmed!',
      //   'Thank You for shopping!',
      //   backgroundColor: AppConstants.AppMainColor,
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 3),
      // );

      await GetNotifications.getNotificationFromApi(
        token:
            'ffuWolJaR_KUY5HHkqeSCN:APA91bHeP9Uv1tBJmeBSVBreWbaVLX_M8f83sVDSSO56pBaSOzgCko3fgZ-CCsbgfSmj322va4oRX5RKQ6JnRgu6XJlAz1rbR86B5RBuXiCnHzvci9U8uHw',
        title: 'Order Confirmed!',
        body: 'Thank you for shopping!',
        data: {'screen': 'NotificationScreen'},
      );

      EasyLoading.dismiss();
      Get.to(() => MainScreen());
    } catch (e) {
      print('Error $e');
    }
  }
}
