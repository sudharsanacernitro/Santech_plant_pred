import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'text_to_speech.dart';
//import 'video_leaner.dart';
import 'global_settings.dart';

class ChatPage extends StatefulWidget {
  final String  disease_name;
  
  const ChatPage({
    Key? key,
    required this.disease_name,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  String? ip=GlobalSettings.instance.ip;
  List<dynamic> chatMessages = [];
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _textController = TextEditingController();

  List<Widget> chatWidgets = [];
  bool _speechEnabled = false;
  bool _isListening = false;
  String _selectedLanguage = 'en_US';
  List<Map<String, String>> _messages = [];

   Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    
  }




  void addMessage(String sender_content, String AI_content) {
    final newMessage = {'sender': sender_content, 'AI': AI_content};
    chatMessages.add(newMessage);
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print("Error: $val"),
      onStatus: (val) => print("Status: $val"),
    );
    setState(() {});
  }

  void _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      },
      localeId: _selectedLanguage,
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

 

  void _sendMessage(String userMessage) async {
      _addMessageWidget(_buildMessageWidget(userMessage, true));
      _textController.clear();

      try {
        Response response = await Dio().post(
          'http://${ip!}:5000/chat',
          data: {
            'message': userMessage,
            'diseaseName':widget.disease_name,
            'lang': _selectedLanguage,

          },
        );

        if (response.statusCode == 200) {
          String reply = response.data['reply'];
          addMessage(userMessage, reply);
          _addMessageWidget(_buildMessageWidget(reply, false));
        } else {
          _addMessageWidget(_buildMessageWidget("Error: Failed to get a response.", false));
        }
      } catch (e) {
        _addMessageWidget(_buildMessageWidget("Error: Could not send message.", false));
      }
    
  }

  Widget _buildMessageWidget(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          TextToSpeechScreenState().speak(message);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 17,
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  void _addMessageWidget(Widget widget) {
    setState(() {
      chatWidgets.add(widget);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('AgroSense',style: TextStyle(fontFamily: 'crisp',color: Color.fromARGB(255, 119, 206, 121)),),
        backgroundColor: Color.fromARGB(255, 26, 27, 26),
        toolbarHeight: 30,
          
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: chatWidgets,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        items: const [
                          DropdownMenuItem(value: 'en_US', child: Text('English')),
                          DropdownMenuItem(value: 'hi_IN', child: Text('Hindi')),
                          DropdownMenuItem(value: 'ta_IN', child: Text('Tamil')),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.blue,
                        ),
                        iconSize: 40,
                        onPressed: _speechEnabled ? _toggleListening : null,
                      ),
                    ],
                  ),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message or use the mic...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed:(){
                          if (_textController.text.isNotEmpty) {
                           _sendMessage( _textController.text); 
                           
                          }
                           } ,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
