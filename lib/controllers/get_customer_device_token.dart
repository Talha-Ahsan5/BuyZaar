import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> getUserDeviceToken() async {
  String? token = await FirebaseMessaging.instance.getToken();

  try {
    if (token != null) {
      return token;
    } else {
      throw Exception('Error');
    }
  } catch (e) {
    print('Error');
    throw Exception('Error: $e');
  }
}
