import 'package:flutter/material.dart';
import 'package:frontend/screens/account_settings.dart';
import 'addresses_page.dart'; 
import 'user_info_page.dart'; 
import 'favorite_carts_page.dart'; 
import 'package:frontend/widgets/bottom_navigation.dart';

class UserAccountPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hesabım'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildUserInfoSection(context),
            _buildAddressesSection(context),
            _buildFavoriteCartsSection(context),
            _buildAccountSettingsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: -1,  
        categorizedProducts: const {},
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.account_circle, size: 40),
        title: Text('Hesap Bilgileri'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserInfoPage()),
          );
        },
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.location_on, size: 40),
        title: Text('Adres Bilgileri'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddressManagementPage()),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCartsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.shopping_cart, size: 40),
        title: Text('Favori Sepetlerim'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavoriteCartsPage()),
          );
        },
      ),
    );
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.settings, size: 40),
        title: Text('Hesap Ayarları'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AccountSettingsPage()),
          );
        },
      ),
    );
  }
}