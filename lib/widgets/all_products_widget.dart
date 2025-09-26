import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:letsshop/models/product_models.dart';
import 'package:letsshop/user_panel/product_details_screen.dart';

class AllProductsWidget extends StatelessWidget {
  const AllProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          FirebaseFirestore.instance
              .collection('products')
              .where('isSale', isEqualTo: false)
              .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error found: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Text('Products not found!');   
        }
        return GridView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index];
              ProductModel productModel = ProductModel(
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
              );
              // var categoryData = snapshot.data!.docs[index];
              // String productImg = productData['productImg'] ?? '';
              // if (productImg.isEmpty) {
              //   productImg = 'default_image_url'; // A fallback image
              // }

              // CategoriesModel categoriesModel = CategoriesModel(
              //   categoryId: categoryData['categoryId'],
              //   categoryImg: categoryImg,
              //   categoryName: categoryData['categoryName'],
              //   createdAt: categoryData['createdAt'],
              //   updatedAt: categoryData['updatedAt'],
              // );

              return GestureDetector(
                onTap: () {
                  // print('Index: $index');
                Get.to(() => ProductDetailsScreen(productModel: productModel));
                },
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: FillImageCard(
                    borderRadius: 20.0,
                    width: Get.width / 1,
                    heightImage: Get.height / 8.0,
                    imageProvider: CachedNetworkImageProvider(
                      productModel.productImages[0],
                    ),
                    title: Center(
                      child: Text(
                        productModel.productName ?? 'No Name',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    // description: Text(''),
                    footer: Center(
                      child: Text(
                        'PKR${productModel.fullPrice}',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
      },
    );
  }
}
