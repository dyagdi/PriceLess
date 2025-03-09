class ProductComparison {
  final String canonicalName;
  final List<MarketPrice> marketPrices;
  final double minPrice;
  final double maxPrice;
  final double priceDiffPercent;
  final String cheapestMarket;
  final String mostExpensiveMarket;
  final int numMarkets;

  ProductComparison({
    required this.canonicalName,
    required this.marketPrices,
    required this.minPrice,
    required this.maxPrice,
    required this.priceDiffPercent,
    required this.cheapestMarket,
    required this.mostExpensiveMarket,
    this.numMarkets = 0,
  });

  factory ProductComparison.fromJson(Map<String, dynamic> json) {
    List<MarketPrice> prices = [];

    // Handle detailed_market_prices if available (from search endpoint)
    if (json['detailed_market_prices'] != null) {
      List<dynamic> detailedPrices = json['detailed_market_prices'];
      for (var marketData in detailedPrices) {
        prices.add(MarketPrice(
          market: marketData['market'],
          price: marketData['price']?.toDouble() ?? 0.0,
          productLink: marketData['product_link'],
          productName: marketData['product_name'],
        ));
      }
    }
    // Handle market_prices string if available (from comparison endpoint)
    else if (json['market_prices'] != null) {
      // Parse the market_prices string which is in format "market1: price1, market2: price2"
      String marketPricesStr = json['market_prices'];
      List<String> marketPricesList = marketPricesStr.split(', ');

      for (var marketPrice in marketPricesList) {
        List<String> parts = marketPrice.split(': ');
        if (parts.length == 2) {
          String market = parts[0];
          double price = double.tryParse(parts[1]) ?? 0.0;

          // Create a product link based on the market
          String? productLink;
          switch (market.toLowerCase()) {
            case 'migros':
              productLink =
                  'https://www.migros.com.tr/search?q=${json['canonical_name']}';
              break;
            case 'carrefour':
              productLink =
                  'https://www.carrefoursa.com/search/?text=${json['canonical_name']}';
              break;
            case 'a101':
              productLink =
                  'https://www.a101.com.tr/list/?search_text=${json['canonical_name']}';
              break;
            case 'sok':
            case 'şok':
              productLink =
                  'https://www.sokmarket.com.tr/search?q=${json['canonical_name']}';
              break;
            case 'bim':
              productLink =
                  'https://www.bim.com.tr/Categories/100/aktuel-urunler.aspx';
              break;
            default:
              productLink = null;
          }

          prices.add(MarketPrice(
            market: market,
            price: price,
            productLink: productLink,
          ));
        }
      }
    }

    return ProductComparison(
      canonicalName: json['canonical_name'] ?? '',
      marketPrices: prices,
      minPrice: json['min_price']?.toDouble() ?? 0.0,
      maxPrice: json['max_price']?.toDouble() ?? 0.0,
      priceDiffPercent: json['price_diff_percent']?.toDouble() ?? 0.0,
      cheapestMarket: json['cheapest_market'] ?? '',
      mostExpensiveMarket: json['most_expensive_market'] ?? '',
      numMarkets: json['num_markets'] ?? prices.length,
    );
  }
}

class MarketPrice {
  final String market;
  final double price;
  final String? productLink;
  final String? image;
  final String? productName;

  MarketPrice({
    required this.market,
    required this.price,
    this.productLink,
    this.image,
    this.productName,
  });
}
