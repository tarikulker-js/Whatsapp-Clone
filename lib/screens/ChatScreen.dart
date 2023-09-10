import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/components/Appbar.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:whatsapp/screens/LoginScreen.dart';
import 'package:whatsapp/storage/SecureStorage.dart';

class ChatScreen extends StatefulWidget {
  final user;

  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var myId;
  var jwt;
  var messages = [];
  TextEditingController messageController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  late IO.Socket socket;
  final secureStorage = SecureStorage();

  void jumpToButtom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

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

      loadMessages();
    }
  }

  void initState() {
    super.initState();

    _checkToken();
  }

  void loadMessages() async {
    final response = await http.get(
      Uri.parse("https://whatsapp-backend--tarik11.repl.co/get-messages/${widget.user}"),
      headers: {"Content-Type": "application/json", 'Authorization': jwt},
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body) as List<dynamic>;

      setState(() {
        messages = jsonData;
        isLoading = false;
      });

      jumpToButtom();
    } else {
      throw Exception("Failed to load messages");
    }

    // ! Socket Bağlantı Kurulumu
    socket = IO.io(
        'https://whatsapp-backend--tarik11.repl.co',
        IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
            {'authorization': '$jwt'}).build());

    socket.onConnectError((error) {
      print('Socket bağlantısı sırasında hata oluştu: $error');
    });

    // ! Socket üzerinden mesaj dinleme
    socket.on('message', (data) {
      print("yeni bir mesaj " + data.toString());
      final getedsender = data['sender'];
      final getedMessage = data['message'];
      setState(() {
        messages.add(data);
      });

      jumpToButtom();
    });

    // ! Socket üzerinden hata dinleme
    socket.on('error', (data) {
      print("yeni bir hata " + data.toString());
    });
  }

  void sendMessage(String messageText) {
    var data = {'message': messageText, 'receiver': widget.user};
    socket.emit('message', data);

    /*setState(() {
      messages.add(data);
    });*/

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });

    messageController.clear();

    FocusScope.of(context).requestFocus(_focusNode);
  }

  String formatCreatedAt(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return DateFormat('d MMM y').format(createdAt);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'şimdi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          children: [
            // ! Messages
            _buildChatMessages(),

            // ! Send Message Box
            _buildChatSendMessage(),
          ],
        ),
      ),
    );
    ;
  }

  Widget _buildChatSendMessage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onSubmitted: (value) {
                if (messageController.text.isNotEmpty) {
                  sendMessage(messageController.text);
                }
              },
              focusNode: _focusNode,
              cursorColor: Colors.white,
              controller: messageController,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: "Mesajınız",
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            color: Colors.white,
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                sendMessage(messageController.text);
              }
            },
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return Container(
      height: MediaQuery.of(context).size.height - 180,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final bool isMyMessage = message['sender']['id'] == myId;

          // ! Message Box
          return _buildChatMessageBox(isMyMessage, message);
        },
      ),
    );
  }

  Widget _buildChatMessageBox(bool isMyMessage, Map<String, dynamic> message) {
    return Container(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            !isMyMessage ? message['sender']['fullname'] : "Siz",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isMyMessage ? Colors.blue : Colors.grey,
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              message['message'] ?? "",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Text(
            message.containsKey("createdAt")
                ? formatCreatedAt(
                    DateTime.parse(message["createdAt"].toString()))
                : formatCreatedAt(DateTime.now()),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
