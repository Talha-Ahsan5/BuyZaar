import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/cart_controllers.dart';
import 'package:letsshop/screens/splash_screen.dart';
import 'package:letsshop/admin_panel/admin_screen.dart';
import 'package:letsshop/controllers/get_userdata_controller.dart';
import 'package:letsshop/firebase_options.dart';
import 'package:letsshop/screens/login_screen.dart';
import 'package:letsshop/user_panel/main_screen.dart';
import 'package:letsshop/services/notification_services.dart'; // import your service
import 'package:shared_preferences/shared_preferences.dart';

// Background or Terminated state handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // You could also handle message data here if you want
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(CartController());

  // Init notifications service
  final notificationServices = NotificationServices();
  await notificationServices.requestNotificationPermission();
  await notificationServices.initializeLocalNotifications(); 
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Get SharedPreferences instance
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? uId = prefs.getString('uId');

  Widget startScreen = const LoginScreen();

  if (isLoggedIn && uId != null) {
    final GetUserdataController userDataCtrl = Get.put(GetUserdataController());
    var data = await userDataCtrl.userData(uId);

    if (data.isNotEmpty) {
      bool isAdmin = data[0]['isAdmin'] ?? false;
      startScreen = isAdmin ? const AdminScreen() : const MainScreen();
    }
  }

  runApp(MainApp(startScreen: startScreen));

  // ⚡ Very important: check if the app was opened from a terminated state by a notification
  notificationServices.setUpInteractMessage(navigatorKey.currentContext!);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  final Widget startScreen;
  const MainApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey, // add navigatorKey so we always have context
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
