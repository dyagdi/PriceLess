import 'package:flutter/material.dart';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:frontend/screens/account_page.dart';
import 'package:frontend/services/product_service.dart';
// ignore: unused_import
import 'package:frontend/screens/popular_product_page.dart';
import 'package:frontend/screens/discounted_product_page.dart';
// ignore: unused_import
import 'package:frontend/widgets/search_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/screens/cart_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/widgets/product_card.dart';
import 'package:frontend/widgets/search_bar.dart';
import 'package:frontend/screens/discounted_product_page.dart'
    show ProductDetailSheet;
import 'package:frontend/models/address_model.dart';
import 'package:frontend/providers/recently_viewed_provider.dart';

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
              ListView.builder(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "PriceLess",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationBar(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSearch: _handleSearch,
                    hintText: 'Ürün, marka veya kategori ara',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Hoş Geldiniz!',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'En uygun fiyatlı ürünleri keşfedin',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _buildFeaturedCategories(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'En Uygun Fiyatlı Ürünler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCheapestProducts(),
          ),
          SliverToBoxAdapter(
            child: _buildRecentlyViewed(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category, color: Colors.black),
            label: 'Kategoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.black),
            label: 'Listem',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLocationBar() {
    return GestureDetector(
      onTap: _showAddressSelector,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teslimat Adresi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    currentAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCategories(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name': 'İndirimli\nÜrünler',
        'icon': Icons.local_offer,
        'route': '/discounted'
      } as Map<String, dynamic>,
      {
        'name': 'Popüler\nÜrünler',
        'icon': Icons.trending_up,
        'route': '/popular'
      } as Map<String, dynamic>,
      {
        'name': 'Alışveriş\nListem',
        'icon': Icons.checklist,
        'route': '/shopping-list'
      } as Map<String, dynamic>,
      {'name': 'Favoriler', 'icon': Icons.favorite, 'route': '/favorites'}
          as Map<String, dynamic>,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, category['route'] as String),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
        return SizedBox(
          height: 320,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 180,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 8),
                  child: ProductCard(
                    name: product.name ?? '',
                    price: product.price ?? 0.0,
                    imageUrl: product.image ?? '',
                    category: product.category ?? '',
                    onTap: () => _showProductDetail(context, product),
                    onAddToCart: () => _addToCart(context, product),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showProductDetail(BuildContext context, CheapestProductPc product) {
    // Add to recently viewed when showing details
    context.read<RecentlyViewedProvider>().addItem(product);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProductDetailSheet(
          name: product.name ?? '',
          price: product.price ?? 0.0,
          image: product.image ?? '',
          category: product.category ?? '',
          scrollController: scrollController,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} sepete eklendi!'),
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
        if (provider.items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Son Görüntülenenler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(
              height: 320,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  final product = provider.items[index];
                  return SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: ProductCard(
                        name: product.name ?? '',
                        price: product.price ?? 0.0,
                        imageUrl: product.image ?? '',
                        category: product.category ?? '',
                        onTap: () => _showProductDetail(context, product),
                        onAddToCart: () => _addToCart(context, product),
                      ),
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
}
