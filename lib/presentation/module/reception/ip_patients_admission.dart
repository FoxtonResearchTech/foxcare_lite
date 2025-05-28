import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/op_counters.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/presentation/module/reception/reception_ip_patient.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
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
  bool isFetchDataLoading = false;
  final List<String> headers1 = [
    'IP Ticket',
    'OP NO',
    'IP Admit Date',
    'Status',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  int selectedIndex = 3;

  Timer? _timer;

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

  Future<void> fetchData({
    String? ipNumber,
    String? phoneNumber,
    int pageSize = 20,
    Duration delayBetweenPages = const Duration(milliseconds: 100),
  }) async {
    print('Fetching data with IP Number: $ipNumber');

    DocumentSnapshot? lastPatientDoc; // for paging
    List<Map<String, dynamic>> allFetchedData = [];
    final patientsCollection =
        FirebaseFirestore.instance.collection('patients');

    try {
      while (true) {
        Query<Map<String, dynamic>> query = patientsCollection.limit(pageSize);
        if (lastPatientDoc != null) {
          query = query.startAfterDocument(lastPatientDoc);
        }

        final patientSnapshot = await query.get();

        if (patientSnapshot.docs.isEmpty) {
          // No more patients to fetch
          break;
        }

        for (var patientDoc in patientSnapshot.docs) {
          final patientId = patientDoc.id;
          final patientData = patientDoc.data();

          Query ipTicketsQuery =
              patientsCollection.doc(patientId).collection('ipTickets');
          final ipTicketsSnapshot = await ipTicketsQuery.get();

          for (var ipTicketDoc in ipTicketsSnapshot.docs) {
            final ipTicketData = ipTicketDoc.data() as Map<String, dynamic>;

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

              try {
                final tokenSnapshot = await patientsCollection
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

              allFetchedData.add({
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
                'Primary Info': patientData['otherComments'] ?? 'N/A',
                'Action': TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceptionIpPatient(
                          date: ipTicketData['ipAdmitDate'] ?? 'N/A',
                          patientID: patientData['opNumber'] ?? 'N/A',
                          ipNumber: ipTicketData['ipTicket'] ?? 'N/A',
                          name:
                              '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? 'N/A'}'
                                  .trim(),
                          age: patientData['age'] ?? 'N/A',
                          place: patientData['state'] ?? 'N/A',
                          address: patientData['address1'] ?? 'N/A',
                          pincode: patientData['pincode'] ?? 'N/A',
                          primaryInfo: ipTicketData['otherComments'] ?? 'N/A',
                          temperature: ipTicketData['temperature'] ?? 'N/A',
                          bloodPressure: ipTicketData['bloodPressure'] ?? 'N/A',
                          sugarLevel: ipTicketData['bloodSugarLevel'] ?? 'N/A',
                        ),
                      ),
                    );
                  },
                  child: const CustomText(text: 'IP Rooms'),
                ),
                'Abscond': TextButton(
                    onPressed: () async {
                      try {
                        await patientsCollection
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

              break; // one matching ipTicket per patient only
            }
          }
        }

        lastPatientDoc = patientSnapshot.docs.last;

        setState(() {
          tableData1 = List.from(allFetchedData);
        });

        // Optional small delay to ease UI update / avoid rate limits
        await Future.delayed(delayBetweenPages);
      }

      print('Finished fetching total: ${allFetchedData.length}');
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
                    isFetchDataLoading
                        ? Container(
                            width: 200,
                            height: 200,
                            child: Lottie.asset('assets/tableLoading.json'))
                        : LazyDataTable(
                            headerBackgroundColor: AppColors.blue,
                            headerColor: Colors.white,
                            tableData: tableData1,
                            headers: headers1,
                            rowColorResolver: (row) {
                              return row['Status'] == 'abscond'
                                  ? Colors.red.shade200
                                  : Colors.transparent;
                            },
                          ),
                    SizedBox(height: screenHeight * 0.05),
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
