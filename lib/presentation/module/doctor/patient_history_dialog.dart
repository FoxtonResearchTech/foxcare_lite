import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/text/primary_text.dart';

class PatientHistoryDialog extends StatefulWidget {
  final String? opNumber;
  final String? firstName;
  final String? lastName;
  final String? sex;
  final String? bloodGroup;
  final String? phone1;
  final String? phone2;
  final String? dob;
  final String? ipNumber;

  PatientHistoryDialog({
    this.firstName,
    this.lastName,
    this.sex,
    this.bloodGroup,
    this.phone1,
    this.phone2,
    this.dob,
    this.opNumber,
    this.ipNumber,
  });

  @override
  _PatientHistoryDialogState createState() => _PatientHistoryDialogState();
}

class _PatientHistoryDialogState extends State<PatientHistoryDialog> {
  List<bool> isOpSignClicked = [];
  List<bool> isIpSignClicked = [];
  List<Map<String, dynamic>> opHistory = [];
  List<Map<String, dynamic>> ipHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isOpSignClicked = List.generate(100, (index) => false);
    isIpSignClicked = List.generate(100, (index) => false);
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> fetchedOpHistory = [];
      List<Map<String, dynamic>> fetchedIpHistory = [];

      if (widget.opNumber == null || widget.opNumber!.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final opTicketsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.opNumber!)
          .collection('opTickets')
          .get();

      for (var doc in opTicketsSnapshot.docs) {
        final data = doc.data();
        fetchedOpHistory.add({
          'patientId': data['opTicket'],
          'date': data['tokenDate'] ?? '',
          'symptoms': data['investigationTests']?['symptoms'] ?? '',
          'rxPrescription': data['Medication'] ?? '',
        });
      }

      final ipTicketsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.opNumber)
          .collection('ipTickets')
          .get();

      for (var ipDoc in ipTicketsSnapshot.docs) {
        final ipData = ipDoc.data();
        final ipTicketId = ipData['ipTicket'];
        final ipAdmitDate = ipData['ipAdmitDate'] ?? '';
        final ipSymptoms = ipData['investigationTests']?['symptoms'] ?? '';

        final medicationSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.opNumber)
            .collection('ipTickets')
            .doc(ipDoc.id)
            .collection('Medication')
            .get();

        List<dynamic> prescriptions = [];

        for (var medDoc in medicationSnapshot.docs) {
          final medData = medDoc.data();
          prescriptions.add({
            'date': medData['date'] ?? '',
            'Medications': medData['items'] ?? '',
          });
        }

        fetchedIpHistory.add({
          'patientId': ipTicketId,
          'date': ipAdmitDate,
          'symptoms': ipSymptoms,
          'rxPrescription': prescriptions, // list of meds
        });
      }

      fetchedOpHistory.sort((a, b) => b['date'].compareTo(a['date']));
      fetchedIpHistory.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {
        opHistory = fetchedOpHistory;
        ipHistory = fetchedIpHistory;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching ticket data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: CustomText(
        text: 'Patient History',
        size: screenWidth * 0.014,
      ),
      content: isLoading
          ? SizedBox(
              width: screenWidth * 0.3,
              height: screenHeight * 0.6,
              child: Center(
                  child: CircularProgressIndicator(
                color: AppColors.blue,
              )))
          : (opHistory.isEmpty && ipHistory.isEmpty)
              ? SizedBox(
                  width: screenWidth * 0.3,
                  height: screenHeight * 0.6,
                  child: Center(child: CustomText(text: "No history found")))
              : SingleChildScrollView(
                  child: SizedBox(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.6,
                    child: ListView.builder(
                      itemCount: opHistory.length + ipHistory.length,
                      itemBuilder: (context, index) {
                        if (index < opHistory.length) {
                          return TimelineTile(
                            isFirst: index == 0,
                            isLast: index == opHistory.length - 1,
                            beforeLineStyle:
                                const LineStyle(color: Colors.grey),
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
                                        "OP number: ${opHistory[index]['patientId']} on ${opHistory[index]['date']}",
                                  ),
                                  Row(
                                    children: [
                                      const CustomText(text: 'Sign: '),
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
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                              text:
                                                  'Symptoms: ${opHistory[index]['symptoms']}'),
                                          CustomText(text: 'Findings: '),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 50.0),
                                            child: CustomText(
                                                text:
                                                    'Prescription: ${opHistory[index]['rxPrescription']}'),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          int ipIndex = index - opHistory.length;
                          return TimelineTile(
                            isFirst: ipIndex == 0,
                            isLast: ipIndex == ipHistory.length - 1,
                            beforeLineStyle:
                                const LineStyle(color: Colors.grey),
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
                                        "IP number: ${ipHistory[ipIndex]['patientId']} on ${ipHistory[ipIndex]['date']} ",
                                  ),
                                  Row(
                                    children: [
                                      const CustomText(text: 'Sign: '),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                              text:
                                                  'Symptoms: ${ipHistory[ipIndex]['symptoms']}'),
                                          CustomText(text: 'Findings'),
                                          SizedBox(height: screenHeight * 0.01),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 50.0),
                                            child: CustomText(
                                                text:
                                                    'Prescription: \n ${ipHistory[ipIndex]['rxPrescription']}'),
                                          ),
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
