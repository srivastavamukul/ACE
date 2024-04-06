import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hackbyte/chat.dart';
import 'package:hackbyte/dashboard.dart';
import 'package:hackbyte/gifanim.dart';
import 'package:hackbyte/login.dart';
import 'package:hackbyte/name.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Welcome extends StatefulWidget {
  final dynamic token;

  const Welcome({required this.token, super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late SharedPreferences prefs;

  void enterRoom(BuildContext context) async {
    if (room.text.isNotEmpty) {
      var reqBody = {
        "room": room.text.trim(),
      };

      var response = await http.post(
          Uri.parse('http://192.168.102.51:3000/room'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      var jsonRes = jsonDecode(response.body);
      if (jsonRes['status']) {
        var uid = jsonRes['UID'];
        print(uid);
        await prefs.setString('UID', uid);
        if (!context.mounted) return;

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                token: widget.token,
                uid: uid,
              ),
            ));
      }
    }
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!context.mounted) return;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ));
  }

  TextEditingController room = TextEditingController();
  late String username;

  @override
  void initState() {
    initSharedPreferences();
    super.initState();
    Map<String, dynamic> jwtDecodedtoken = JwtDecoder.decode(widget.token);
    username = jwtDecodedtoken['username'];
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const GifAnim(gifPath: 'assets/gif/dashboard.gif'),
                    Stats(
                      username: username,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.70,
                        height: 45,
                        child: TextField(
                          style:
                              const TextStyle(color: Colors.white, fontSize: 14),
                          cursorColor: Colors.white,
                          cursorWidth: 2,
                          textAlignVertical: TextAlignVertical.center,
                          cursorHeight: 20,
                          cursorOpacityAnimates: true,
                          cursorRadius: const Radius.circular(20),
                          decoration: InputDecoration(
                            labelText: "Enter a room code",
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: 13,
                            ),
                            fillColor: const Color.fromARGB(255, 67, 67, 67),
                            filled: true,
                            contentPadding: const EdgeInsets.all(10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.white), // Added border color
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Colors.white), // Added border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.white), // Added border color
                            ),
                          ),
                          controller: room,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          enterRoom(context);
                        },
                        style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 67, 67, 67)),
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)))),
                        child: const Text(
                          'Join Room',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 13,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: InkWell(
                onTap: () {
                  logout(context);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 93, 93, 93),
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    SizedBox(
                        width: 10,
                        height: 10,
                        child: Image.asset('assets/icons/logout.png'))
                  ],
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 50,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard(token: widget.token),
                        ));
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 85, 85, 85),
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      SizedBox(
                        width: 35,
                        height: 35,
                        child: Lottie.asset(
                          'assets/gif/rocket.json',
                          fit: BoxFit.contain,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
