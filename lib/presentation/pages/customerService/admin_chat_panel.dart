import 'package:flutter/material.dart';

import '../../../utilities/colors.dart';

class AdminChatPanel extends StatefulWidget {
  const AdminChatPanel({super.key});

  @override
  State<AdminChatPanel> createState() => _AdminChatPanelState();
}

class _AdminChatPanelState extends State<AdminChatPanel> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.70),
          child: Text(
            "Bejan Singh Eye Hospital",
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          ),
        ),
        backgroundColor: AppColors.secondaryColor,
        leading: const Icon(
          Icons.search,
          color: Colors.white,
        ),
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
            width: screenWidth * 0.35,
            color: Colors.white,
            child: ListView.separated(
              itemCount: 20,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade400,
                thickness: 1.0,
              ),
              itemBuilder: (context, index) {
                return Container(
                  height: screenHeight * 0.10,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        Positioned(
                          top: -1,
                          left: -1,
                          child: Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 12,
                          ),
                        ),
                        CircleAvatar(
                          radius: screenHeight * 0.05,
                          backgroundImage:
                              AssetImage('assets/hospital_logo.png'),
                        ),
                      ],
                    ),
                    title: Text(
                      "  Bejan Singh Eye Hospital",
                      style: TextStyle(
                          fontSize: screenWidth * 0.013, fontFamily: 'Poppins'),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.022, left: screenWidth * 0.22),
                      child: Text(
                        "12:10 AM",
                        style: TextStyle(
                            color: Colors.green, fontFamily: 'Poppins'),
                      ),
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),

          // Right Side Chat View
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
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
                                    color: Colors.white,
                                    fontFamily: 'SanFrancisco'),
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
