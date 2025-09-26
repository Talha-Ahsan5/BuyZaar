import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:letsshop/models/categories_models.dart';
import 'package:letsshop/user_panel/single_category_product_screen.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('categories').get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error found: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Text('Categories not found!');
        }
        return SizedBox(
          height: Get.height * 0.18,
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var categoryData = snapshot.data!.docs[index];
              String categoryImg = categoryData['categoryImg'] ?? '';
              if (categoryImg.isEmpty) {
                categoryImg = 'default_image_url'; // A fallback image
              }

              CategoriesModel categoriesModel = CategoriesModel(
                categoryId: categoryData['categoryId'],
                categoryImg: categoryImg,
                categoryName: categoryData['categoryName'],
                createdAt: categoryData['createdAt'],
                updatedAt: categoryData['updatedAt'],
              );

              return GestureDetector(
                onTap:
                    () => Get.to(
                      () => SingleCategoryProductScreen(
                        categoryId: categoriesModel.categoryId,
                      ),
                    ),
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: FillImageCard(
                    borderRadius: 20.0,
                    width: Get.width / 4.0,
                    heightImage: Get.height / 10.0,
                    imageProvider: CachedNetworkImageProvider(
                      categoriesModel.categoryImg,
                    ),
                    title: Center(
                      child: Text(
                        categoriesModel.categoryName ?? 'No Name',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
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
