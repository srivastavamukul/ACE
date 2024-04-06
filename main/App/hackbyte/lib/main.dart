import 'package:flutter/material.dart';
import 'package:hackbyte/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(Hack(
    token: token,
  ));
}

class Hack extends StatefulWidget {
  final dynamic token;
  const Hack({
    @required this.token,
    super.key,
  });

  @override
  State<Hack> createState() => _HackState();
}

class _HackState extends State<Hack> {
  @override
  Widget build(BuildContext context) {
    String? myToken = widget.token;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: const Color(0xff0e0e0e),
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: Splash(
        token: myToken,
      ),
    );
  }
}
