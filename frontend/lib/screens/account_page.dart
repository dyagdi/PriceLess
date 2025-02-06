import 'package:flutter/material.dart';
import 'package:frontend/screens/account_settings.dart';
import 'addresses_page.dart'; 
import 'user_info_page.dart'; 
import 'favorite_carts_page.dart'; 
class UserAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hesabım'),
        backgroundColor: Colors.blue,
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
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.account_circle, size: 40),
        title: Text('Hesap Bilgileri'),
        //subtitle: Text('E-mail, telefon, name, and surname'),
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
        //subtitle: Text('Add, edit, remove addresses'),
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
        //subtitle: Text('View your saved carts'),
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