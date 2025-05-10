import 'package:flutter/material.dart';
import '../../../Cards/card_contents.dart';

class CartProvider extends ChangeNotifier {
  final List<CardContents> _cartItems = [];

  List<CardContents> get cartItems => _cartItems;

  void addToCart(CardContents course) {
    if (!_cartItems.contains(course)) {
      _cartItems.add(course);
      notifyListeners();
    }
  }

  void removeFromCart(CardContents course) {
    _cartItems.remove(course);
    notifyListeners();
  }
}
