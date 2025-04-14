import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechScreenState  {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();

  Future<void> speak(String text) async {
    
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

}

