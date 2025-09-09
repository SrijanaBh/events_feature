import 'dart:async';
import 'package:flutter/material.dart';

class LoopingTypingAppBarTitle extends StatefulWidget {
  final List<String> messages;
  final Duration typingSpeed;
  final Duration pauseDuration;

  const LoopingTypingAppBarTitle({
    super.key,
    required this.messages,
    this.typingSpeed = const Duration(milliseconds: 100),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  State<LoopingTypingAppBarTitle> createState() =>
      _LoopingTypingAppBarTitleState();
}

class _LoopingTypingAppBarTitleState extends State<LoopingTypingAppBarTitle> {
  String _displayedText = '';
  int _currentMessageIndex = 0;
  int _charIndex = 0;
  Timer? _typingTimer;
  Timer? _cursorBlinkTimer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  void _startCursorBlink() {
    _cursorBlinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(widget.typingSpeed, (timer) {
      final currentMessage = widget.messages[_currentMessageIndex];

      if (_charIndex < currentMessage.length) {
        setState(() {
          _displayedText += currentMessage[_charIndex];
          _charIndex++;
        });
      } else {
        // Pause before switching to next message
        timer.cancel();
        Future.delayed(widget.pauseDuration, () {
          setState(() {
            _charIndex = 0;
            _displayedText = '';
            _currentMessageIndex =
                (_currentMessageIndex + 1) % widget.messages.length;
          });
          _startTyping();
        });
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorBlinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_displayedText${_showCursor ? " * * *" : " "}',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }
}
