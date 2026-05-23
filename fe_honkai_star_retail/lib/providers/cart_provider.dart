import 'package:fe_honkai_star_retail/models/cart_model.dart';
import 'package:fe_honkai_star_retail/models/resource_model.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<CartModel> _items = [];

  List<CartModel> get items => _items;

  void addToCart(ResourceModel resource, int quantity) {
    final index = _items.indexWhere((item) => item.resource.id == resource.id);

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartModel(resource: resource, quantity: quantity));
    }

    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int get totalPrice {
    int total = 0;
    for (var item in _items) {
      total += item.resource.price * item.quantity;
    }

    return total;
  }
}
