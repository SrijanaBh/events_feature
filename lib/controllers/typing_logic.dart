import 'dart:async';
import 'package:flutter/material.dart';

class TypingAppBarTitle extends StatefulWidget {
  final String fullText;
  final Duration typingSpeed;

  const TypingAppBarTitle({
    super.key,
    required this.fullText,
    this.typingSpeed = const Duration(milliseconds: 100),
  });

  @override
  State<TypingAppBarTitle> createState() => _TypingAppBarTitleState();
}

class _TypingAppBarTitleState extends State<TypingAppBarTitle> {
  String displayedText = '';
  int currentIndex = 0;
  Timer? typingTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    typingTimer = Timer.periodic(widget.typingSpeed, (timer) {
      if (currentIndex < widget.fullText.length) {
        setState(() {
          displayedText += widget.fullText[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
