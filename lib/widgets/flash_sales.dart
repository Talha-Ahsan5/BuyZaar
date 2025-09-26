import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:letsshop/models/product_models.dart';
import 'package:letsshop/user_panel/product_details_screen.dart';
import 'package:letsshop/utils/app_constants.dart';

class FlashSalesWiget extends StatelessWidget {
  const FlashSalesWiget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          FirebaseFirestore.instance
              .collection('products')
              .where('isSale', isEqualTo: true)
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
        return SizedBox(
          height: Get.height * 0.19,
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              // var categoryData = snapshot.data!.docs[index];
              // String categoryImg = categoryData['categoryImg'] ?? '';
              // if (categoryImg.isEmpty) {
              //   categoryImg = 'default_image_url'; // A fallback image
              // }

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

              // CategoriesModel categoriesModel = CategoriesModel(
              //   categoryId: categoryData['categoryId'],
              //   categoryImg: categoryImg,
              //   categoryName: categoryData['categoryName'],
              //   createdAt: categoryData['createdAt'],
              //   updatedAt: categoryData['updatedAt'],
              // );

              return Padding(
                padding: EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => ProductDetailsScreen(productModel: productModel),
                    );
                  },
                  child: FillImageCard(
                    borderRadius: 20.0,
                    width: Get.width / 4.0,
                    heightImage: Get.height / 10.0,
                    imageProvider: CachedNetworkImageProvider(
                      // categoriesModel.categoryImg,
                      productModel.productImages[0],
                    ),
                    title: Center(
                      child: Text(
                        productModel.productName ?? 'No Name',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w300,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    footer: Row(
                      children: [
                        Text(
                          'Rs ${productModel.salePrice}',
                          style: TextStyle(fontSize: 10.0),
                        ),
                        SizedBox(width: 2.0),
                        Text(
                          'Rs ${productModel.fullPrice}',
                          style: TextStyle(
                            fontSize: 10.0,
                            decoration: TextDecoration.lineThrough,
                            color: AppConstants.AppMainColor,
                          ),
                        ),
                      ],
                    ),
                    // description: Text(''),
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
