import 'package:flutter/material.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/gestures.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/app_logo.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    //_loadCredentials();
  }

  /*Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = _emailController.text.isNotEmpty;  
    });
  }*/

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;

      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      _surnameController.clear();
      _isPasswordVisible = false;
      _isConfirmPasswordVisible = false;

      _formKey.currentState?.reset();
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }
/*
  void _submitForm() async {
    if (true) {
      //Navigator.pushReplacementNamed(context, '/home');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePage()), // Replace `HomePage` with the actual name of your home page widget
      );
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final url =
          _isLoginMode ? '${baseUrl}users/login/' : '${baseUrl}users/register/';
      final body = _isLoginMode
          ? {
              'email': _emailController.text,
              'password': _passwordController.text,
            }
          : {
              'email': _emailController.text,
              'password': _passwordController.text,
              'first_name': _nameController.text,
              'last_name': _surnameController.text,
            };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_isLoginMode
                  ? "Login successful!"
                  : "Registration successful!")));

          // Navigate to HomePage after successful login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed: ${response.body}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("An error occurred: $e")));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }*/

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final url =
          _isLoginMode ? '${baseUrl}users/login/' : '${baseUrl}users/register/';
      final body = _isLoginMode
          ? {
              'email': _emailController.text,
              'password': _passwordController.text,
            }
          : {
              'email': _emailController.text,
              'password': _passwordController.text,
              'first_name': _nameController.text,
              'last_name': _surnameController.text,
            };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Parse the response to get the token
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];

          // Save the token regardless of whether it's login or registration
          await AuthService.saveToken(token);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_isLoginMode
                  ? "Login successful!"
                  : "Registration successful!")));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed: ${response.body}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("An error occurred: $e")));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo and welcome text
                Column(
                  children: [
                    // App Logo
                    const AppLogo(size: 120),
                    const SizedBox(height: 8),
                    // Welcome Text
                    Text(
                      "PriceLess'a Hoşgeldiniz",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),

                // Auth mode toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoginMode ? null : _toggleAuthMode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isLoginMode
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusM),
                              ),
                              child: Center(
                                child: Text(
                                  "Giriş Yap",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isLoginMode
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoginMode ? _toggleAuthMode : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isLoginMode
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusM),
                              ),
                              child: Center(
                                child: Text(
                                  "Üye Ol",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !_isLoginMode
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form fields
                if (!_isLoginMode) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Ad',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Bu alan boş bırakılamaz'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            labelText: 'Soyad',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Bu alan boş bırakılamaz'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Bu alan boş bırakılamaz'
                      : RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                          ? null
                          : 'Lütfen geçerli bir e-posta giriniz',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifre giriniz';
                    } else if (value.length < 6) {
                      return 'Şifreniz en az altı karakterden oluşmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_isLoginMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (newValue) {
                              setState(() {
                                _rememberMe = newValue!;
                              });
                            },
                          ),
                          const Text("Beni hatırla"),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // şifreni unuttun mu? buraya yaz
                        },
                        child: const Text(
                          "Şifremi unuttum",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                if (!_isLoginMode)
                  TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Şifre Doğrulama',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi tekrar giriniz';
                        } else if (value != _passwordController.text) {
                          return 'Şifreler aynı değil';
                        }
                        return null;
                      }),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusL),
                            ),
                          ),
                          child: Text(
                            _isLoginMode ? "Giriş Yap" : "Hesap Oluştur",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                if (_isLoginMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: RichText(
                      text: TextSpan(
                        text: "Henüz üye değil misiniz? ",
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: "Üye ol",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _toggleAuthMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!_isLoginMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: RichText(
                      text: TextSpan(
                        text: "Zaten bir hesabınız var mı? ",
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: "Giriş yap",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _toggleAuthMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
