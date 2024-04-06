import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class Stats extends StatelessWidget {
  final String username;

  const Stats({super.key, required this.username});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Transform.translate(
        offset: const Offset(0, -58),
        child: Stack(children: [
          GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.92,
            height: 82,
            borderRadius: 20,
            alignment: Alignment.center,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF494949).withOpacity(0.2),
                const Color(0xFF494949).withOpacity(0.1),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Hey! Anony$username",
                    style: const TextStyle(
                        fontSize: 17,
                        fontFamily: 'Roboto',
                        color: Color.fromARGB(255, 213, 213, 213),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                ),
                const Text(
                  "Welcome to ACE",
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Roboto',
                      color: Color.fromARGB(255, 127, 127, 127),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none),
                ),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}
