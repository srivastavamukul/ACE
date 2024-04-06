import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

class Chat {
  final String id;
  final String subject;
  final String message;

  Chat(this.id, this.subject, this.message);

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      json['_id'],
      json['subject'],
      json['message'],
    );
  }
}

class HomePage extends StatefulWidget {
  final dynamic token;
  final dynamic uid;
  const HomePage({@required this.token, @required this.uid, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chat> chats = [];

  late String username = "";
  late String id;
  late io.Socket socket;

  @override
  void initState() {
    fetchChats();
    socket = io.io('http://192.168.102.51:3000', <String, dynamic>{
      'transports': ['websocket'],
      "autoConnect": false,
    });

    socket.connect();

    if (widget.token != null) {
      Map<String, dynamic> jwtDecodedtoken = JwtDecoder.decode(widget.token);
      username = jwtDecodedtoken['username'] ?? "";
      id = jwtDecodedtoken['_id'];
    }

    super.initState();
  }

  TextEditingController chat = TextEditingController();
  TextEditingController subjectCont = TextEditingController();

  void sendChat(String id, String status, String subject, String message,
      String room) async {
    if (chat.text.isNotEmpty && subjectCont.text.isNotEmpty) {
      var reqBody = {
        "_id": id,
        "status": status,
        "subject": subject,
        "message": message,
        "room": room
      };

      var response = await http.post(
          Uri.parse('http://192.168.102.51:3000/chat'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      if (response.statusCode == 200) {
        // Emit the newChat event to notify the server
        socket.emit('new', 'rebuild');

        socket.on("build", (data) {
          fetchChats();
        });
      }
    }
  }

  Future<void> fetchChats() async {
    var reqBody = {
      "room": widget.uid,
    };
    var response = await http.post(
        Uri.parse('http://192.168.102.51:3000/fetch'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        chats = responseData
            .map((data) => Chat.fromJson(data))
            .where((chat) => chat.id == id)
            .toList();
      });
    } else {
      throw Exception('Failed to load chats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      'assets/gif/chat.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    'Room ${widget.uid}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ListTile(
                    title: Text(
                      chat.subject,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 157, 157, 157),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chat.message,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      cursorWidth: 2,
                      textAlignVertical: TextAlignVertical.center,
                      cursorHeight: 20,
                      cursorOpacityAnimates: true,
                      cursorRadius: const Radius.circular(20),
                      decoration: InputDecoration(
                        labelText: "Subject",
                        labelStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontSize: 13),
                        fillColor: const Color.fromARGB(255, 67, 67, 67),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      controller: subjectCont,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      cursorWidth: 2,
                      textAlignVertical: TextAlignVertical.center,
                      cursorHeight: 20,
                      cursorOpacityAnimates: true,
                      cursorRadius: const Radius.circular(20),
                      decoration: InputDecoration(
                        labelText: "Enter the message",
                        labelStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontSize: 13),
                        fillColor: const Color.fromARGB(255, 67, 67, 67),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      controller: chat,
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        sendChat(id, "pending", subjectCont.text, chat.text,
                            widget.uid);
                        chat.text = "";
                        subjectCont.text = "";
                        fetchChats();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
