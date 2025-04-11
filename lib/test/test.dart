import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';



class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  void _sendMessage() async {
    String input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'text': input});
      _controller.clear();
    });

    String response = await handleUserInput(input);
    setState(() {
      messages.add({'sender': 'bot', 'text': response});
    });
  }

  Future<String> handleUserInput(String userInput) async {
    final docScheduleRegex = RegExp(r'dr\.?\s*([a-zA-Z]+)', caseSensitive: false);
    final monthRegex = RegExp(r'(january|february|march|april|may|june|july|august|september|october|november|december)', caseSensitive: false);
    final yearRegex = RegExp(r'\b(20\d{2})\b');

    if (userInput.toLowerCase().contains("schedule") && docScheduleRegex.hasMatch(userInput)) {
      final doctorMatch = docScheduleRegex.firstMatch(userInput);
      final monthMatch = monthRegex.firstMatch(userInput);
      final yearMatch = yearRegex.firstMatch(userInput);

      if (doctorMatch != null && monthMatch != null && yearMatch != null) {
        final doctorName = "Dr. ${doctorMatch.group(1)![0].toUpperCase()}${doctorMatch.group(1)!.substring(1).toLowerCase()}";
        final monthName = monthMatch.group(1)!.toLowerCase();
        final year = int.parse(yearMatch.group(1)!);

        final monthMap = {
          'january': 1, 'february': 2, 'march': 3, 'april': 4,
          'may': 5, 'june': 6, 'july': 7, 'august': 8,
          'september': 9, 'october': 10, 'november': 11, 'december': 12
        };

        final month = monthMap[monthName]!;
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 1);

        final query = await FirebaseFirestore.instance
            .collection('doctorSchedulesMonthly')
            .where('doctorName', isEqualTo: doctorName)
            .where('timestamp', isGreaterThanOrEqualTo: start)
            .where('timestamp', isLessThan: end)
            .get();

        if (query.docs.isEmpty) {
          return "❌ No schedule found for $doctorName in ${monthName[0].toUpperCase()}${monthName.substring(1)} $year.";
        }

        StringBuffer reply = StringBuffer();
        reply.writeln("📅 $doctorName's schedule for ${monthName[0].toUpperCase()}${monthName.substring(1)} $year:");

        for (var doc in query.docs) {
          var d = doc.data();
          var date = DateTime.parse(d['date']);
          reply.writeln("- ${date.day}/${date.month}/${date.year}: Morning ${d['fromTimeMorning']}–${d['toTimeMorning']}, Evening ${d['fromTimeEvening']}–${d['toTimeEvening']}");
        }
        return reply.toString();
      }
    }

    // Patient Info Query
    if (userInput.toLowerCase().contains("patient")) {
      final nameMatch = RegExp(r'patient\s+([a-zA-Z0-9]+)', caseSensitive: false).firstMatch(userInput);
      if (nameMatch != null) {
        final firstName = nameMatch.group(1)!;
        final query = await FirebaseFirestore.instance
            .collection('patients')
            .where('firstName', isEqualTo: firstName)
            .get();

        if (query.docs.isEmpty) {
          return "❌ No patient found with name $firstName.";
        }

        var data = query.docs.first.data();
        if (userInput.toLowerCase().contains("created")) {
          return "🗓️ Patient $firstName was created on: ${data['date']}";
        }
        if (userInput.toLowerCase().contains("blood group")) {
          return "🩸 Patient $firstName's blood group is: ${data['bloodGroup']}";
        }
        if (userInput.toLowerCase().contains("sex")) {
          return "👤 Patient $firstName's sex is: ${data['sex']}";
        }
        return "ℹ️ Available details for $firstName:\nDate: ${data['date']}\nBlood Group: ${data['bloodGroup']}\nSex: ${data['sex']}";
      }
    }

    return "🤖 I didn't understand that. Try asking about a doctor's schedule or a patient's detail.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firestore ChatBot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg['text']!, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Ask something...")),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          )
        ],
      ),
    );
  }
}
