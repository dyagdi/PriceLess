class ProductComparison {
  final String canonicalName;
  final List<MarketPrice> marketPrices;
  final double minPrice;
  final double maxPrice;
  final double priceDiffPercent;
  final String cheapestMarket;
  final String mostExpensiveMarket;

  ProductComparison({
    required this.canonicalName,
    required this.marketPrices,
    required this.minPrice,
    required this.maxPrice,
    required this.priceDiffPercent,
    required this.cheapestMarket,
    required this.mostExpensiveMarket,
  });

  factory ProductComparison.fromJson(Map<String, dynamic> json) {
    List<MarketPrice> prices = [];
    if (json['market_prices'] != null) {
      // Parse the market_prices string which is in format "market1: price1, market2: price2"
      String marketPricesStr = json['market_prices'];
      List<String> marketPricesList = marketPricesStr.split(', ');

      for (var marketPrice in marketPricesList) {
        List<String> parts = marketPrice.split(': ');
        if (parts.length == 2) {
          String market = parts[0];
          double price = double.tryParse(parts[1]) ?? 0.0;
          prices.add(MarketPrice(market: market, price: price));
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
    );
  }
}

class MarketPrice {
  final String market;
  final double price;
  final String? productLink;
  final String? image;

  MarketPrice({
    required this.market,
    required this.price,
    this.productLink,
    this.image,
  });
}
