import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CalculatingRatingsController extends GetxController {
  final String productId;
  RxDouble averageRating = 0.0.obs;

  CalculatingRatingsController(this.productId);

  @override
  void onInit() {
    // TODO: implement onInit
    calculatingRatings();
    super.onInit();
  }

  void calculatingRatings() {
    FirebaseFirestore.instance
        .collection('reviews')
        .doc(productId)
        .collection('CustomerReviews')
        .snapshots()
        .listen((snapshot) {
          if(snapshot.docs.isNotEmpty){
            double totalRatings = 0;
            int numberOfReviews = 0;
            for (var docs in snapshot.docs) {
              final ratingsAsString = docs['ratings'] as String;
              //convert String Rating to double
              final rating = double.tryParse(ratingsAsString);
              if(rating != null){
                totalRatings += rating;
                numberOfReviews++;

              }
            }
            if(numberOfReviews != 0){
              averageRating.value = totalRatings / numberOfReviews;
            } else{
              averageRating.value = 0.0;

            }
          } else {
            averageRating.value = 0.0;
          }
        });
  }
}
