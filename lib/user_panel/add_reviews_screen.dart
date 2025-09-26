import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:letsshop/models/order_model.dart';
import 'package:letsshop/models/reviews_model.dart';
import 'package:letsshop/utils/app_constants.dart';

class AddReviewsScreen extends StatefulWidget {
  final OrderModel orderModel;
  const AddReviewsScreen({super.key, required this.orderModel});

  @override
  State<AddReviewsScreen> createState() => _AddReviewsScreenState();
}

class _AddReviewsScreenState extends State<AddReviewsScreen> {
  TextEditingController feedbackController = TextEditingController();
  double productRatings = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews & Feedback',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstants.AppMainColor,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
            Text(
              'Give your desired ratings :") ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder:
                  (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                productRatings = rating;
                setState(() {
                  print(productRatings);
                });
              },
            ),
            SizedBox(height: 90),
            Text('FeedBack', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            TextFormField(
              controller: feedbackController,
              decoration: InputDecoration(
                label: Text('Give the FeedBack here'),
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.AppMainColor,
              ),
              onPressed: () async {
                EasyLoading.show(status: 'Please Wait...');
                String feedback = feedbackController.text.trim();
                User? user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  EasyLoading.dismiss();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You must be logged in to submit feedback!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                ReviewModel reviewmodel = ReviewModel(
                  customerName: widget.orderModel.customerName,
                  customerPhone: widget.orderModel.customerPhone,
                  customerDeviceToken: widget.orderModel.customerDeviceToken,
                  customerId:
                      user.uid, // Use user.uid for customerId (not categoryId)
                  feedback: feedback,
                  ratings: productRatings.toString(),
                  createdAt: DateTime.now(),
                );

                await FirebaseFirestore.instance
                    .collection('reviews')
                    .doc(widget.orderModel.categoryId)
                    .collection('CustomerReviews')
                    .add(reviewmodel.toMap());

                EasyLoading.dismiss();

                feedbackController.clear();
                FocusScope.of(context).unfocus();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Feedback submitted!'),
                    backgroundColor: AppConstants.AppMainColor,
                  ),
                );
              },
              child: Text(
                'Submit Feedback',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
