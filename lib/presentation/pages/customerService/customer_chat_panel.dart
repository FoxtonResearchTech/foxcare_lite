import 'package:flutter/material.dart';

import '../../../utilities/colors.dart';

class CustomerChatPanel extends StatefulWidget {
  const CustomerChatPanel({super.key});

  @override
  State<CustomerChatPanel> createState() => _CustomerChatPanelState();
}

class _CustomerChatPanelState extends State<CustomerChatPanel> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.75),
          child: Text(
            "FoxTon Research Center",
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
        ),
        backgroundColor: AppColors.secondaryColor,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.attach_file_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side Chat List
          Container(
            padding: EdgeInsets.only(top: screenWidth * 0.01),
            width: screenWidth * 0.45,
            color: Colors.white,
            child: Container(
                decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/chatbots_for_customer_service.png'),
              ),
            )),
          ),

          // Right Side Chat View
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: screenWidth * 0.012,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Online",
                        style: TextStyle(
                            fontSize: screenWidth * 0.015,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        ChatBubble(
                          message: "Hi",
                          isSender: false,
                        ),
                        ChatBubble(
                          message: "Hello",
                          isSender: true,
                        ),
                        ChatBubble(
                          message: "Can you help me!",
                          isSender: false,
                        ),
                        ChatBubble(
                          message: "How can I help you",
                          isSender: true,
                        ),
                      ],
                    ),
                  ),
                  // Input Field
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.010), // Circular border radius
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      color: AppColors.secondaryColor,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "  How Can I Help You  ",
                                hintStyle: TextStyle(
                                    color: Colors.white, fontFamily: 'Poppins'),
                                filled: true,
                                fillColor: AppColors.secondaryColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          CircleAvatar(
                            backgroundColor: AppColors.secondaryColor,
                            child: Icon(
                              Icons.telegram_sharp,
                              color: Colors.white,
                              size: screenWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12.0),
            topRight: const Radius.circular(12.0),
            bottomLeft: isSender ? const Radius.circular(12.0) : Radius.zero,
            bottomRight: isSender ? Radius.zero : const Radius.circular(12.0),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
              fontSize: screenWidth * 0.01,
              color: Colors.white,
              fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}
