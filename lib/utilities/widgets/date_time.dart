import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../colors.dart';

class TimeDateWidget extends StatefulWidget {
  final String text;
  const TimeDateWidget({super.key, required this.text});

  @override
  _TimeDateWidgetState createState() => _TimeDateWidgetState();
}

class _TimeDateWidgetState extends State<TimeDateWidget> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String formattedTime = DateFormat.jm().format(_now);
    String formattedDate = DateFormat('dd/MM/yyyy EEEE').format(_now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: screenWidth * 0.008),
          child: Column(
            children: [
              CustomText(
                text: widget.text,
                size: screenWidth * 0.0275,
                color: AppColors.blue,
              ),
            ],
          ),
        ),
        Column(
          children: [
            CustomText(
              text: formattedTime,
              color: AppColors.blue,
              size: screenWidth * 0.02,
            ),
            SizedBox(height: screenHeight * 0.005),
            CustomText(
              text: formattedDate,
              color: AppColors.blue,
            )
          ],
        ),
        Container(
          width: screenWidth * 0.15,
          height: screenWidth * 0.05,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            image: const DecorationImage(
              image: AssetImage('assets/foxcare_lite_logo.png'),
            ),
          ),
        ),
      ],
    );
  }
}
