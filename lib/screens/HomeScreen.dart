import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:whatsapp/components/Appbar.dart';
import 'package:whatsapp/screens/ChatScreen.dart';
import 'package:whatsapp/screens/LoginScreen.dart';
import 'package:whatsapp/storage/SecureStorage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var users = [];
  var myId = null;
  var jwt = null;
  final secureStorage = SecureStorage();
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

  void _checkToken() async {
    final token = await secureStorage.read('token');
    final user = await secureStorage.read('user');

    if (token!.isEmpty && user!.isEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (BuildContext context) => LoginScreen()),
          (router) => false);
    } else {
      setState(() {
        myId = user;
        jwt = token;
      });

      loadUsers();
    }
  }

  void loadUsers() async {
    final response = await http.get(
      Uri.parse("https://whatsapp-backend--tarik11.repl.co/users"),
      headers: {"Content-Type": "application/json", 'Authorization': jwt},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;

      setState(() {
        users = jsonData;
        isLoading = false;
      });

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else {
      //throw Exception("Failed to load messages");
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
        body: ListView.builder(
          controller: _scrollController,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            // ! Message Box
            return BuildChatListItem(user: user);
          },
        ));
  }
}

class BuildChatListItem extends StatelessWidget {
  final Map<String, dynamic> user;

  const BuildChatListItem({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = user['pic'] ??
        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";

    return InkWell(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (BuildContext context) => ChatScreen(user: user['id'])));
      },
      child: Container(
        width: 200,
        height: 100,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 0.1, color: Colors.white),
            bottom: BorderSide(width: 0.1, color: Colors.white),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Stack(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27.5),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl), // imageUrl kullanın
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: user['online'] == true ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['fullname'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 275,
                    child: Text(
                      "${user['fullname']} ile sohbete başlayın!",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
