// lib/controllers/cart_controller.dart
import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItemCount = 0.obs;

  void increaseCartItem() {
    cartItemCount++;
  }

  void decreaseCartItem() {
    if (cartItemCount > 0) cartItemCount--;
  }

  void resetCart() {
    cartItemCount.value = 0;
  }
}
