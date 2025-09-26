import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letsshop/controllers/cart_controllers.dart';
import 'package:letsshop/controllers/notification_controller.dart';
import 'package:letsshop/screens/all_products_screen.dart';
import 'package:letsshop/services/fcm_service.dart';
import 'package:letsshop/services/get_notifications.dart';
import 'package:letsshop/services/get_server_key.dart';
import 'package:letsshop/services/notification_services.dart';
import 'package:letsshop/user_panel/all_categories_screen.dart';
import 'package:letsshop/user_panel/all_flash_Sales_products_screen.dart';
import 'package:letsshop/user_panel/cart_screen.dart';
import 'package:letsshop/user_panel/notification_screen.dart';
import 'package:letsshop/utils/app_constants.dart';
import 'package:letsshop/widgets/all_products_widget.dart';
import 'package:letsshop/widgets/banner_widget.dart';
import 'package:letsshop/widgets/categories_widget.dart';
import 'package:letsshop/widgets/custom_drawer.dart';
import 'package:letsshop/widgets/flash_sales.dart';
import 'package:letsshop/widgets/heading_widgets.dart';
import 'package:badges/badges.dart' as badges;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NotificationServices notificationServices = NotificationServices();
  final NotificationController notificationController = Get.put(
    NotificationController(),
  );

  @override
  void initState() {
    super.initState();

    // Foreground notifications
    notificationServices.firebaseInit();

    // Optional: FCM direct init if you use custom service
    FcmService.firebaseInit();

    // Debug/testing only: send test notification
    _getServerKeyToken();
    // _getNotificationService();
  }

  // print server key
  void _getServerKeyToken() async {
    final token = await GetServerKey().GetServiceKeyToken();
    print('Server Key Token: $token');
  }

  // //send a test notification
  // void _getNotificationService() async {
  //   await GetNotifications.getNotificationFromApi(
  //     token:
  //         'ffuWolJaR_KUY5HHkqeSCN:APA91bHeP9Uv1tBJmeBSVBreWbaVLX_M8f83sVDSSO56pBaSOzgCko3fgZ-CCsbgfSmj322va4oRX5RKQ6JnRgu6XJlAz1rbR86B5RBuXiCnHzvci9U8uHw',
  //     title: 'Notification Title',
  //     body: 'Notification Body',
  //     data: {'screen': 'NotificationScreen'},
  // //   );
  // }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppConstants.AppMainColor,
        title: Text(
          AppConstants.AppName,
          style: TextStyle(color: AppConstants.appTextColor),
        ),
        centerTitle: true,
        actions: [
          // Notification Icon
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),

              child: badges.Badge(
                badgeContent: Text('${notificationController.notificationCount.value}', style: TextStyle(color: Colors.white),),
                position: badges.BadgePosition.topEnd(top: 1, end: 1),
                showBadge: notificationController.notificationCount.value > 0,
                child: IconButton(
                  onPressed: () {
                    Get.to(() => NotificationScreen());
                  },
                  icon: Icon(Icons.notifications),
                ),
              ),
            ),
          ),
          // Cart Icon
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 8, top: 8),
              child: GestureDetector(
                onTap: () => Get.to(() => const CartScreen()),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      size: 28,
                      color: Colors.white,
                    ),
                    if (cartController.cartItemCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '${cartController.cartItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const BannerWidget(),
            HeadingWidgets(
              titleHeading: 'Categories',
              subHeadingTitle: 'According to your budget',
              textBtn: 'See more >',
              onTap: () => Get.to(() => const AllCategoriesScreen()),
            ),
            const CategoriesWidget(),
            HeadingWidgets(
              titleHeading: 'Flash Sales',
              subHeadingTitle: 'According to your budget',
              textBtn: 'See more >',
              onTap: () => Get.to(() => const AllFlashSalesProductsScreen()),
            ),
            const FlashSalesWiget(),
            HeadingWidgets(
              titleHeading: 'All Products',
              subHeadingTitle: 'According to your budget',
              textBtn: 'See more >',
              onTap: () => Get.to(() => const AllProductsScreen()),
            ),
            const AllProductsWidget(),
          ],
        ),
      ),
    );
  }
}
