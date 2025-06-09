import 'package:flutter/material.dart';
import 'package:frontend/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  set isNavigating(bool value) {
    _isNavigating = value;
    notifyListeners();
  }

  void addItem(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.name == item.name,
    );

    if (existingItemIndex != -1) {
      // If item already exists, increase its quantity
      _cartItems[existingItemIndex].quantity += 1;
    } else {
      // Add the item to the cart with default quantity = 1
      _cartItems.add(CartItem(
        name: item.name,
        price: item.price,
        image: item.image,
        quantity: 1, // Ensure default quantity is set to 1
      ));
    }

    notifyListeners();
  }

  void removeItem(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.name == item.name,
    );

    if (existingItemIndex != -1) {
      // If item exists, decrease quantity or remove it completely
      if (_cartItems[existingItemIndex].quantity > 1) {
        _cartItems[existingItemIndex].quantity -= 1;
      } else {
        _cartItems.removeAt(existingItemIndex);
      }

      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
