import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding the JSON file
import 'package:flutter/services.dart'; // For loading the asset

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
        title: const Text('Add Address'),
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
            selectedState = null; // Reset state when city changes
          });
        },
      ),
    ),
    const SizedBox(width: 16),
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
                    hint: 'e.g., 34000',
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
                onPressed: () {
                  final addressData = {
                    'address_title': _addressTitleController.text.trim(),
                    'address_line': _addressLineController.text.trim(),
                    'city': selectedCity,
                    'state': selectedState,
                    'country': 'Turkey', // Default value
                    'postal_code': _postalCodeController.text.trim(),
                    'mahalle': _mahalleController.text.trim(),
                  };

                  // Check only the mandatory fields
                  if ([
                    addressData['address_title'],
                    addressData['address_line'],
                    addressData['city'],
                    addressData['state'],
                    addressData['mahalle'],
                  ].any((value) => value == null || value.toString().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen zorunlu alanları doldurunuz')),
                    );
                  } else {
                    Navigator.pop(context, addressData);
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
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
