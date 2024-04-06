import 'package:flutter/material.dart';

class GifAnim extends StatefulWidget {
  final String gifPath;
  const GifAnim({super.key, required this.gifPath});

  @override
  State<GifAnim> createState() => _GifAnimState();
}

class _GifAnimState extends State<GifAnim> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(0, -15),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              widget.gifPath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      
      ],
    );
  }
}
