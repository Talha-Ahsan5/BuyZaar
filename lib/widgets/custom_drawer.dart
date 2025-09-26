import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letsshop/screens/login_screen.dart';
import 'package:letsshop/user_panel/all_orders_screen.dart';
import 'package:letsshop/utils/app_constants.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: Wrap(
        children: [
          // 🔵 Colored header section
          Container(
            color: AppConstants.AppMainColor,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 30.0,
                  ),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: Text(
                      "Buyzaar",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Version 1.0.1',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.shopping_bag),
                    ),
                  ),
                ),
                // Divider(
                //   color: Colors.white,
                //   indent: 10.0,
                //   endIndent: 10.0,
                //   thickness: 1.5,
                // ),
              ],
            ),
          ),

          // ⚪ Uncolored section with tappable items
          _drawerItem(
            context,
            title: 'Home',
            icon: Icons.home,
            onTap: () {
              Navigator.pop(context);
              // Navigate to home
            },
          ),
          _drawerItem(
            context,
            title: 'Products',
            icon: Icons.production_quantity_limits_outlined,
            onTap: () {
              Navigator.pop(context);
              // Navigate to products
            },
          ),
          _drawerItem(
            context,
            title: 'Orders',
            icon: Icons.receipt_long,
            onTap: () {
              Navigator.pop(context);
              // Navigate to orders
              Get.back();
              Get.to(() => AllOrdersScreen());
            },
          ),
          _drawerItem(
            context,
            title: 'Contact Us',
            icon: Icons.contact_mail,
            onTap: () {
              Navigator.pop(context);
              // Navigate to contact page
            },
          ),
          _drawerItem(
            context,
            title: 'Logout',
            icon: Icons.logout,
            onTap: () {
              GoogleSignIn googleSignIn = GoogleSignIn();
              FirebaseAuth auth = FirebaseAuth.instance;

              auth.signOut();
              googleSignIn.signOut();
              Get.offAll(() => LoginScreen());
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        title: Text(title),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon),
        ),
        onTap: onTap,
      ),
    );
  }
}
