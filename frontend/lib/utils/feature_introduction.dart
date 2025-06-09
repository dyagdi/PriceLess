import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class FeatureIntroduction {
  static final GlobalKey _searchKey = GlobalKey();
  static final GlobalKey _locationKey = GlobalKey();
  static final GlobalKey _cartKey = GlobalKey();
  static final GlobalKey _favoritesKey = GlobalKey();
  static final GlobalKey _discountsKey = GlobalKey();
  static final GlobalKey _chatbotKey = GlobalKey();

  static List<GlobalKey> get keys => [
        _searchKey,
        _locationKey,
        _cartKey,
        _favoritesKey,
        _discountsKey,
        _chatbotKey,
      ];

  static void startShowcase(BuildContext context) {
    // Add a small delay to ensure all widgets are built
    Future.delayed(const Duration(milliseconds: 500), () {
      ShowCaseWidget.of(context).startShowCase(keys);
    });
  }

  static Widget wrapWithShowcase({
    required Widget child,
    required String title,
    required String description,
    required GlobalKey key,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      child: child,
      overlayColor: Colors.black54,
      overlayOpacity: 0.75,
      tooltipBackgroundColor: Colors.white,
      textColor: Colors.black,
      tooltipPadding: const EdgeInsets.all(16),
      tooltipBorderRadius: BorderRadius.circular(8),
      tooltipPosition: TooltipPosition.bottom,
      disableMovingAnimation: true,
      disableScaleAnimation: true,
    );
  }

  // Keys getters
  static GlobalKey get searchKey => _searchKey;
  static GlobalKey get locationKey => _locationKey;
  static GlobalKey get cartKey => _cartKey;
  static GlobalKey get favoritesKey => _favoritesKey;
  static GlobalKey get discountsKey => _discountsKey;
  static GlobalKey get chatbotKey => _chatbotKey;
} 