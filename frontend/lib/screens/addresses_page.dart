import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';
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
      appBar: AppBar(
        title: const Text('Adreslerim'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kayıtlı Adreslerim',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: addresses.isEmpty
                        ? Center(
                            child: Text(
                              'Kayıtlı adresiniz bulunmamaktadır!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(address['address_title']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${address['mahalle']}, ${address['state']}, ${address['city']}'),
                                      Text(address['address_details']),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddAddressPage(
                                            existingAddress: address,
                                          ),
                                        ),
                                      ).then((_) {
                                        _loadAddresses(); // Refresh the list when returning from edit page
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAddressPage(),
                          ),
                        ).then((_) {
                          _loadAddresses(); // Refresh the list when returning from add page
                        });
                      },
                      child: const Text('Yeni Adres Ekle'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}