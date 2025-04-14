import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiKey = 'AIzaSyANxMbt3hW08LbIcYETq4jfTaQ_Y0Cbep0'; // 🔑 Replace with your key
const String geminiUrl =
    'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey';



class GeminiChatPage extends StatefulWidget {
  @override
  _GeminiChatPageState createState() => _GeminiChatPageState();
}

class _GeminiChatPageState extends State<GeminiChatPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> _askGemini(String prompt) async {
    setState(() => _response = "Thinking...");

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final res = await http.post(
        Uri.parse(geminiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() => _response = content);
      } else {
        setState(() => _response = "Error: ${res.statusCode}");
      }
    } catch (e) {
      setState(() => _response = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gemini Chatbot")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ask something...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _askGemini(_controller.text),
              child: Text("Send"),
            ),
            SizedBox(height: 20),
            Text(
              _response,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
