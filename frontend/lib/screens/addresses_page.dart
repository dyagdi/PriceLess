import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/widgets/loading_indicator.dart';
import 'add_address_page.dart';

class AddressManagementPage extends StatefulWidget {
  @override
  _AddressManagementPageState createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  List<Map<String, dynamic>> addresses = [];
  bool _isLoading = true;

  String _fixTurkishChars(String? text) {
    if (text == null) return '';

    final Map<String, String> turkishChars = {
      'Ä±': 'ı',
      'Ä°': 'İ',
      'Ã¶': 'ö',
      'Ã–': 'Ö',
      'Ã¼': 'ü',
      'Ãœ': 'Ü',
      'ÅŸ': 'ş',
      'Å': 'Ş',
      'Ä': 'ğ',
      'Ä': 'Ğ',
      'Ã§': 'ç',
      'Ã‡': 'Ç',
      'â€™': "'",
      'â€"': "–",
      'â€"': "-",
      'â€œ': '"',
      'â€': '"',
    };

    String fixedText = text;
    turkishChars.forEach((key, value) {
      fixedText = fixedText.replaceAll(key, value);
    });
    return fixedText;
  }

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen önce giriş yapın")),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}addresses/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          addresses = data.map((item) {
            Map<String, dynamic> address = Map<String, dynamic>.from(item);
            return {
              ...address,
              'address_title': _fixTurkishChars(address['address_title']),
              'address_details': _fixTurkishChars(address['address_details']),
              'city': _fixTurkishChars(address['city']),
              'state': _fixTurkishChars(address['state']),
              'mahalle': _fixTurkishChars(address['mahalle']),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adresler yüklenirken hata oluştu")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('${baseUrl}addresses/$addressId/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Adres başarıyla silindi")),
        );
        _loadAddresses();
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adres silinirken hata oluştu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Adreslerim',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Kayıtlı Adreslerim',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                ? const CustomLoadingIndicator(message: "Adresleriniz yükleniyor...")
                : addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kayıtlı adresiniz bulunmamaktadır!',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              address['address_title'] ?? '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  address['address_details'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${address['mahalle']}, ${address['state']}, ${address['city']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                              onPressed: () => _deleteAddress(address['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddAddressPage()),
            ).then((_) => _loadAddresses());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
          child: Text(
            'Yeni Adres Ekle',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
