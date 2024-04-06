import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hackbyte/gifanim.dart';
import 'package:hackbyte/login.dart';
import 'package:hackbyte/name.dart';
import 'package:hackbyte/welcome.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final dynamic token;

  const Dashboard({required this.token, super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late SharedPreferences prefs;
  late String username;
  late String _id;
  late int ongoing = 0;
  late int pending = 0;
  late int closed = 0;
  late int stash = 0;

  @override
  void initState() {
    Map<String, dynamic> jwtDecodedtoken = JwtDecoder.decode(widget.token);
    username = jwtDecodedtoken['username'];
    _id = jwtDecodedtoken['_id'];
    getCounts(_id);
    super.initState();
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

  Future<void> getCounts(String id) async {
    try {
      final responsePending = await http.post(
        Uri.parse('http://192.168.102.51:3000/countPending'),
        body: jsonEncode({'_id': _id}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseOngoing = await http.post(
        Uri.parse('http://192.168.102.51:3000/countOngoing'),
        body: jsonEncode({'_id': id}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseClosed = await http.post(
        Uri.parse('http://192.168.102.51:3000/countClosed'),
        body: jsonEncode({'_id': id}),
        headers: {'Content-Type': 'application/json'},
      );

      final responseTotal = await http.post(
        Uri.parse('http://192.168.102.51:3000/countStash'),
        body: jsonEncode({'_id': id}),
        headers: {'Content-Type': 'application/json'},
      );

      if (responsePending.statusCode == 200 &&
          responseOngoing.statusCode == 200 &&
          responseClosed.statusCode == 200 &&
          responseTotal.statusCode == 200) {
        final dataPending = jsonDecode(responsePending.body);
        final dataOngoing = jsonDecode(responseOngoing.body);
        final dataClosed = jsonDecode(responseClosed.body);
        final dataTotal = jsonDecode(responseTotal.body);

        setState(() {
          pending = dataPending['pending'];
          ongoing = dataOngoing['ongoing'];
          closed = dataClosed['closed'];
          stash = dataTotal['stash'];
        });
      } else {
        throw Exception('Failed to load counts');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const GifAnim(gifPath: 'assets/gif/dashboard.gif'),
                  Stats(
                    username: username,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: const SizedBox(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 42, 42, 42),
                          borderRadius: BorderRadius.circular(15)),
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pending Anonymity',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              ),
                              Text(
                                '$pending',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              )
                            ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 42, 42, 42),
                          borderRadius: BorderRadius.circular(15)),
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ongoing Anonymity',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              ),
                              Text(
                                '$ongoing',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              )
                            ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 42, 42, 42),
                          borderRadius: BorderRadius.circular(15)),
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Closed Anonymity',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              ),
                              Text(
                                '$closed',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              )
                            ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 42, 42, 42),
                          borderRadius: BorderRadius.circular(15)),
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Stash',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              ),
                              Text(
                                '$stash',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none),
                              )
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  )
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
                        builder: (context) => Welcome(token: widget.token),
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
                      child: Lottie.asset('assets/gif/rocket.json'),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 15,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
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
          ),
        ],
      ),
    );
  }
}
