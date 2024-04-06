import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hackbyte/login.dart';
import 'package:hackbyte/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignUpState();
}

class _SignUpState extends State<Signup> {
  late SharedPreferences prefs;

  TextEditingController email = TextEditingController();

  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();

  @override
  void initState() {
    initsharedpref();
    super.initState();
  }

  void initsharedpref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser(BuildContext context) async {
    if (email.text.isNotEmpty &&
        password.text.isNotEmpty &&
        username.text.isNotEmpty &&
        email.text.contains('@') &&
        username.text.length > 2 && username.text.length < 16 &&
        password.text.length >= 6 && password.text.length < 31) {
      var reqBody = {
        "username": username.text.trim(),
        "email": email.text.trim(),
        "password": password.text.trim()
      };

      var response = await http.post(
          Uri.parse('http://192.168.102.51:3000/register'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      var jsonRes = jsonDecode(response.body);
      if (jsonRes['status']) {
        var myToken = jsonRes['token'];
        await prefs.setString('token', myToken);
        if (!context.mounted) return;

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Welcome(token: myToken),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: Stack(
        children: [
          Transform.translate(
            offset: const Offset(0, 60),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset(
                  'assets/gif/login.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 350,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GlassmorphicContainer(
                      width: MediaQuery.of(context).size.width,
                      height: 350,
                      borderRadius: 20,
                      alignment: Alignment.center,
                      linearGradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(44, 137, 137, 137),
                          Color.fromARGB(44, 82, 82, 82),
                        ],
                      ),
                      blur: 6,
                      borderGradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey,
                        ],
                      ),
                      border: 0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white38),
                        ),
                        SizedBox(
                          width: 200,
                          height: 40,
                          child: TextField(
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            cursorColor: Colors.white,
                            cursorWidth: 2,
                            textAlignVertical: TextAlignVertical.center,
                            cursorHeight: 20,
                            cursorOpacityAnimates: true,
                            cursorRadius: const Radius.circular(20),
                            decoration: InputDecoration(
                              labelText: "Enter your username",
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
                            controller: username,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          height: 40,
                          child: TextField(
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            cursorColor: Colors.white,
                            cursorWidth: 2,
                            textAlignVertical: TextAlignVertical.center,
                            cursorHeight: 20,
                            cursorOpacityAnimates: true,
                            cursorRadius: const Radius.circular(20),
                            decoration: InputDecoration(
                              labelText: "Enter your email",
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
                            controller: email,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          height: 40,
                          child: TextField(
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            cursorColor: Colors.white,
                            obscureText: true,
                            obscuringCharacter: "\$",
                            cursorWidth: 2,
                            textAlignVertical: TextAlignVertical.center,
                            cursorHeight: 20,
                            cursorOpacityAnimates: true,
                            cursorRadius: const Radius.circular(20),
                            decoration: InputDecoration(
                              labelText: "Enter your password",
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
                            controller: password,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            loginUser(context);
                          },
                          style: ButtonStyle(
                              alignment: Alignment.center,
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 67, 67, 67)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)))),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                color: Colors.white),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already registered?',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Login(),
                                        ));
                                  },
                                  child: const Text('Login',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
