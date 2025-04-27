import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/models/product_search_result.dart';
import 'package:frontend/widgets/product_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<ProductSearchResult> products = [];
  String? errorMessage;

  String _decodeUtf8(String text) {
    try {
      return utf8.decode(text.runes.toList());
    } catch (e) {
      return text;
    }
  }

  void _searchProducts() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        products = [];
        isLoading = false;
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      products = [];
    });

    try {
      final Uri uri =
          Uri.parse('https://35c4-144-122-129-53.ngrok-free.app/search')
              .replace(queryParameters: {
        'query': Uri.encodeQueryComponent(query),
        'collection': 'SupermarketProducts',
        'limit': '20',
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Ensure the response is decoded as UTF-8
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        final List<ProductSearchResult> result = data.map((item) {
          // Ensure all text fields are properly decoded
          if (item is Map<String, dynamic>) {
            item['name'] = _decodeUtf8(item['name'] ?? '');
            item['market_name'] = _decodeUtf8(item['market_name'] ?? '');
            item['main_category'] = _decodeUtf8(item['main_category'] ?? '');
            item['sub_category'] = _decodeUtf8(item['sub_category'] ?? '');
            item['lowest_category'] =
                _decodeUtf8(item['lowest_category'] ?? '');
          }
          return ProductSearchResult.fromJson(item);
        }).toList();

        setState(() {
          products = result;
        });
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          errorMessage =
              'Sonuçlar alınırken bir hata oluştu: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error during search: $e');
      setState(() {
        errorMessage = 'Bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ürün Ara',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: _searchProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ürün adı veya kategori ara',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.green[400]!,
                    width: 1.0,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _searchProducts(),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                errorMessage!,
                style: TextStyle(
                    color: Colors.red[400], fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                  ))
                : products.isEmpty &&
                        !isLoading &&
                        errorMessage == null &&
                        _searchController.text.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Aramanızla eşleşen ürün bulunamadı.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: products.length,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Material(
                            color: Colors.grey[50],
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailPage(product: product),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: product.imageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                product.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                    Icons.broken_image,
                                                    size: 30,
                                                    color: Colors.grey[400],
                                                  );
                                                },
                                              ),
                                            )
                                          : Icon(
                                              Icons.image_not_supported,
                                              size: 30,
                                              color: Colors.grey[400],
                                            ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Market: ${product.marketName}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Fiyat: ₺${product.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
