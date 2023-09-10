import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whatsapp/components/Appbar.dart';
import 'package:whatsapp/screens/HomeScreen.dart';
import 'package:whatsapp/screens/RegisterScreen.dart';
import 'package:whatsapp/storage/SecureStorage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final secureStorage = SecureStorage();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String phoneNumber = _phoneNumberController.text;
    String password = _passwordController.text;

    final response = await http.post(
      Uri.parse("https://whatsapp-backend--tarik11.repl.co/signin"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber, 'password': password}),
    );

    print(response);
    print("https://whatsapp-backend--tarik11.repl.co/signin");

    if (response.statusCode == 200) {
      await secureStorage.write('token', json.decode(response.body)['token']);
      await secureStorage.write('user', json.decode(response.body)['user']);

      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (BuildContext context) => HomeScreen()),
          (router) => false);
    } else {
      print(response.body);
      // ! Hatalı giriş durumunu burada işleyebilirsiniz.
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

    var verifyToken = await http.get(
      Uri.parse("https://whatsapp-backend--tarik11.repl.co/protected"),
      headers: {"Content-Type": "application/json", "authorization": "$token"},
    );

    if (verifyToken.statusCode != 401) {
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
              onPressed: _login,
              child: Text("Giriş Yap"),
            ),
            Container(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (BuildContext context) => RegisterScreen()));
                },
                child: Text("Hesabınız yok mu? Kayıt olun!"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
