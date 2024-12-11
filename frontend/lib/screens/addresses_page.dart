import 'package:flutter/material.dart';
import 'add_address_page.dart'; // Import the AddAddressPage

class AddressManagementPage extends StatefulWidget {
  @override
  _AddressManagementPageState createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  final List<String> _addresses = [
    "123 Main St, Springfield",
    "456 Elm St, Springfield",
  ]; // Sample addresses

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adreslerim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            for (var address in _addresses)
              ListTile(
                title: Text(address),
                trailing: Icon(Icons.edit),
                onTap: () {
                  // Implement address editing functionality here
                  // You can navigate to an "Edit Address" page if needed
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the AddAddressPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAddressPage(),
                  ),
                ).then((newAddress) {
                  if (newAddress != null) {
                    // Add the returned new address to the list and update the state
                    setState(() {
                      _addresses.add(newAddress);
                    });
                  }
                });
              },
              child: const Text('Yeni Adres Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
