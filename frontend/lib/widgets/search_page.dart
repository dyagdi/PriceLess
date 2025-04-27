import 'package:flutter/material.dart';
import 'package:frontend/models/product_search_result.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/widgets/product_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<ProductSearchResult> products = [];

  void _searchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<ProductSearchResult> result =
          await searchProducts(_searchController.text);
      setState(() {
        products = result;
      });
    } catch (e) {
      // Handle error
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arama Sonuçları'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ürün, marka veya kategori ara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle:
                            Text('${product.price} - ${product.marketName}'),
                        leading: Image.network(product.imageUrl),
                        onTap: () {
                          // Navigate to the product detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
