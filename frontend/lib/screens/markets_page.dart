import 'package:flutter/material.dart';
import 'package:frontend/models/market_products.dart';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:frontend/services/market_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/widgets/bottom_navigation.dart';

class MarketsPage extends StatefulWidget {
  final Map<String, List<dynamic>> categorizedProducts;

  const MarketsPage({super.key, this.categorizedProducts = const {}});

  @override
  _MarketsPageState createState() => _MarketsPageState();
}

class _MarketsPageState extends State<MarketsPage> {
  List<MarketProducts> marketProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMarketProducts();
  }

  Future<void> loadMarketProducts() async {
    try {
      final fetchedMarketProducts = await fetchMarketProducts();
      setState(() {
        marketProducts = fetchedMarketProducts;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Marketler",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: marketProducts.length,
              itemBuilder: (context, index) {
                final marketData = marketProducts[index];
                return MarketSection(marketData: marketData);
              },
            ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        categorizedProducts: widget.categorizedProducts,
      ),
    );
  }
}

class MarketSection extends StatelessWidget {
  final MarketProducts marketData;

  const MarketSection({
    super.key,
    required this.marketData,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> marketImages = {
      "Carrefour": "images/carrefour.png",
      "A101": "images/a101.png",
      "Şok": "images/şok.png",
      "Migros": "images/migros.png",
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(marketImages[marketData.marketName] ??
                          'images/default.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marketData.marketName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${marketData.products.length} ürün",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: marketData.products.length > 4
                  ? 4
                  : marketData.products.length,
              itemBuilder: (context, index) {
                final product = marketData.products[index];
                return MarketProductCard(product: product);
              },
            ),
          ),
          if (marketData.products.length > 4)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to market detail page
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text(
                    "Tüm Ürünleri Gör",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MarketProductCard extends StatelessWidget {
  final CheapestProductPc product;

  const MarketProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 140,
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      product.image != null && product.image!.startsWith('http')
                          ? Image.network(
                              product.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset("images/default.png");
                              },
                            )
                          : Image.asset(
                              "images/default.png",
                              fit: BoxFit.cover,
                            ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  product.name ?? "Ürün Adı Yok",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "₺${product.price?.toStringAsFixed(2) ?? "0.00"}",
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              OutlinedButton(
                onPressed: () {
                  final cartItem = CartItem(
                    name: product.name ?? "Ürün Adı Yok",
                    price: product.price ?? 0.0,
                    image: product.image ?? "",
                  );
                  cartProvider.addItem(cartItem);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}