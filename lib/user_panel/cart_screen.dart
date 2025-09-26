import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/cart_controllers.dart';
import 'package:letsshop/controllers/product_price_controller.dart';
import 'package:letsshop/models/cart_model.dart';
import 'package:letsshop/user_panel/checkout_screen.dart';
import 'package:letsshop/utils/app_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  ProductPriceController productPriceController = Get.put(ProductPriceController());
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CartController>().resetCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Screen', style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.AppMainColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('cartOrders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error found: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Products not found! Please add products to cart :)'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
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
                    title: 'Delete',
                    icon: const Icon(Icons.delete_forever_outlined),
                    onTap: (handler) async {
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
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text("PKR ${cartModel.productTotalPrice}/="),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            if (cartModel.productQuantity > 1) {
                              final price = double.parse(
                                  cartModel.isSale ? cartModel.salePrice : cartModel.fullPrice);
                              await FirebaseFirestore.instance
                                  .collection('cart')
                                  .doc(user!.uid)
                                  .collection('cartOrders')
                                  .doc(cartModel.productId)
                                  .update({
                                'productQuantity': cartModel.productQuantity - 1,
                                'productTotalPrice': price * (cartModel.productQuantity - 1),
                              });
                            }
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppConstants.AppMainColor,
                            child: Text('-', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () async {
                            final price = double.parse(
                                cartModel.isSale ? cartModel.salePrice : cartModel.fullPrice);
                            await FirebaseFirestore.instance
                                .collection('cart')
                                .doc(user!.uid)
                                .collection('cartOrders')
                                .doc(cartModel.productId)
                                .update({
                              'productQuantity': cartModel.productQuantity + 1,
                              'productTotalPrice': price * (cartModel.productQuantity + 1),
                            });
                          },
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppConstants.AppMainColor,
                            child: Text('+', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Obx(
                  () => Text(
                    '${productPriceController.totalPrice.toStringAsFixed(1)} : PKR',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              ],
            ),
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const CheckoutScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.AppMainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
