import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}
class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {});
    });
  }

  String _formatPhoneNumber(String input) {
    String formatted = '';
    List<int> grouping = [3, 3, 2, 2];
    int index = 0;

    for (int group in grouping) {
      if (index >= input.length) break;
      if (formatted.isNotEmpty) formatted += ' ';
      formatted += input.substring(index, index + group > input.length ? input.length : index + group);
      index += group;
    }

    return formatted;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hesap Bilgilerim'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('E-mail'),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email alanı boş olamaz";
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return "Geçerli bir email giriniz";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
             Row(
                children: [
                  // Country Code Field
                  Container(
                    width: 100,
                    child: TextFormField(
                      initialValue: '+90', // Default country code
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Ülke Kodu',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Phone Number Field
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefon Numarası', // Label on top of the box
                        hintText: '123-456-78-90', // Placeholder text when empty
                        hintStyle: TextStyle(color: Colors.grey[500]), // Lighter, paler hint text
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (text) {
                        setState(() {
                          // Format the phone number as user types
                          _phoneController.text = _formatPhoneNumber(text.replaceAll(RegExp(r'\D'), ''));
                          _phoneController.selection = TextSelection.fromPosition(TextPosition(offset: _phoneController.text.length));
                        });
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                ],
              ),

              SizedBox(height: 16),
              const Text('Ad'),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              const Text('Soyad'),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Implement saving updated information logic here
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Bilgileriniz güncellenmiştir!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Tamam'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
