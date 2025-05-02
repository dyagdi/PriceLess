import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _phoneController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen önce giriş yapın")),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}user-info/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _emailController.text = data['email'] ?? '';
          _nameController.text = data['first_name'] ?? '';
          _surnameController.text = data['last_name'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kullanıcı bilgileri yüklenirken hata oluştu")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserInfo() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen önce giriş yapın")),
        );
        return;
      }

      final response = await http.put(
        Uri.parse('${baseUrl}user-info/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: jsonEncode({
          'first_name': _nameController.text,
          'last_name': _surnameController.text,
          'phone_number': _phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bilgileriniz başarıyla güncellendi")),
        );
      } else {
        throw Exception('Failed to update user info');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bilgiler güncellenirken hata oluştu")),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hesap Bilgilerim'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('E-mail'),
                    TextFormField(
                      controller: _emailController,
                      enabled: false, // Email field is disabled
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        color: Colors.grey[600], // Making the text grey
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          child: TextFormField(
                            initialValue: '+90',
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Ülke Kodu',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Telefon Numarası',
                              hintText: '123-456-78-90',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (text) {
                              final numericText = text.replaceAll(RegExp(r'\D'), '');
                              if (numericText != text) {
                                setState(() {
                                  _phoneController.text = _formatPhoneNumber(numericText);
                                  _phoneController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _phoneController.text.length),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Ad'),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    Text('Soyad'),
                    TextFormField(
                      controller: _surnameController,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _saveUserInfo();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }
}
