import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/text/primary_text.dart';

class PatientHistoryDialog extends StatefulWidget {
  @override
  _PatientHistoryDialogState createState() => _PatientHistoryDialogState();
}

class _PatientHistoryDialogState extends State<PatientHistoryDialog> {
  List<bool> isOpSignClicked = [];
  List<bool> isIpSignClicked = [];

  @override
  void initState() {
    super.initState();
    isOpSignClicked = List.generate(100, (index) => false);
    isIpSignClicked = List.generate(100, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Map<String, String>> opHistory = [
      {
        'patientId': 'Fox001234',
        'time': '10:30',
        'date': '2024-01-25',
      },
      {
        'patientId': 'Fox001234',
        'time': '10:30',
        'date': '2024-01-25',
      },
      {
        'patientId': 'Fox001234',
        'time': '10:30',
        'date': '2024-01-25',
      },
      {
        'patientId': 'Fox001234',
        'time': '10:30',
        'date': '2024-01-25',
      },
    ];

    List<Map<String, String>> ipHistory = [
      {
        'patientId': 'Fox001234',
        'time': '10:30',
        'date': '2024-01-25',
      },
    ];

    return AlertDialog(
      title: Text('Patient History'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: screenWidth * 0.25,
          height: screenHeight * 0.6,
          child: ListView.builder(
            itemCount:
                opHistory.length + ipHistory.length, // Correct total count
            itemBuilder: (context, index) {
              if (index < opHistory.length) {
                return TimelineTile(
                  isFirst: index == 0,
                  isLast: index == opHistory.length - 1,
                  beforeLineStyle: const LineStyle(color: Colors.grey),
                  indicatorStyle: const IndicatorStyle(
                    width: 20,
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  endChild: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text:
                              "Op number : ${opHistory[index]['patientId']!} on ${opHistory[index]['date']!} ${opHistory[index]['time']!}",
                        ),
                        Row(
                          children: [
                            const CustomText(
                                text: 'Sign :                          '),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isOpSignClicked[index] =
                                      !isOpSignClicked[index];
                                });
                              },
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.secondaryColor,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                        if (isOpSignClicked[index])
                          const Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Column(
                              children: [
                                CustomText(text: 'Symptoms : '),
                                CustomText(text: 'Findings : '),
                                Padding(
                                  padding: EdgeInsets.only(left: 50.0),
                                  child: Column(
                                    children: [
                                      CustomText(text: 'Rx Prescription : '),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              // Display the Ip history after all Op history is shown
              else {
                int ipIndex =
                    index - opHistory.length; // Adjust the index for ipHistory
                return TimelineTile(
                  isFirst: ipIndex == 0,
                  isLast: ipIndex == ipHistory.length - 1,
                  beforeLineStyle: const LineStyle(color: Colors.grey),
                  indicatorStyle: const IndicatorStyle(
                    width: 20,
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  endChild: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text:
                              "Ip number : ${ipHistory[ipIndex]['patientId']!} on ${ipHistory[ipIndex]['date']!} ${ipHistory[ipIndex]['time']!}",
                        ),
                        Row(
                          children: [
                            const CustomText(
                                text: 'Sign :                          '),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isIpSignClicked[ipIndex] =
                                      !isIpSignClicked[ipIndex];
                                });
                              },
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.secondaryColor,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                        if (isIpSignClicked[ipIndex])
                          Padding(
                            padding: EdgeInsets.only(
                                top: 5.0, left: screenWidth * 0.009),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(text: 'Symptoms : '),
                                CustomText(text: 'Findings : '),
                                SizedBox(height: screenHeight * 0.01),
                                CustomTextField(
                                  hintText: 'Discharge Summary',
                                  width: 200,
                                  verticalSize: 5,
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
