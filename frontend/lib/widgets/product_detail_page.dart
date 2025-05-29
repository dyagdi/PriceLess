import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/product_search_result.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/providers/price_history_provider.dart';

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
  late Future<List<Map<String, dynamic>>> _priceHistoryFuture;

  @override
  void initState() {
    super.initState();
    _fetchSimilarProducts();
    _priceHistoryFuture = context
        .read<PriceHistoryProvider>()
        .fetchPriceHistory(widget.product.name);
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
        'collection': 'SupermarketProducts3',
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
            Builder(
              builder: (context) {
                final allPrices = [
                  widget.product.price,
                  ...similarProducts.map((p) => p.price)
                ];
                final minPrice = allPrices.isNotEmpty
                    ? allPrices.reduce((a, b) => a < b ? a : b)
                    : null;
                final maxPrice = allPrices.isNotEmpty
                    ? allPrices.reduce((a, b) => a > b ? a : b)
                    : null;
                return Column(
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
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '₺${product.price.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.green[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      if (product.price ==
                                                          minPrice) ...[
                                                        SizedBox(width: 6),
                                                        Icon(Icons.star,
                                                            color: Colors.green,
                                                            size: 18),
                                                        SizedBox(width: 2),
                                                        Text('En Ucuz',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12)),
                                                      ],
                                                      if (product.price ==
                                                          maxPrice) ...[
                                                        SizedBox(width: 6),
                                                        Icon(Icons.trending_up,
                                                            color: Colors.red,
                                                            size: 18),
                                                        SizedBox(width: 2),
                                                        Text('En Pahalı',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12)),
                                                      ],
                                                    ],
                                                  ),
                                                  if (product.highPrice != null)
                                                    Text(
                                                      '₺${product.highPrice!.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[500],
                                                        decoration:
                                                            TextDecoration
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
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPrices = [
      widget.product.price,
      ...similarProducts.map((p) => p.price)
    ];
    final minPrice =
        allPrices.isNotEmpty ? allPrices.reduce((a, b) => a < b ? a : b) : null;
    final maxPrice =
        allPrices.isNotEmpty ? allPrices.reduce((a, b) => a > b ? a : b) : null;

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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                              null,
                              Icons.payment,
                              valueColor: Colors.green[700],
                              price: widget.product.price,
                              minPrice: minPrice,
                              maxPrice: maxPrice,
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
                      _buildComparisonSection(),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _priceHistoryFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'Fiyat geçmişi yükleniyor...',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            print('Price history error: ${snapshot.error}');
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red[300], size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Fiyat geçmişi yüklenirken bir hata oluştu',
                                    style: TextStyle(color: Colors.red[400]),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _priceHistoryFuture = context
                                            .read<PriceHistoryProvider>()
                                            .fetchPriceHistory(
                                                widget.product.name);
                                      });
                                    },
                                    child: Text('Tekrar Dene'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history,
                                      color: Colors.grey[400], size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Bu ürün için fiyat geçmişi bulunmamaktadır',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          final history = snapshot.data!;
                          final spots = <FlSpot>[];
                          double? maxPrice;
                          double? minPrice;

                          try {
                            for (int i = 0; i < history.length; i++) {
                              final price =
                                  (history[i]['price'] as num?)?.toDouble() ??
                                      0.0;
                              spots.add(FlSpot(i.toDouble(), price));
                              if (maxPrice == null || price > maxPrice)
                                maxPrice = price;
                              if (minPrice == null || price < minPrice)
                                minPrice = price;
                            }

                            // Add some padding to the min and max values
                            if (minPrice != null && maxPrice != null) {
                              final padding = (maxPrice - minPrice) * 0.1;
                              minPrice = minPrice - padding;
                              maxPrice = maxPrice + padding;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fiyat Geçmişi',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    height: 200,
                                    child: LineChart(
                                      LineChartData(
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: spots,
                                            isCurved: true,
                                            color:
                                                Theme.of(context).primaryColor,
                                            barWidth: 2,
                                            dotData: FlDotData(
                                              show: true,
                                              getDotPainter: (spot, percent,
                                                  barData, index) {
                                                return FlDotCirclePainter(
                                                  radius: 4,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  strokeWidth: 2,
                                                  strokeColor: Colors.white,
                                                );
                                              },
                                            ),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                            ),
                                          ),
                                        ],
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  '₺${value.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 10,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value == 0 ||
                                                    value == spots.length - 1) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      history[value.toInt()]
                                                              ['date']
                                                          .toString()
                                                          .substring(5, 10),
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 1,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: Colors.grey[200]!,
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                            left: BorderSide(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        minX: 0,
                                        maxX: spots.length - 1,
                                        minY: minPrice ?? 0,
                                        maxY: maxPrice ?? 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            print('Error rendering price history chart: $e');
                            return Center(
                              child: Text(
                                'Fiyat geçmişi gösterilirken bir hata oluştu',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                            );
                          }
                        },
                      ),
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
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final cartItem = CartItem(
                      name: widget.product.name,
                      price: widget.product.price,
                      image: widget.product.imageUrl,
                    );
                    Provider.of<CartProvider>(context, listen: false)
                        .addItem(cartItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.name} sepete eklendi!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Sepete Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon,
      {Color? valueColor, double? price, double? minPrice, double? maxPrice}) {
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
              Row(
                children: [
                  Text(
                    value ?? '₺${price?.toStringAsFixed(2) ?? ''}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                  if (price != null && price == minPrice) ...[
                    SizedBox(width: 6),
                    Icon(Icons.star, color: Colors.green, size: 18),
                    SizedBox(width: 2),
                    Text('En Ucuz',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                  if (price != null && price == maxPrice) ...[
                    SizedBox(width: 6),
                    Icon(Icons.trending_up, color: Colors.red, size: 18),
                    SizedBox(width: 2),
                    Text('En Pahalı',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ],
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
