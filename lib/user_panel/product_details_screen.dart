import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/calculating_ratings_controller.dart';
import 'package:letsshop/controllers/cart_controllers.dart';
import 'package:letsshop/models/cart_model.dart';
import 'package:letsshop/models/product_models.dart';
import 'package:letsshop/models/reviews_model.dart';
import 'package:letsshop/user_panel/cart_screen.dart';
import 'package:letsshop/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ProductDetailsScreen extends StatefulWidget {
  ProductModel productModel;
  ProductDetailsScreen({super.key, required this.productModel});

  @override
  State<ProductDetailsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<ProductDetailsScreen> {
  final CartController cartController = Get.find();

  User? user = FirebaseAuth.instance.currentUser;

  bool isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.AppMainColor,
        title: const Text(
          'Products Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => CartScreen()),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Obx(() {
                bool hasItems = cartController.cartItemCount.value > 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                    if (hasItems)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '${cartController.cartItemCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: Get.height / 70),
            CarouselSlider(
              items:
                  List<String>.from(widget.productModel.productImages ?? [])
                      .map(
                        (imageUrl) => ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: Get.width - 10,
                            placeholder:
                                (context, url) => const ColoredBox(
                                  color: Colors.white,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                          ),
                        ),
                      )
                      .toList(),
              options: CarouselOptions(
                scrollDirection: Axis.horizontal,
                autoPlay: true,
                aspectRatio: 2.5,
                viewportFraction: 1,
              ),
            ),
            _buildDetailsCard(
              productName: widget.productModel.productName,
              category: widget.productModel.categoryName,
              fullPrice: widget.productModel.fullPrice.toString(),
              salePrice: widget.productModel.salePrice.toString(),
              description: widget.productModel.productDescription,
            ),
            _buildReviewsSection(),
            SizedBox(height: 20), // Add some bottom spacing
          ],
        ),
      ),
    );
  }

  bool isFavorite = false; // Add this at the top of your State class

  Widget _buildDetailsCard({
    required String productName,
    required String category,
    required String salePrice,
    required String fullPrice,
    required String description,
  }) {
    CalculatingRatingsController calculatingRatingsController = Get.put(
      CalculatingRatingsController(widget.productModel.categoryId),
    );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Card(
        elevation: 5.6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name + Favorite Icon Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildInfoText('Product Name: $productName')),
                  IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                        // TODO: Save to favorite list or local DB if needed
                      });
                    },
                  ),
                ],
              ),
              //showing average reviews based on total reviews on the item...
              Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Obx(
                      () => RatingBar(
                        glow: false,
                        ignoreGestures: true,
                        initialRating:
                            calculatingRatingsController.averageRating.value,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 25,
                        itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                        ratingWidget: RatingWidget(
                          full: Icon(Icons.star, color: Colors.amber),
                          half: Icon(Icons.star_half, color: Colors.amber),
                          empty: Icon(Icons.star_border, color: Colors.amber),
                        ),
                        onRatingUpdate: (value) {},
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Obx(
                    () => Text(
                      calculatingRatingsController.averageRating.value
                          .toStringAsFixed(1),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoText('Category: $category'),
              const SizedBox(height: 20),
              widget.productModel.isSale == true &&
                      widget.productModel.salePrice != ' '
                  ? _buildInfoText('PKR: $salePrice/=')
                  : _buildInfoText('PKR: $fullPrice/='),
              const SizedBox(height: 20),
              _buildInfoText(description),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      // TODO: WhatsApp logic here

                      sendWhatAppMsgHere(productModel: widget.productModel);
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('WhatsApp'),
                  ),
                  const SizedBox(width: 50),
                  OutlinedButton.icon(
                    onPressed: () async {
                      // TODO: Cart logic here
                      await checkProductDetailsExistance(uId: user!.uid);
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.blue[200],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _showAverageReviews() {
  //   CalculatingRatingsController calculatingRatingsController = Get.put(
  //     CalculatingRatingsController(widget.productModel.categoryId),
  //   );
  //   return Row(
  //     children: [
  //       Container(
  //         alignment: Alignment.topLeft,
  //         child: RatingBar(
  //           glow: false,
  //           ignoreGestures: true,
  //           initialRating: double.parse(
  //             calculatingRatingsController.averageRating.toString(),
  //           ),
  //           minRating: 1,
  //           direction: Axis.horizontal,
  //           allowHalfRating: true,
  //           itemCount: 5,
  //           itemSize: 25,
  //           itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
  //           ratingWidget: RatingWidget(
  //             full: Icon(Icons.star, color: Colors.amber),
  //             half: Icon(Icons.star_half, color: Colors.amber),
  //             empty: Icon(Icons.star_border, color: Colors.amber),
  //           ),
  //           onRatingUpdate: (value) {},
  //         ),
  //       ),
  //       Text(calculatingRatingsController.averageRating.toString()),
  //     ],
  //   );
  // }

 Widget _buildReviewsSection() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.productModel.categoryId)
        .collection('CustomerReviews')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error found: ${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CupertinoActivityIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Text('No reviews found!');
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          var data = snapshot.data!.docs[index];
          ReviewModel reviewModel = ReviewModel(
            customerName: data['customerName'],
            customerPhone: data['customerPhone'],
            customerDeviceToken: data['customerDeviceToken'],
            customerId: data['customerId'],
            feedback: data['feedback'],
            ratings: data['ratings'],
            createdAt: data['createdAt'],
          );

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade300,
                        child: Text(
                          reviewModel.customerName.isNotEmpty
                              ? reviewModel.customerName[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviewModel.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              reviewModel.feedback,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            reviewModel.ratings,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<void> checkProductDetailsExistance({
    required String uId,
    int initialquantity = 1,
  }) async {
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(uId)
        .collection('cartOrders')
        .doc(widget.productModel.productId.toString());

    DocumentSnapshot documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      int currentQuantity = documentSnapshot['productQuantity'];
      int updatedQuantity = currentQuantity + initialquantity;

      double totalPriceofProducts =
          double.parse(
            widget.productModel.isSale
                ? widget.productModel.salePrice
                : widget.productModel.fullPrice,
          ) *
          updatedQuantity;

      documentReference.update({
        'productQuantity': updatedQuantity,
        'productTotalPrice': totalPriceofProducts,
      });

      print('product Exists');
      //increasing cart items
      cartController.increaseCartItem();
    } else {
      await FirebaseFirestore.instance.collection('cart').doc(uId).set({
        'uId': uId,
        'createdAt': DateTime.now(),
      });

      CartModel cartModel = CartModel(
        productId: widget.productModel.productId,
        categoryId: widget.productModel.categoryId,
        productName: widget.productModel.productName,
        categoryName: widget.productModel.categoryName,
        salePrice: widget.productModel.salePrice,
        fullPrice: widget.productModel.fullPrice,
        productImages: widget.productModel.productImages,
        deliveryTime: widget.productModel.deliveryTime,
        isSale: widget.productModel.isSale,
        productDescription: widget.productModel.productDescription,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productQuantity: 1,
        productTotalPrice: double.parse(
          widget.productModel.isSale
              ? widget.productModel.salePrice
              : widget.productModel.fullPrice,
        ),
      );

      await documentReference.set(cartModel.toMap());

      print('Cart Added!!');

      //increasing cart items
      cartController.increaseCartItem();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dear User! ${cartModel.productName} is added to cart',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppConstants.AppMainColor,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  static Future<void> sendWhatAppMsgHere({
    required ProductModel productModel,
  }) async {
    final number = '923003497918';
    final message =
        'Hello BuyZaar!\nCould you please give me more details about this product?\n\n'
        '🛍 Product Name: ${productModel.productName}\n'
        '🆔 Product ID: ${productModel.productId}';

    final whatsappUrl = Uri.parse(
      "whatsapp://send?phone=$number&text=${Uri.encodeComponent(message)}",
    );
    final waMeUrl = Uri.parse(
      "https://wa.me/$number?text=${Uri.encodeComponent(message)}",
    );

    try {
      // Try WhatsApp app scheme
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      print('Failed to launch WhatsApp URI scheme: $e');
    }

    try {
      // Fallback to web URL
      await launchUrl(waMeUrl, mode: LaunchMode.externalApplication);
      return;
    } catch (e) {
      print('Failed to launch wa.me URL: $e');
    }

    throw 'Could not launch WhatsApp chat for $number';
  }
}
