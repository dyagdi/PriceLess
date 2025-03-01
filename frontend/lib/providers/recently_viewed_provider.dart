import 'package:flutter/foundation.dart';
import 'package:frontend/models/cheapest_pc.dart';

class RecentlyViewedProvider extends ChangeNotifier {
  final List<CheapestProductPc> _items = [];
  static const int _maxItems = 10;

  List<CheapestProductPc> get items => List.unmodifiable(_items);

  void addItem(CheapestProductPc product) {
    if (product.id == null) return;

    // Remove if already exists
    _items.removeWhere((item) => item.id == product.id);

    // Add to beginning
    _items.insert(0, product);

    // Keep only last 10 items
    if (_items.length > _maxItems) {
      _items.removeLast();
    }

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
