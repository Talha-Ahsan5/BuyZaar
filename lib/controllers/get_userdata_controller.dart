import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetUserdataController extends GetxController {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Object?>>> userData(String Uid) async {
    final QuerySnapshot userData =
        await _firebaseFirestore
            .collection('users')
            .where('uId', isEqualTo: Uid)
            .get();

    return userData.docs;
  }
}
