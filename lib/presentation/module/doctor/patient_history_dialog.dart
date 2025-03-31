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
      Query query = FirebaseFirestore.instance
          .collection('patients')
          .where('firstName', isEqualTo: widget.firstName)
          .where('lastName', isEqualTo: widget.lastName)
          .where('sex', isEqualTo: widget.sex)
          .where('bloodGroup', isEqualTo: widget.bloodGroup)
          .where('phone1', isEqualTo: widget.phone1)
          .where('phone2', isEqualTo: widget.phone2)
          .where('dob', isEqualTo: widget.dob);

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          opHistory = [];
          ipHistory = [];
          isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> fetchedOpHistory = [];
      List<Map<String, dynamic>> fetchedIpHistory = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('opNumber') &&
            data['opNumber'] != widget.opNumber) {
          fetchedOpHistory.add({
            'patientId': data['opNumber'],
            'time': data['time'],
            'date': data['opAdmissionDate'],
            'opAdmissionDate': data['opAdmissionDate'] ?? '',
            'symptoms': (data['investigationTests']
                    as Map<String, dynamic>?)?['symptoms'] ??
                '',
            'findings': data['findings'] ?? '',
            'rxPrescription': data['Medication'] ?? '',
          });
        }
        if (data.containsKey('ipNumber') &&
            data['ipNumber'] != widget.ipNumber) {
          DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .doc('details')
              .get();

          String date = detailsDoc.exists ? detailsDoc['date'] ?? '' : '';
          fetchedIpHistory.add({
            'patientId': data['ipNumber'],
            'time': date,
            'date': (data['ipPrescription']
                    as Map<String, dynamic>?)?['details']?['date'] ??
                '',
            'opAdmissionDate': data['opAdmissionDate'] ?? '',
            'symptoms': (data['investigationTests']
                    as Map<String, dynamic>?)?['symptoms'] ??
                '',
            'findings': data['findings'] ?? '',
            'rxPrescription': data['Medication'] ?? '',
          });
        }
      }

      fetchedOpHistory
          .sort((a, b) => b['opAdmissionDate'].compareTo(a['opAdmissionDate']));
      fetchedIpHistory
          .sort((a, b) => b['opAdmissionDate'].compareTo(a['opAdmissionDate']));

      setState(() {
        opHistory = fetchedOpHistory;
        ipHistory = fetchedIpHistory;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
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
      title: Text('Patient History'),
      content: isLoading
          ? Center(child: CircularProgressIndicator())
          : (opHistory.isEmpty && ipHistory.isEmpty)
              ? Center(child: CustomText(text: "No history found"))
              : SingleChildScrollView(
                  child: SizedBox(
                    width: screenWidth * 0.25,
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
                                        "Op number: ${opHistory[index]['patientId']} on ${opHistory[index]['date']}",
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
                                          CustomText(
                                              text:
                                                  'Findings: ${opHistory[index]['findings']}'),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 50.0),
                                            child: CustomText(
                                                text:
                                                    'Rx Prescription: ${opHistory[index]['rxPrescription']}'),
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
                                        "Ip number: ${ipHistory[ipIndex]['patientId']} on ${ipHistory[ipIndex]['date']} ${ipHistory[ipIndex]['time']}",
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
                                          CustomText(
                                              text:
                                                  'Findings: ${ipHistory[ipIndex]['findings']}'),
                                          SizedBox(height: screenHeight * 0.01),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 50.0),
                                            child: CustomText(
                                                text:
                                                    'Rx Prescription: ${ipHistory[ipIndex]['rxPrescription']}'),
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
