import 'package:flutter/foundation.dart';
import 'package:frontend/models/cheapest_pc.dart';

class RecentlyViewedProvider with ChangeNotifier {
  final List<CheapestProductPc> _items = [];
  static const int _maxItems = 10;

  List<CheapestProductPc> get items => List.unmodifiable(_items);

  void addItem(CheapestProductPc product) {
    print('Adding to recently viewed: ${product.name}');
    print('Current items before add: ${_items.length}');

    // Check if the product already exists
    final existingIndex = _items.indexWhere((item) => item.id == product.id);

    if (existingIndex != -1) {
      // If product exists, remove it from its current position
      _items.removeAt(existingIndex);
    }

    // Add the product to the beginning of the list (most recent)
    _items.insert(0, product);

    // If we exceed the maximum number of items, remove the oldest one
    if (_items.length > _maxItems) {
      _items.removeLast();
    }

    print('Current items after add: ${_items.length}');
    print('Items in list: ${_items.map((item) => item.name).join(', ')}');
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
