import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/pharmacy_stocks.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/doctor/doctor_module_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import '../doctor/ip_prescription.dart';
import 'doctor_rx_list.dart';

class IpPatientsDetails extends StatefulWidget {
  final String doctorName;
  const IpPatientsDetails({Key? key, required this.doctorName})
      : super(key: key);

  @override
  State<IpPatientsDetails> createState() => _IpPatientsDetails();
}

class _IpPatientsDetails extends State<IpPatientsDetails> {
  TextEditingController _ipNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  DateTime now = DateTime.now();

  final List<String> headers1 = [
    'Token NO',
    'IP Ticket',
    'IP Admit Date',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action',
    'Abscond',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;
  int selectedIndex = 2;
  String? roomNumber;
  String? roomType;

  @override
  void initState() {
    super.initState();
    fetchData();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   fetchData();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

          if (ipTicketData['doctorName'] == widget.doctorName &&
              patientData['isIP'] == true) {
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

            try {
              final tokenSnapshot = await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientId)
                  .collection('tokens')
                  .doc('currentToken')
                  .get();

              if (tokenSnapshot.exists) {
                final tokenData = tokenSnapshot.data();
                if (tokenData != null && tokenData['tokenNumber'] != null) {
                  tokenNo = tokenData['tokenNumber'].toString();
                }
                if (tokenData != null && tokenData['date'] != null) {
                  tokenDate = tokenData['date'];
                }
              }
            } catch (e) {
              print('Error fetching tokenNo for patient $patientId: $e');
            }
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
              'Token NO': tokenNo,
              'IP Admit Date': ipTicketData['ipAdmitDate'] ?? 'N/A',
              'OP NO': patientData['opNumber'] ?? 'N/A',
              'IP Ticket': ipTicketData['ipTicket'] ?? 'N/A',
              'Name':
                  '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                      .trim(),
              'Age': patientData['age'] ?? 'N/A',
              'Place': patientData['city'] ?? 'N/A',
              'Address': patientData['address1'] ?? 'N/A',
              'PinCode': patientData['pincode'] ?? 'N/A',
              'Status': ipTicketData['status'] ?? 'N/A',
              'Primary Info': ipTicketData['otherComments'] ?? 'N/A',
              'Action': TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IpPrescription(
                          patientID: patientData['opNumber'] ?? 'N/A',
                          name:
                              '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? 'N/A'}'
                                  .trim(),
                          city: patientData['city'] ?? 'N/A',
                          roomWard: detailsData?['ipAdmission']?['roomType'] !=
                                      null &&
                                  detailsData?['ipAdmission']?['roomNumber'] !=
                                      null
                              ? "${detailsData!['ipAdmission']['roomType']} ${detailsData['ipAdmission']['roomNumber']}"
                              : 'N/A',
                          date: ipTicketData['ipAdmitDate'] ?? 'N/A',
                          ipAdmitDate: ipTicketData['ipAdmitDate'] ?? 'N/A',
                          age: patientData['age'] ?? 'N/A',
                          place: patientData['state'] ?? 'N/A',
                          address: patientData['address1'] ?? 'N/A',
                          pincode: patientData['pincode'] ?? 'N/A',
                          primaryInfo: ipTicketData['otherComments'] ?? 'N/A',
                          temperature: ipTicketData['temperature'] ?? 'N/A',
                          bloodPressure: ipTicketData['bloodPressure'] ?? 'N/A',
                          sugarLevel: ipTicketData['bloodSugarLevel'] ?? 'N/A',
                          phone1: patientData['phone1'],
                          phone2: patientData['phone2'],
                          sex: patientData['sex'],
                          bloodGroup: patientData['bloodGroup'],
                          firstName: patientData['firstName'],
                          lastName: patientData['lastName'],
                          dob: patientData['dob'],
                          doctorName: widget.doctorName,
                          ipNumber: ipTicketData['ipTicket'],
                          specialization: ipTicketData['specialization'],
                        ),
                      ),
                    );
                  },
                  child: const CustomText(text: 'Prescribe')),
              'Abscond': TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('patients')
                          .doc(patientId)
                          .collection('ipTickets')
                          .doc(ipTicketData['ipTicket'])
                          .update({'status': 'abscond'});

                      CustomSnackBar(context,
                          message: 'Status updated to abscond');
                    } catch (e) {
                      print('Error updating status: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to update status')),
                      );
                    }
                  },
                  child: const CustomText(text: 'Abort')),
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
              child: DoctorModuleDrawer(
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
              child: DoctorModuleDrawer(
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: dashboard()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.03,
            right: screenWidth * 0.03,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'IP Prescription',
                        size: screenWidth * .04,
                      ),
                      CustomText(
                        text: 'Waiting Queue',
                        size: screenWidth * .02,
                      ),
                    ],
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
                children: [
                  CustomText(
                    text: 'Dept : General Medicine',
                    size: screenWidth * .015,
                    color: AppColors.blue,
                  ),
                  SizedBox(width: screenWidth * 0.08),
                  CustomText(
                    text: 'Counter A',
                    size: screenWidth * .015,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
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
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  return row['Status'] == 'abscond'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
