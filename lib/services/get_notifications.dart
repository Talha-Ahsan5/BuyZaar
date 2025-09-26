import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:letsshop/services/get_server_key.dart';

class GetNotifications {
  static Future<void> getNotificationFromApi({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {
    try {
      String serverKey = await GetServerKey().GetServiceKeyToken();

      String url = 'https://fcm.googleapis.com/v1/projects/let-s-shop-47c2a/messages:send';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      Map<String, dynamic> message = {
        "message": {
          if (token != null) "token": token,
          "notification": {"body": body, "title": title},
          if (data != null) "data": data,
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Notification Sent Successfully!');
      } else {
        print('❌ Failed with ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error sending notification: $e');
    }
  }
}
