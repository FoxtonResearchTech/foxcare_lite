import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/op_counters.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/presentation/module/reception/reception_ip_patient.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import '../doctor/ip_prescription.dart';
import 'admission_status.dart';
import 'doctor_schedule.dart';
import 'ip_admission.dart';
import 'op_ticket.dart';

class IpPatientsAdmission extends StatefulWidget {
  @override
  State<IpPatientsAdmission> createState() => _IpPatientsAdmission();
}

class _IpPatientsAdmission extends State<IpPatientsAdmission> {
  TextEditingController _ipNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  final List<String> headers1 = [
    'Token NO',
    'IP NO',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action',
    'Abort',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;
  int selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData({String? ipNumber, String? phoneNumber}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (ipNumber != null) {
        query = query.where('ipNumber', isEqualTo: ipNumber);
      } else if (phoneNumber != null) {
        query = query.where(Filter.or(
          Filter('phone1', isEqualTo: phoneNumber),
          Filter('phone2', isEqualTo: phoneNumber),
        ));
      }
      final QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('ipNumber')) continue;

        String tokenNo = '';
        bool hasIpPrescription = false;

        try {
          final tokenSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('tokens')
              .doc('currentToken')
              .get();

          if (tokenSnapshot.exists) {
            final tokenData = tokenSnapshot.data();
            if (tokenData != null && tokenData['tokenNumber'] != null) {
              tokenNo = tokenData['tokenNumber'].toString();
            }
          }
          final ipPrescriptionSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .get();

          if (ipPrescriptionSnapshot.docs.isNotEmpty) {
            hasIpPrescription = true;
          }
        } catch (e) {
          print('Error fetching token No for patient ${doc.id}: $e');
        }

        if (!hasIpPrescription) {
          fetchedData.add({
            'Token NO': tokenNo,
            'OP NO': data['opNumber'] ?? 'N/A',
            'IP NO': data['ipNumber'] ?? 'N/A',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'Age': data['age'] ?? 'N/A',
            'Place': data['state'] ?? 'N/A',
            'Address': data['address1'] ?? 'N/A',
            'PinCode': data['pincode'] ?? 'N/A',
            'Status': data['status'] ?? 'N/A',
            'Primary Info': data['otherComments'] ?? 'N/A',
            'Action': TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceptionIpPatient(
                        patientID: data['opNumber'] ?? 'N/A',
                        ipNumber: data['ipNumber'] ?? 'N/A',
                        name:
                            '${data['firstName'] ?? ''} ${data['lastName'] ?? 'N/A'}'
                                .trim(),
                        age: data['age'] ?? 'N/A',
                        place: data['state'] ?? 'N/A',
                        address: data['address1'] ?? 'N/A',
                        pincode: data['pincode'] ?? 'N/A',
                        primaryInfo: data['otherComments'] ?? 'N/A',
                        temperature: data['temperature'] ?? 'N/A',
                        bloodPressure: data['bloodPressure'] ?? 'N/A',
                        sugarLevel: data['bloodSugarLevel'] ?? 'N/A',
                      ),
                    ),
                  );
                },
                child: const CustomText(text: 'IP Rooms')),
            'Abort': TextButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('patients')
                        .doc(data['ipNumber'])
                        .update({'status': 'aborted'});

                    CustomSnackBar(context,
                        message: 'Status updated to aborted');
                  } catch (e) {
                    print(
                        'Error updating status for patient ${data['patientID']}: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update status')),
                    );
                  }
                },
                child: const CustomText(text: 'Abort'))
          });
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
      print('Error fetching data from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text(
                'OP Ticket Dashboard',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            )
          : null,
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
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Sidebar width for larger screens
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
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.02,
                  right: screenWidth * 0.02,
                  bottom: screenWidth * 0.33,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                text: "IP Patient Admission",
                                size: screenWidth * 0.025,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.14,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.05),
                              image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/foxcare_lite_logo.png'))),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          hintText: 'IP Number',
                          width: screenWidth * 0.15,
                          controller: _ipNumber,
                        ),
                        SizedBox(width: screenHeight * 0.02),
                        CustomButton(
                          label: 'Search',
                          onPressed: () {
                            fetchData(ipNumber: _ipNumber.text);
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
