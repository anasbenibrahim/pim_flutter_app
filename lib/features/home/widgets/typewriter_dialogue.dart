import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _indigo = Color(0xFF022F40);

class TypewriterDialogue extends StatefulWidget {
  final String text;
  final Duration charDelay;

  const TypewriterDialogue({
    super.key,
    required this.text,
    this.charDelay = const Duration(milliseconds: 50),
  });

  @override
  State<TypewriterDialogue> createState() => _TypewriterDialogueState();
}

class _TypewriterDialogueState extends State<TypewriterDialogue> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant TypewriterDialogue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    setState(() {
      _displayedText = '';
      _currentIndex = 0;
    });

    if (widget.text.isEmpty) return;

    _timer = Timer.periodic(widget.charDelay, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(maxWidth: 180.w), // Scaled down the box width
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h), // Scaled down padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
          bottomLeft: Radius.circular(4.r), // The "tail" pointing to Hopi
        ),
        boxShadow: [
          BoxShadow(
            color: _indigo.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _displayedText,
        style: TextStyle(
          fontSize: 12.sp, // Scaled down font size
          color: _indigo,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}
