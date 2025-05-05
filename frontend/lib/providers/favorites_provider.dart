import 'package:flutter/foundation.dart';
import 'package:frontend/models/cheapest_pc.dart';

class FavoritesProvider with ChangeNotifier {
  final List<CheapestProductPc> _items = [];

  List<CheapestProductPc> get items => _items;

  bool isFavorite(String? productName) {
    if (productName == null) return false;
    return _items.any((item) => item.name == productName);
  }

  void toggleFavorite(CheapestProductPc product) {
    print('Toggling favorite for product: ${product.name}');

    if (product.name.isEmpty) {
      print('Product name is empty, cannot toggle favorite');
      return;
    }

    final isAlreadyFavorite = _items.any((item) => item.name == product.name);
    print('Is already favorite: $isAlreadyFavorite');

    if (isAlreadyFavorite) {
      _items.removeWhere((item) => item.name == product.name);
      print('Removed from favorites');
    } else {
      _items.add(product);
      print('Added to favorites');
    }

    print('Current favorites count: ${_items.length}');
    notifyListeners();
  }

  void addToFavorites(CheapestProductPc product) {
    if (product.name.isEmpty) return;

    if (!isFavorite(product.name)) {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(String productName) {
    _items.removeWhere((item) => item.name == productName);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
