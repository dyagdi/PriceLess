import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:flutter/services.dart'; 
import 'package:http/http.dart' as http;

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _addressTitleController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _mahalleController = TextEditingController();

  List<String> cities = [];
  Map<String, List<String>> statesByCity = {};
  String? selectedCity;
  String? selectedState;

  @override
  void initState() {
    super.initState();
    _loadCityStateData();
  }

  Future<void> _loadCityStateData() async {
    final String response = await rootBundle.loadString('assets/cities_states.json');
    final Map<String, dynamic> data = json.decode(response);

    setState(() {
      cities = data.keys.toList();
      statesByCity = data.map((key, value) => MapEntry(key, List<String>.from(value)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adres Ekle'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _addressTitleController,
              label: 'Adres Başlığı*',
              hint: 'Ev, Ofis...',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressLineController,
              label: 'Adres*',
              hint: 'Cumhuriyet Bulvarı, Menekşe Apartman',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: _buildDropdown(
                  label: 'İl*',
                  value: selectedCity,
                  items: cities,
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                      selectedState = null; 
                    });
                  },
                ),
              ),
              const SizedBox(width: 6), 
              Flexible(
                flex: 1,
                child: _buildDropdown(
                  label: 'İlçe*',
                  value: selectedState,
                  items: selectedCity != null ? statesByCity[selectedCity!] ?? [] : [],
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                  },
                ),
              ),
            ],
          ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _postalCodeController,
                    label: 'Posta Kodu',
                    hint: '34000',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _mahalleController,
                    label: 'Mahalle*',
                    hint: 'Üniversiteliler Mahallesi',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final addressData = {
                    'address_title': _addressTitleController.text.trim(),
                    'address_details': _addressLineController.text.trim(), 
                    'city': selectedCity,
                    'state': selectedState,
                    'country': 'Turkey',
                    'postal_code': _postalCodeController.text.trim(),
                    'mahalle': _mahalleController.text.trim(),
                  };

                  if ([
                    addressData['address_title'],
                    addressData['address_details'],
                    addressData['city'],
                    addressData['state'],
                    addressData['mahalle'],
                  ].any((value) => value == null || value.toString().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen zorunlu alanları doldurunuz')),
                    );
                    return;
                  }

                  try {
                    final response = await http.post(
                      Uri.parse('http://127.0.0.1:8000/api/addresses/'), 
                      headers: {
                        'Content-Type': 'application/json',
                      },

                      body: json.encode(addressData),
                    );

                    if (response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adres başarıyla kaydedildi!')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: ${response.statusCode} - ${response.body}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bir hata oluştu: $e')),
                    );
                  }
                },

                child: const Text('Adresi kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hint,
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }

 Widget _buildDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14), 
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

}