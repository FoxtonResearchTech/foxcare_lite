import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/pharmacy_stocks.dart';
import 'package:foxcare_lite/presentation/module/doctor/rx_prescription.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/doctor/doctor_module_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'ip_patients_details.dart';

class DoctorRxList extends StatefulWidget {
  final String doctorName;
  const DoctorRxList({super.key, required this.doctorName});

  @override
  State<DoctorRxList> createState() => _DoctorRxList();
}

class _DoctorRxList extends State<DoctorRxList> {
  final TextEditingController _opNumber = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  int selectedIndex = 1;

  DateTime now = DateTime.now();

  final List<String> headers1 = [
    'Token NO',
    'OP Ticket',
    'OP NO',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action',
    'Abscond',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    print(widget.doctorName);
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

  void onSearchPressed() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }

  Future<void> fetchData({String? opNumber, String? phoneNumber}) async {
    print('Fetching data with OP Number: $opNumber');

    try {
      List<Map<String, dynamic>> fetchedData = [];
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      const int pageSize = 10; // Fetch 10 patients per batch
      DocumentSnapshot? lastDoc;

      bool hasMore = true;

      while (hasMore) {
        Query<Map<String, dynamic>> query =
            FirebaseFirestore.instance.collection('patients').limit(pageSize);
        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final QuerySnapshot<Map<String, dynamic>> patientSnapshot =
            await query.get();
        if (patientSnapshot.docs.isEmpty) {
          break;
        }

        for (var patientDoc in patientSnapshot.docs) {
          final patientId = patientDoc.id;
          final patientData = patientDoc.data();

          final opTicketsSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .collection('opTickets')
              .get();

          for (var opTicketDoc in opTicketsSnapshot.docs) {
            final opTicketData = opTicketDoc.data();

            bool matches = false;
            bool isAbscond = false;
            bool isMedPrescribed = false;
            bool isLabPrescribed = false;
            bool isTestOver = false;

            if (opTicketData['doctorName'] == widget.doctorName &&
                patientData['isIP'] == false) {
              if (opNumber != null &&
                  opTicketData['opTicket'] != null &&
                  opTicketData['opTicket'].toString().trim().toLowerCase() ==
                      opNumber.trim().toLowerCase()) {
                matches = true;
              }
              else if (phoneNumber != null && phoneNumber.isNotEmpty) {
                if (patientData['phone1'] == phoneNumber ||
                    patientData['phone2'] == phoneNumber) {
                  matches = true;
                }
              } else if (opNumber == null &&
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
                  if (tokenData != null) {
                    tokenNo = tokenData['tokenNumber']?.toString() ?? '';
                    tokenDate = tokenData['date'] ?? '';
                  }
                }
              } catch (e) {
                print('Error fetching token for $patientId: $e');
              }

              isAbscond = opTicketData['status'] == 'abscond';
              isLabPrescribed =
                  opTicketData.containsKey('labExaminationPrescribedDate');
              isMedPrescribed =
                  opTicketData.containsKey('medicinePrescribedDate');

              try {
                final testSnapshot = await FirebaseFirestore.instance
                    .collection('patients')
                    .doc(patientId)
                    .collection('opTickets')
                    .doc(opTicketDoc.id)
                    .collection('tests')
                    .get();
                isTestOver = testSnapshot.docs.isNotEmpty;
              } catch (e) {
                print('Error checking tests: $e');
              }

              if (tokenDate == todayString) {
                fetchedData.add({
                  'Token NO': tokenNo,
                  'OP NO': patientData['opNumber'] ?? 'N/A',
                  'OP Ticket': opTicketData['opTicket'] ?? 'N/A',
                  'Name':
                      '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? ''}'
                          .trim(),
                  'Age': patientData['age'] ?? 'N/A',
                  'Place': patientData['city'] ?? 'N/A',
                  'Address': patientData['address1'] ?? 'N/A',
                  'PinCode': patientData['pincode'] ?? 'N/A',
                  'Status': opTicketData['status'] ?? 'N/A',
                  'Primary Info': opTicketData['otherComments'] ?? 'N/A',
                  'isMedPrescribed': isMedPrescribed,
                  'isLabPrescribed': isLabPrescribed,
                  'isTestOver': isTestOver,
                  'Action': TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RxPrescription(
                              tokenNo: tokenNo,
                              patientID: patientData['opNumber'] ?? 'N/A',
                              name:
                                  '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? ''}'
                                      .trim(),
                              date: opTicketData['tokenDate'],
                              age: patientData['age'] ?? 'N/A',
                              place: patientData['state'] ?? 'N/A',
                              address: patientData['address1'] ?? 'N/A',
                              city: patientData['city'] ?? 'N/A',
                              pincode: patientData['pincode'] ?? 'N/A',
                              primaryInfo:
                                  opTicketData['otherComments'] ?? 'N/A',
                              temperature: opTicketData['temperature'] ?? 'N/A',
                              bloodPressure:
                                  opTicketData['bloodPressure'] ?? 'N/A',
                              sugarLevel:
                                  opTicketData['bloodSugarLevel'] ?? 'N/A',
                              counter: opTicketData['counter'] ?? 'N/A',
                              phone1: patientData['phone1'],
                              phone2: patientData['phone2'],
                              sex: patientData['sex'],
                              bloodGroup: patientData['bloodGroup'],
                              firstName: patientData['firstName'],
                              lastName: patientData['lastName'],
                              dob: patientData['dob'],
                              doctorName: widget.doctorName,
                              opTicket: opTicketData['opTicket'],
                              specialization: opTicketData['specialization'],
                            ),
                          ),
                        );
                      },
                      child:
                          CustomText(text: isAbscond ? 'Open' : 'Prescribe')),
                  'Abscond': TextButton(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('patients')
                              .doc(patientId)
                              .collection('opTickets')
                              .doc(opTicketData['opTicket'])
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
              }
            }
          }
        }

        lastDoc = patientSnapshot.docs.last;
        hasMore = patientSnapshot.docs.length == pageSize;
        fetchedData.sort((a, b) {
          int tokenA = int.tryParse(a['Token NO']) ?? 0;
          int tokenB = int.tryParse(b['Token NO']) ?? 0;
          return tokenA.compareTo(tokenB);
        });

        setState(() {
          tableData1 = fetchedData;
        });
        await Future.delayed(const Duration(milliseconds: 100)); // small delay
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  bool isPhoneLoading = false;
  bool isOpLoading = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    bool isMobile = screenWidth < 600;


    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Doctor Dashboard'),
            )
          : null, // No AppBar for web view
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
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300,
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
    final double buttonWidth = screenWidth * 0.08;
    final double buttonHeight = screenHeight * 0.040;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.1,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'OP Prescription',
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: 'OP Ticket Number'),
                      SizedBox(height: 5,),
                      CustomTextField(
                        hintText: '',
                        width: screenWidth * 0.18,
                        controller: _opNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 28,),
                      isOpLoading
                          ? SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: Lottie.asset(
                          'assets/button_loading.json', // Ensure this path is correct
                          fit: BoxFit.contain,
                        ),
                      )
                          : CustomButton(
                        label: 'Search',
                        onPressed: () async {
                          setState(() => isOpLoading = true);
                          await fetchData(opNumber:_opNumber.text);
                          setState(() => isOpLoading = false);
                        },
                        width: buttonWidth,
                        height: buttonHeight,
                      ),
                    ],
                  ),

                  SizedBox(width: screenHeight * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: 'Phone Number'),
                      SizedBox(height: 5,),
                      CustomTextField(
                        hintText: '',
                        width: screenWidth * 0.18,
                        controller: _phoneNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: 28,),
                      isPhoneLoading
                          ? SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: Lottie.asset(
                          'assets/button_loading.json', // Update the path to your Lottie file
                          fit: BoxFit.contain,
                        ),
                      )
                          : CustomButton(
                        label: 'Search',
                        onPressed: () async {
                          setState(() => isPhoneLoading = true);
                          await fetchData(phoneNumber: _phoneNumber.text);
                          setState(() => isPhoneLoading = false);
                        },
                        width: buttonWidth,
                        height: buttonHeight,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                headerColor: Colors.white,
                headerBackgroundColor: const Color(0xFF106ac2),
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  if (row['Status'] == 'abscond') {
                    return Colors.red.shade300; // Strong red to show alert/critical
                  }
                  if (row['isTestOver'] == true) {
                    return Colors.deepOrange.shade200; // Bold warm tone to indicate tests done
                  }
                  if (row['isMedPrescribed'] == true && row['isLabPrescribed'] == true) {
                    return Colors.green.shade300; // Darker green for both tasks done
                  }
                  if (row['isMedPrescribed'] == true) {
                    return Colors.teal.shade300; // Clear teal for medicine prescribed
                  }
                  if (row['isLabPrescribed'] == true) {
                    return Colors.amber.shade400; // Rich amber for lab prescribed
                  }

                  return Colors.grey.shade200; // Slightly darker neutral for default rows
                },


              ),
              SizedBox(height: screenHeight * 0.05)
            ],
          ),
        ),
      ),
    );
  }
}
