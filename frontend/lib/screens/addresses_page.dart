import 'package:flutter/material.dart';
import 'add_address_page.dart'; 

class AddressManagementPage extends StatefulWidget {
  @override
  _AddressManagementPageState createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  final List<String> _addresses = [
    "ODTÜ 1. yurt",
    "ODTÜ 19. yurt",
  ]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adreslerim'),
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
                  // adres editlicez
                },
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAddressPage(),
                  ),
                ).then((newAddress) {
                  if (newAddress != null) {
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