import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/product_search_result.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductSearchResult product;

  ProductDetailPage({required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  List<ProductSearchResult> similarProducts = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSimilarProducts();
  }

  Future<void> _fetchSimilarProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Searching for similar products to: ${widget.product.name}');

      final Uri uri =
          Uri.parse(ApiConfig.searchEndpoint).replace(queryParameters: {
        'query': widget.product.name,
        'collection': 'SupermarketProducts',
      });

      print('Fetching similar products from: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);

        print('Number of products returned: ${data.length}');

        if (data.isEmpty) {
          setState(() {
            similarProducts = [];
          });
          return;
        }

        try {
          final List<ProductSearchResult> results = data
              .map((item) {
                print('Processing item: $item');
                return ProductSearchResult.fromJson(item);
              })
              .where((product) =>
                  product.productLink != widget.product.productLink &&
                  product.marketName != widget.product.marketName)
              .take(3)
              .toList();

          print('Number of filtered products: ${results.length}');

          setState(() {
            similarProducts = results;
          });
        } catch (e) {
          print('Error parsing product results: $e');
          setState(() {
            errorMessage = 'Ürün verileri işlenirken bir hata oluştu';
          });
        }
      } else {
        print('Error response: ${response.body}');
        setState(() {
          errorMessage =
              'Benzer ürünler yüklenirken bir hata oluştu (${response.statusCode})';
        });
      }
    } catch (e, stackTrace) {
      print('Exception while fetching similar products: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        errorMessage = 'Bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildComparisonSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                'Diğer Marketler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              if (!isLoading && similarProducts.isNotEmpty)
                Text(
                  '${similarProducts.length} ürün bulundu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
              ),
            )
          else if (errorMessage != null)
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[400]),
            )
          else if (similarProducts.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Benzer ürün bulunamadı',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: similarProducts
                  .map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
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
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.broken_image,
                                              size: 24,
                                              color: Colors.grey[400],
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.image_not_supported,
                                          size: 24,
                                          color: Colors.grey[400],
                                        ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              product.marketName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '₺${product.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (product.highPrice != null)
                                                Text(
                                                  '₺${product.highPrice!.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
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
          'Ürün Detayı',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: widget.product.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Market',
                          widget.product.marketName,
                          Icons.store,
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Fiyat',
                          '₺${widget.product.price.toStringAsFixed(2)}',
                          Icons.payment,
                          valueColor: Colors.green[700],
                        ),
                        if (widget.product.highPrice != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            'Yüksek Fiyat',
                            '₺${widget.product.highPrice!.toStringAsFixed(2)}',
                            Icons.trending_up,
                            valueColor: Colors.orange[700],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori Bilgileri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Ana Kategori',
                          widget.product.mainCategory,
                          Icons.category,
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Alt Kategori',
                          widget.product.subCategory,
                          Icons.subdirectory_arrow_right,
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Alt Kategori',
                          widget.product.lowestCategory,
                          Icons.label,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildComparisonSection(),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _launchURL(widget.product.productLink),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart),
                        SizedBox(width: 8),
                        Text(
                          'Ürünü İncele',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
