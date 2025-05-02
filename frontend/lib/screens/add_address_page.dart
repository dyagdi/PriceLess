import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';

class AddAddressPage extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;

  AddAddressPage({this.existingAddress});

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  
 
  final _countryController = TextEditingController(text: 'Türkiye');
  final _addressTitleController = TextEditingController();
  final _addressDetailsController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _mahalleController = TextEditingController();

 
  Map<String, List<String>> _citiesAndStates = {};
  String? _selectedCity;
  String? _selectedState;
  int? _addressId;

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
    _loadCitiesAndStates().then((_) {
      if (widget.existingAddress != null) {
        setState(() {
          _addressId = widget.existingAddress!['id'];
          _addressTitleController.text = _fixTurkishChars(widget.existingAddress!['address_title'] ?? '');
          _addressDetailsController.text = _fixTurkishChars(widget.existingAddress!['address_details'] ?? '');
          _postalCodeController.text = widget.existingAddress!['postal_code'] ?? '';
          _mahalleController.text = _fixTurkishChars(widget.existingAddress!['mahalle'] ?? '');
          
          
          final city = _fixTurkishChars(widget.existingAddress!['city'] ?? '');
          final state = _fixTurkishChars(widget.existingAddress!['state'] ?? '');
          
          if (_citiesAndStates.containsKey(city)) {
            _selectedCity = city;
            if (_citiesAndStates[city]!.contains(state)) {
              _selectedState = state;
            }
          }
        });
      }
    });
  }

  Future<void> _loadCitiesAndStates() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/cities_states.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      setState(() {
        _citiesAndStates = Map<String, List<String>>.from(
          data.map((key, value) => MapEntry(key, (value as List).cast<String>()))
        );
      });
    } catch (e) {
      print('Error loading cities and states: $e');
    }
  }

  Future<void> _saveAddress() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen önce giriş yapın")),
        );
        return;
      }

      final url = Uri.parse('${baseUrl}addresses/${_addressId != null ? "$_addressId/" : ""}');
      final method = _addressId != null ? http.put : http.post;

      final requestData = {
        'country': _countryController.text,
        'city': _selectedCity,
        'state': _selectedState,
        'address_title': _addressTitleController.text,
        'address_details': _addressDetailsController.text,
        'postal_code': _postalCodeController.text,
        'mahalle': _mahalleController.text,
      };

      print('Sending address data: $requestData'); 

      final response = await method(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: jsonEncode(requestData),
      );

      print('Response status: ${response.statusCode}'); 
      print('Response body: ${response.body}'); 

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_addressId != null ? "Adres başarıyla güncellendi" : "Adres başarıyla kaydedildi")),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to save address: ${response.body}');
      }
    } catch (e) {
      print('Error saving address: $e'); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adres kaydedilirken hata oluştu: ${e.toString()}")),
      );
    }
  }

  Future<void> _deleteAddress() async {
    try {
      if (_addressId == null) return;

      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('${baseUrl}addresses/$_addressId/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Adres başarıyla silindi")),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adres silinirken hata oluştu")),
      );
    }
  }

  Widget _buildStateDropdown() {
    List<DropdownMenuItem<String>> items = [];
    if (_selectedCity != null && _citiesAndStates[_selectedCity] != null) {
      items = _citiesAndStates[_selectedCity]!
          .where((state) => state != "**")
          .map((String state) => DropdownMenuItem<String>(
                value: state,
                child: Text(_fixTurkishChars(state)),
              ))
          .toList();
      items.sort((a, b) => a.child.toString().compareTo(b.child.toString()));
    }

    return DropdownButtonFormField<String>(
      value: _selectedState,
      decoration: InputDecoration(
        labelText: 'İlçe',
        border: OutlineInputBorder(),
      ),
      items: items,
      onChanged: (String? newValue) {
        setState(() {
          _selectedState = newValue;
        });
      },
      validator: (value) => value == null ? 'Lütfen ilçe seçin' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAddress != null ? 'Adresi Düzenle' : 'Yeni Adres Ekle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _countryController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Ülke',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'İl',
                    border: OutlineInputBorder(),
                  ),
                  items: _citiesAndStates.keys
                    .map((String city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(_fixTurkishChars(city)),
                        ))
                    .toList()
                    ..sort((a, b) => a.child.toString().compareTo(b.child.toString())),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                      _selectedState = null;
                    });
                  },
                  validator: (value) => value == null ? 'Lütfen il seçin' : null,
                ),
                SizedBox(height: 16),
                _buildStateDropdown(),
                SizedBox(height: 16),
                TextFormField(
                  controller: _mahalleController,
                  decoration: InputDecoration(
                    labelText: 'Mahalle',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Mahalle alanı boş bırakılamaz' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressTitleController,
                  decoration: InputDecoration(
                    labelText: 'Adres Başlığı (örn: Ev, İş)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Adres başlığı boş bırakılamaz' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressDetailsController,
                  decoration: InputDecoration(
                    labelText: 'Adres Detayı',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Adres detayı boş bırakılamaz' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'Posta Kodu',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveAddress();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.existingAddress != null ? 'Adresi Güncelle' : 'Adresi Kaydet'),
                      ),
                    ),
                    if (widget.existingAddress != null) ...[
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _deleteAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Adresi Sil'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    _addressTitleController.dispose();
    _addressDetailsController.dispose();
    _postalCodeController.dispose();
    _mahalleController.dispose();
    super.dispose();
  }
}