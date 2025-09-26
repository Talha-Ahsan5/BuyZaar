import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:letsshop/models/categories_models.dart';
import 'package:letsshop/user_panel/single_category_product_screen.dart';
import 'package:letsshop/utils/app_constants.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Categories', style: TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.AppMainColor,
      ),
      body: FutureBuilder(
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
          return GridView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1.19,
            ),
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
                onTap: () {
                  // print('Index: $index');
                  Get.to(() => SingleCategoryProductScreen(categoryId: categoriesModel.categoryId));
                },
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: FillImageCard(
                    borderRadius: 20.0,
                    width: Get.width / 1,
                    heightImage: Get.height / 8.0,
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
          );

          // return SizedBox(
          //   height: Get.height * 0.18,
          //   child: ListView.builder(
          //     itemCount: snapshot.data!.docs.length,
          //     shrinkWrap: true,
          //     scrollDirection: Axis.horizontal,

          //   ),
          // );
        },
      ),
    );
  }
}
