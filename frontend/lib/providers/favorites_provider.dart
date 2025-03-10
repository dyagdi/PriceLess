import 'package:flutter/foundation.dart';
import 'package:frontend/models/cheapest_pc.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<CheapestProductPc> _items = [];

  List<CheapestProductPc> get items => List.unmodifiable(_items);

  bool isFavorite(String? productId) {
    if (productId == null) return false;
    return _items.any((item) => item.id == productId);
  }

  void toggleFavorite(CheapestProductPc product) {
    if (product.id == null) return;

    final isAlreadyFavorite = _items.any((item) => item.id == product.id);

    if (isAlreadyFavorite) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }

    notifyListeners();
  }

  void addToFavorites(CheapestProductPc product) {
    if (product.id == null) return;

    if (!isFavorite(product.id)) {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
