import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsshop/models/order_model.dart';
import 'package:letsshop/user_panel/add_reviews_screen.dart';
import 'package:letsshop/utils/app_constants.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllordersScreenState();
}

class _AllordersScreenState extends State<AllOrdersScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Orders so far',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstants.AppMainColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .doc(user!.uid)
                .collection('confirmedOrders')
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error found: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Orders not found! Please add products to cart :)'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final productData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Safely retrieve 'customerDeviceToken' or provide a default value
              var customerDeviceToken =
                  productData.containsKey('customerDeviceToken')
                      ? productData['customerDeviceToken']
                      : 'default_token'; // Use 'default_token' as fallback

              // Creating the OrderModel with the data, including the safely fetched token
              OrderModel orderModel = OrderModel(
                productId: productData['productId'],
                categoryId: productData['categoryId'],
                productName: productData['productName'],
                categoryName: productData['categoryName'],
                salePrice: productData['salePrice'],
                fullPrice: productData['fullPrice'],
                productImages: productData['productImages'],
                deliveryTime: productData['deliveryTime'],
                isSale: productData['isSale'],
                productDescription: productData['productDescription'],
                createdAt: productData['createdAt'],
                updatedAt: productData['updatedAt'],
                productQuantity: productData['productQuantity'],
                productTotalPrice: productData['productTotalPrice'],
                customerId: productData['customerId'],
                customerName: productData['customerName'],
                customerPhone: productData['customerPhone'],
                customerAddress: productData['customerAddress'],
                customerDeviceToken: customerDeviceToken,
                status: productData['status'],
              );

              return Card(
                elevation: 5,
                child: ListTile(
                  title: Text(
                    orderModel.productName,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17),
                  ),
                  subtitle: Row(
                    children: [
                      Text("PKR ${orderModel.productTotalPrice}/="),
                      SizedBox(width: 10),
                      orderModel.status != true
                          ? Text(
                            'Pending',
                            style: TextStyle(color: Colors.red),
                          )
                          : Text(
                            'Delivered',
                            style: TextStyle(color: Colors.green),
                          ),
                    ],
                  ),
                   trailing:
                      orderModel.status == true
                          ? ElevatedButton(
                            onPressed: () {
                              Get.to(() => AddReviewsScreen(
                                orderModel: orderModel,
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.AppMainColor,
                            ),
                            child: Text('Give Reviews', style: TextStyle(fontSize: 10, color: Colors.white),),
                          )
                          : SizedBox.shrink(),
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.AppMainColor,
                    backgroundImage: NetworkImage(orderModel.productImages[0]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
