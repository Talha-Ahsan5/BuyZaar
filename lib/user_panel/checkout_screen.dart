// Stripe import removed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/cart_controllers.dart';
import 'package:letsshop/controllers/get_customer_device_token.dart';
import 'package:letsshop/controllers/product_price_controller.dart';
import 'package:letsshop/models/cart_model.dart';
import 'package:letsshop/services/place_order.dart';
import 'package:letsshop/utils/app_constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ProductPriceController productPriceController = Get.put(ProductPriceController());
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CartController>().resetCart();
    });
  }

  void _onConfirmOrderPressed(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add products to cart before confirming order.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    placeOrderScreenBottomSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout Screen', style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.AppMainColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('cartOrders')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error found: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Products not found! Please add products to cart :)'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index];
              CartModel cartModel = CartModel(
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
              );

              return SwipeActionCell(
                key: ObjectKey(cartModel.productId),
                trailingActions: [
                  SwipeAction(
                    forceAlignmentToBoundary: true,
                    performsFirstActionWithFullSwipe: true,
                    title: 'Delete',
                    icon: Icon(Icons.delete_forever_outlined),
                    onTap: (CompletionHandler handler) async {
                      await FirebaseFirestore.instance
                          .collection('cart')
                          .doc(user!.uid)
                          .collection('cartOrders')
                          .doc(cartModel.productId)
                          .delete();
                    },
                  ),
                ],
                child: Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      cartModel.productName,
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 17),
                    ),
                    subtitle: Text("PKR ${cartModel.productTotalPrice}/="),
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.AppMainColor,
                      backgroundImage: NetworkImage(cartModel.productImages[0]),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('cartOrders')
            .snapshots(),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Obx(
                      () => Text(
                        '${productPriceController.totalPrice.toStringAsFixed(1)} : PKR',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                    // GetServerKey getServerKey = GetServerKey();
                    // String accesstoken = await getServerKey.GetServiceKeyToken();
                    // print(accesstoken);
                    _onConfirmOrderPressed(snapshot);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.AppMainColor,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirm Order',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void placeOrderScreenBottomSheet(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  Get.bottomSheet(
    Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: phoneController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: addressController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Full Address',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 70),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.AppMainColor,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final ctx = context;
                        String customerToken = await getUserDeviceToken();

                        // Just place order directly
                        placeOrder(
                          context: ctx,
                          customerName: fullNameController.text.trim(),
                          customerPhone: phoneController.text.trim(),
                          customerAddress: addressController.text.trim(),
                          customerDeviceToken: customerToken,
                        );

                        // Reset cart
                        Get.find<CartController>().resetCart();
                        Get.find<ProductPriceController>().reset();
                        Get.back();

                        // Get.snackbar(
                        //   "Success",
                        //   "Your order has been placed!",
                        //   backgroundColor: Colors.blue,
                        //   colorText: Colors.white,
                        // );
                      } catch (e) {
                        print('Error: $e');
                        Get.snackbar(
                          "Error",
                          "An error occurred. Please try again.",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Place Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    isDismissible: true,
    elevation: 6,
    enableDrag: true,
  );
}
