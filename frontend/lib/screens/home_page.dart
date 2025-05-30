import 'package:flutter/material.dart';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:frontend/screens/account_page.dart';
import 'package:frontend/screens/discounted_products_page.dart';
import 'package:frontend/screens/popular_products_page.dart';
import 'package:frontend/screens/to_do_list_page.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/screens/popular_product_page.dart';
import 'package:frontend/screens/discounted_product_page.dart';
import 'package:frontend/widgets/search_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/screens/cart_page.dart';
import 'package:frontend/screens/favorites_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/widgets/bottom_navigation.dart';
import 'package:frontend/widgets/product_card.dart';
import 'package:frontend/widgets/search_bar.dart';
import 'package:frontend/screens/discounted_product_page.dart'
    show ProductDetailSheet;
import 'package:frontend/models/address_model.dart';
import 'package:frontend/providers/recently_viewed_provider.dart';
import 'package:frontend/providers/favorites_provider.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/screens/nearby_markets_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/screens/chatbot_page.dart';
import 'package:frontend/providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late Future<List<CheapestProductPc>> _cheapestProducts;
  Map<String, List<dynamic>> categorizedProducts = {};
  bool isLoading = true;
  String currentAddress = "Konum alınıyor...";
  String? selectedAddressId;
  List<Map<String, dynamic>> _nearbyMarkets = [];
  double _userLatitude = 0.0;
  double _userLongitude = 0.0;

  final List<SavedAddress> savedAddresses = [
    SavedAddress(
      id: '1',
      name: 'Ev',
      address: 'Ümit Mh., Meksika Cd., Çankaya',
      isDefault: true,
    ),
    SavedAddress(
      id: '2',
      name: 'İş',
      address: 'Kızılay Mh., Atatürk Blv., Çankaya',
    ),
    SavedAddress(
      id: '3',
      name: 'Okul',
      address: 'ODTÜ, Üniversiteler Mh., Çankaya',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedAddressId = savedAddresses.firstWhere((addr) => addr.isDefault).id;
    _cheapestProducts = fetchCheapestProductsPerCategory();
    _getCurrentLocation();
    loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    try {
      final fetchedProducts = await fetchCheapestProductsPerCategory();
      setState(() {
        categorizedProducts = {};
        for (var product in fetchedProducts) {
          String category = product.category ?? "Uncategorized";
          if (!categorizedProducts.containsKey(category)) {
            categorizedProducts[category] = [];
          }
          categorizedProducts[category]?.add(product);
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchNearbyMarkets(double latitude, double longitude) async {
    const int radius = 1500;

    String overpassQuery = """
  [out:json];
  (
    node["shop"="supermarket"](around:$radius,$latitude,$longitude);
    node["shop"="grocery"](around:$radius,$latitude,$longitude);
    node["amenity"="marketplace"](around:$radius,$latitude,$longitude);
  );
  out;
  """;

    String url = "https://overpass-api.de/api/interpreter?data=" +
        Uri.encodeComponent(overpassQuery);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(utf8DecodedBody);

        List<dynamic> elements = data["elements"];

        setState(() {
          _nearbyMarkets = elements.map<Map<String, dynamic>>((element) {
            // Calculate distance from current location
            double distance = Geolocator.distanceBetween(
                  latitude,
                  longitude,
                  element["lat"],
                  element["lon"],
                ) /
                1000; // Convert to kilometers

            return {
              "name": element["tags"]?["name"] ??
                  element["tags"]?["brand"] ??
                  element["tags"]?["shop"] ??
                  element["tags"]?["amenity"] ??
                  "Unnamed Market",
              "lat": element["lat"],
              "lon": element["lon"],
              "distance": distance,
            };
          }).toList();

          // Sort markets by distance
          _nearbyMarkets.sort((a, b) =>
              (a["distance"] as double).compareTo(b["distance"] as double));
        });
      }
    } catch (e) {
      print("Error fetching markets: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen konum servisini açın.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Konum izni reddedildi.")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Konum izni kalıcı olarak reddedildi.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "tr_TR",
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentAddress =
              "${place.subLocality}, ${place.thoroughfare}, ${place.locality}";
        });
      }
      await fetchNearbyMarkets(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Mevcut konum"),
          content: const Text("Mevcut konumunuzu kullanmak ister misiniz?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _getCurrentLocation();
              },
              child: const Text("Mevcut Konumumu Kullan"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kayıtlı Adreslerim',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Add new address functionality
                    },
                  ),
                ],
              ),
              const Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.4, // Limit to 40% of screen height
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedAddresses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.my_location),
                        title: const Text('Mevcut Konum'),
                        subtitle: Text(currentAddress),
                        trailing: selectedAddressId == null
                            ? Icon(Icons.check,
                                color: Theme.of(context).primaryColor)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedAddressId = null;
                          });
                          _getCurrentLocation();
                          Navigator.pop(context);
                        },
                      );
                    }

                    final address = savedAddresses[index - 1];
                    return ListTile(
                      leading: Icon(
                        address.isDefault ? Icons.home : Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(address.name),
                      subtitle: Text(address.address),
                      trailing: selectedAddressId == address.id
                          ? Icon(Icons.check,
                              color: Theme.of(context).primaryColor)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedAddressId = address.id;
                          currentAddress = address.address;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    // Implement your search logic here
    print('Searching for: $query');
    // You could navigate to a search results page
    // or filter the current products
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }

  // Helper function to truncate long product names
  String _truncateName(String name) {
    if (name.length > 18) {
      return name.substring(0, 18) + "...";
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color:
                isDark ? Colors.amber : Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: isDark ? 'Aydınlık Mod' : 'Karanlık Mod',
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "PriceLess",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.pushNamed(context, '/test-websocket');
            },
          ),
          IconButton(
            icon: Icon(Icons.mail,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.pushNamed(context, '/invitations');
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserAccountPage()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await loadProducts();
                await _getCurrentLocation();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationBar(),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SearchBarButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()),
                              );
                            },
                            hintText: 'Ürün, marka veya kategori ara',
                          ),
                        ),
                        _buildWelcomeBanner(context),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFeaturedCategories(context),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCheapestProducts(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildPersonalizedRecommendations(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildRecentlyViewed(),
                  ),
                  // Add some bottom padding
                  SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        categorizedProducts: categorizedProducts,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatbotPage()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildLocationBar() {
    return GestureDetector(
      onTap: _showAddressSelector,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teslimat Adresi',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    currentAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş Geldiniz!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'En uygun fiyatlı ürünleri keşfedin',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NearbyMarketsPage(
                    markets: _nearbyMarkets,
                    userLatitude: _userLatitude,
                    userLongitude: _userLongitude,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: Text(
              'Yakınımdaki Marketleri Gör',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCategories(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'İndirimli\nÜrünler',
        'icon': Icons.local_offer,
        'color': Colors.orange.withOpacity(0.1),
        'iconColor': Colors.orange,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiscountedProductPage()),
          );
        },
      },
      {
        'name': 'Alışveriş\nSepetim',
        'icon': Icons.checklist,
        'color': Theme.of(context).primaryColor.withOpacity(0.1),
        'iconColor': Theme.of(context).primaryColor,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        },
      },
      {
        'name': 'Favoriler',
        'icon': Icons.favorite,
        'color': Colors.red.withOpacity(0.1),
        'iconColor': Colors.red,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoritesPage(
                categorizedProducts: categorizedProducts,
              ),
            ),
          );
        },
      },
    ];

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: category['onTap'] as VoidCallback,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: category['color'] as Color,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: category['iconColor'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category['name'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheapestProducts() {
    return FutureBuilder<List<CheapestProductPc>>(
      future: _cheapestProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Bir hata oluştu: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Ürün bulunamadı'),
          );
        }

        final products = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Text(
                'En Uygun Fiyatlı Ürünler',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      name: _truncateName(product.name ?? ''),
                      price: product.price ?? 0.0,
                      imageUrl: product.image ?? '',
                      category: product.category ?? '',
                      marketName: product.marketName ?? '',
                      onTap: () => _showProductDetail(context, product),
                      onAddToCart: () => _addToCart(context, product),
                      id: product.id,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProductDetail(BuildContext context, CheapestProductPc product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ProductDetailSheet(
          name: product.name ?? '',
          price: product.price ?? 0.0,
          image: product.image ?? '',
          category: product.category,
          marketName: product.marketName,
          scrollController: scrollController,
          id: product.id,
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, CheapestProductPc product) {
    final cartItem = CartItem(
      name: product.name ?? '',
      price: product.price ?? 0.0,
      image: product.image ?? '',
    );

    context.read<CartProvider>().addItem(cartItem);

    // Use a truncated name for the snackbar message if it's too long
    final displayName = _truncateName(product.name ?? '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$displayName sepete eklendi!'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            context.read<CartProvider>().removeItem(cartItem);
          },
        ),
      ),
    );
  }

  Widget _buildRecentlyViewed() {
    return Consumer<RecentlyViewedProvider>(
      builder: (context, provider, child) {
        final items = provider.items;
        print('Building recently viewed with ${items.length} items');
        print('Items in list: ${items.map((item) => item.name).join(', ')}');

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Text(
                'Son Görüntülenenler',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  print(
                      'Building recently viewed item ${index + 1}: ${product.name}');
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      name: _truncateName(product.name ?? ''),
                      price: product.price ?? 0.0,
                      imageUrl: product.image ?? '',
                      category: product.category ?? '',
                      marketName: product.marketName ?? '',
                      onTap: () => _showProductDetail(context, product),
                      onAddToCart: () => _addToCart(context, product),
                      id: product.id,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalizedRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Text(
            'Sizin İçin Önerilenler',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FutureBuilder<List<CheapestProductPc>>(
          future: _cheapestProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final recommendations = List<CheapestProductPc>.from(snapshot.data!)
              ..shuffle();
            final displayCount =
                recommendations.length > 5 ? 5 : recommendations.length;

            return SizedBox(
              height: 300,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: displayCount,
                itemBuilder: (context, index) {
                  final product = recommendations[index];
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      name: _truncateName(product.name ?? ''),
                      price: product.price ?? 0.0,
                      imageUrl: product.image ?? '',
                      category: product.category ?? '',
                      marketName: product.marketName ?? '',
                      onTap: () => _showProductDetail(context, product),
                      onAddToCart: () => _addToCart(context, product),
                      id: product.id,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
