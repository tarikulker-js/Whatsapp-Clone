import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whatsapp/components/Appbar.dart';
import 'package:whatsapp/screens/HomeScreen.dart';
import 'package:whatsapp/screens/LoginScreen.dart';
import 'package:whatsapp/storage/SecureStorage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final secureStorage = SecureStorage();
  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _register() async {
    String fullname = _fullnameController.text;
    String email = _emailController.text;
    String phoneNumber = _phoneNumberController.text;
    String password = _passwordController.text;

    final response = await http.post(
      Uri.parse("https://whatsapp-backend--tarik11.repl.co/signup"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'fullname': fullname, 
        'email': email, 
        'phoneNumber': phoneNumber, 
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (BuildContext context) => LoginScreen()),
          (router) => false);
    } else {
      print(response.body);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Hata"),
          content: Text("Kullanıcı adı veya şifre yanlış."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    }
  }

  void _checkToken() async {
    final token = await secureStorage.read('token');
    print('token: $token');

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (BuildContext context) => HomeScreen()),
          (router) => false);
    }
  }

  void initState() {
    _checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: MyAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _fullnameController,
              cursorColor: Colors.white,
              decoration: new InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.0),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.white, width: 0.0)),
                labelText: "Ad ve Soyadınız",
                labelStyle: const TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _emailController,
              cursorColor: Colors.white,
              decoration: new InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.0),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.white, width: 0.0)),
                labelText: "E-Mail",
                labelStyle: const TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _phoneNumberController,
              cursorColor: Colors.white,
              decoration: new InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.0),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.white, width: 0.0)),
                labelText: "Telefon Numaranız",
                labelStyle: const TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              cursorColor: Colors.white,
              decoration: new InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.0),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 0.0)),
                labelText: "Şifreniz",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text("Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}
