import 'package:flutter/material.dart';
import 'package:hackbyte/dashboard.dart';
import 'package:hackbyte/login.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  final dynamic token;
  const Splash({
    @required this.token,
    super.key,
  });

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool exists = false;

  @override
  void initState() {
    checkExist(widget.token);
    super.initState();
  }

  void checkExist(token) {
    if (token != null) {
      if (!JwtDecoder.isExpired(token)) {
        exists = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? token = widget.token;
    Future.delayed(const Duration(seconds: 4), () {
      if (exists) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => (Dashboard(token: token))),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => (const Login())),
        );
      }
    });

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Center(
          child: SizedBox(
            child: Lottie.asset(
              'assets/gif/splash.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
