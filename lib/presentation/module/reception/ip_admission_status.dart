import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/reception/reception_drawer.dart';

import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/general_information/management_general_information_drawer.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class IpAdmissionStatus extends StatefulWidget {
  @override
  State<IpAdmissionStatus> createState() => _IpAdmissionStatus();
}

class _IpAdmissionStatus extends State<IpAdmissionStatus> {
  int selectedIndex = 7;
  TextEditingController _patientID = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  final List<String> headers1 = [
    'OP No',
    'IP Ticket',
    'IP Admit Date',
    'Name',
    'Room/Ward',
    'Consulting Doctor',
  ];
  List<Map<String, dynamic>> tableData1 = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData({String? ipNumber, String? phoneNumber}) async {
    print('Fetching data with OP Number: $ipNumber');

    try {
      List<Map<String, dynamic>> fetchedData = [];
      bool hasIpPrescription = false;
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final QuerySnapshot<Map<String, dynamic>> patientSnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      for (var patientDoc in patientSnapshot.docs) {
        final patientId = patientDoc.id;
        final patientData = patientDoc.data();

        final opTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .collection('ipTickets')
            .get();

        bool found = false;

        for (var ipTicketDoc in opTicketsSnapshot.docs) {
          final ipTicketData = ipTicketDoc.data();
          print(
              'opTicketData: ${ipTicketData['opTicket']}'); // Debugging print statement

          bool matches = false;

          if (patientData['isIP'] == true) {
            if (ipNumber != null && ipTicketData['ipTicket'] == ipNumber) {
              matches = true;
            } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
              if (patientData['phone1'] == phoneNumber ||
                  patientData['phone2'] == phoneNumber) {
                matches = true;
              }
            } else if (ipNumber == null &&
                (phoneNumber == null || phoneNumber.isEmpty)) {
              matches = true;
            }
          }

          if (matches) {
            String tokenNo = '';
            String tokenDate = '';

            if (ipTicketData['discharged'] == true) {
              print(
                  'Skipping discharged IP ticket: ${ipTicketData['ipTicket']}');
              continue;
            }
            DocumentSnapshot ipPrescriptionSnapshot = await FirebaseFirestore
                .instance
                .collection('patients')
                .doc(patientId)
                .collection('ipPrescription')
                .doc('details')
                .get();
            Map<String, dynamic>? detailsData = ipPrescriptionSnapshot.exists
                ? ipPrescriptionSnapshot.data() as Map<String, dynamic>?
                : null;

            fetchedData.add({
              'IP Admit Date': ipTicketData['ipAdmitDate'] ?? 'N/A',
              'OP No': patientData['opNumber'] ?? 'N/A',
              'IP Ticket': ipTicketData['ipTicket'] ?? 'N/A',
              'Name':
                  '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                      .trim(),
              'Room/Ward': detailsData?['ipAdmission']?['roomType'] != null &&
                      detailsData?['ipAdmission']?['roomNumber'] != null
                  ? "${detailsData!['ipAdmission']['roomType']} ${detailsData['ipAdmission']['roomNumber']}"
                  : 'N/A',
              'Consulting Doctor': ipTicketData['doctorName'] ?? 'N/A',
            });

            found = true;
            break;
          }
        }
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token NO']) ?? 0;
        int tokenB = int.tryParse(b['Token NO']) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData1 = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'General Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.03,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.07),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Admission Status ",
                          size: screenWidth * .015,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'IP Number',
                    width: screenWidth * 0.15,
                    controller: _patientID,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(ipNumber: _patientID.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.15,
                    controller: _phoneNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(phoneNumber: _phoneNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  return row['Status'] == 'aborted'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
