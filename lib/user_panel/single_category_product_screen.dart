import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsshop/models/product_models.dart';
import 'package:letsshop/user_panel/product_details_screen.dart';
import 'package:letsshop/utils/app_constants.dart';

class SingleCategoryProductScreen extends StatefulWidget {
  final String categoryId;

  const SingleCategoryProductScreen({super.key, required this.categoryId});

  @override
  State<SingleCategoryProductScreen> createState() =>
      _SingleCategoryProductScreen();
}

class _SingleCategoryProductScreen extends State<SingleCategoryProductScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .where('categoryId', isEqualTo: widget.categoryId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: AppConstants.AppMainColor,
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('No Products'),
              backgroundColor: AppConstants.AppMainColor,
            ),
            body: const Center(
              child: Text('No products found in this category.'),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final categoryName = docs.first['categoryName'] ?? 'Category Products';

        // ⬇️ Build a flat list of all images with their associated product model
        final List<Map<String, dynamic>> imageProductPairs = [];

        for (var doc in docs) {
          final productModel = ProductModel(
            productId: doc['productId'],
            categoryId: doc['categoryId'],
            productName: doc['productName'],
            categoryName: doc['categoryName'],
            salePrice: doc['salePrice'],
            fullPrice: doc['fullPrice'],
            productImages: List<String>.from(doc['productImages']),
            deliveryTime: doc['deliveryTime'],
            isSale: doc['isSale'],
            productDescription: doc['productDescription'],
            createdAt: doc['createdAt'],
            updatedAt: doc['updatedAt'],
          );

          for (var imageUrl in productModel.productImages) {
            imageProductPairs.add({
              'imageUrl': imageUrl,
              'product': productModel,
            });
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              categoryName,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppConstants.AppMainColor,
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: imageProductPairs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final imageUrl = imageProductPairs[index]['imageUrl'] as String;
              final productModel =
                  imageProductPairs[index]['product'] as ProductModel;

              return GestureDetector(
                onTap: () {
                  Get.to(() => ProductDetailsScreen(productModel: productModel));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CupertinoActivityIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, color: Colors.red),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
