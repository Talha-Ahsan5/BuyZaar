import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BannersController extends GetxController {
  RxList<String> bannersURL = RxList<String>([]);

  @override
  void onInit() {
    super.onInit();
    fetchBannersUrl();
  }

  Future<void> fetchBannersUrl() async {
    try {
      QuerySnapshot bannersSnapshot =
          await FirebaseFirestore.instance.collection('banners').get();

      if (bannersSnapshot.docs.isNotEmpty) {
        bannersURL.value =
            bannersSnapshot.docs
                .map((doc) => doc['BannersURL'] as String)
                .toList();
      }
    } catch (e) {
      print(e);
    }
  }
}
