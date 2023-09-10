import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/screens/LoginScreen.dart';
import 'package:whatsapp/storage/SecureStorage.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SecureStorage secureStorage = SecureStorage();

  MyAppBar({super.key});

  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: secureStorage.read('token'),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Veri henüz yüklenmediyse bir yükleniyor gösterebilirsiniz
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Hata varsa hata mesajını gösterebilirsiniz
          return Text('Hata: ${snapshot.error}');
        } else {
          final String? token = snapshot.data;

          if (token != null && token.isNotEmpty) {
            return AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "Whatsapp",
                style: TextStyle(fontSize: 20),
              ),
              centerTitle: true,
              elevation: 0.0,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  iconSize: 30,
                  onPressed: () {
                    secureStorage.delete('token');

                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (BuildContext context) => LoginScreen(),
                      ),
                      (router) => false,
                    );
                  },
                ),
              ],
            );
          } else {
            // Token null veya boşsa AppBar'ı oluşturma
            return AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "Whatsapp",
                style: TextStyle(fontSize: 20),
              ),
              centerTitle: true,
              elevation: 0.0,
              actions: [],
            );
          }
        }
      },
    );
  }
}
