import 'package:flutter/material.dart';
import 'package:frontend/screens/login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

//const String baseUrl = 'http://144.122.207.230:8000/api/';
const String baseUrl = 'http://127.0.0.1:8000/api/';
