/*import 'package:flutter/material.dart';
import 'pages/auth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PriceLess',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage(), // Set LoginPage as the home screen
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/screens/auth_page.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/screens/discounted_product_page.dart';
import 'package:frontend/screens/popular_product_page.dart';
import 'package:frontend/screens/to_do_list_page.dart';
import 'package:frontend/screens/favorite_carts_page.dart';
import 'package:frontend/screens/cart_page.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/providers/recently_viewed_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PriceLess',
      theme: AppTheme.lightTheme,
      home: const AuthPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/discounted': (context) => DiscountedProductPage(),
        '/popular': (context) => PopularProductPage(),
        '/shopping-list': (context) => ToDoListPage(),
        '/favorites': (context) => FavoriteCartsPage(),
        '/cart': (context) => CartPage(),
      },
    );
  }
}






/* FLUTTER NOTLARIM:
Stateless Widget: A widget that doesn't change over time. Its UI is static and will not update unless the entire widget is rebuilt.

const MyApp({super.key}); is the constructor
In Flutter, every widget is part of a widget tree. Sometimes, Flutter needs to keep track of where each widget is in the tree, 
especially when widgets are rebuilt. A key is like a unique ID for a widget that helps Flutter keep track of it during complex 
operations (like moving widgets around, animations, or rebuilding the UI). It ensures that Flutter knows which widget is which
 when things change.
The super.key part means that you're passing this "key" up to the superclass. In this case, the superclass is StatelessWidget. 
So, you're telling Flutter: "This widget (MyApp) has a unique key that can help you identify it in the widget tree."

MyApp calls MyHomePage, it is the first page shown to user


class _MyHomePageState extends State<MyHomePage> {
_MyHomePageState is a state class, and it extends State<MyHomePage>, meaning it manages the state for the MyHomePage widget.
This is where all the mutable data (data that can change) and the logic for how MyHomePage behaves is placed.
The underscore _ before MyHomePageState makes the class private, meaning it can only be accessed within the file.

 */