import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/pharmacy/billings/ip_billing_entry.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'dart:async';

import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';

import 'package:intl/intl.dart';
import 'op_billing_entry.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class IpBilling extends StatefulWidget {
  const IpBilling({super.key});

  @override
  State<IpBilling> createState() => _IpBilling();
}

class _IpBilling extends State<IpBilling> {
  final TextEditingController _ipTicket = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();

  final List<String> headers = [
    'Token No',
    'IP Ticket',
    'OP Number',
    'Name',
    'Place',
    'Doctor Name',
    'Specialization',
    'Actions',
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({String? ipNumber, String? phoneNumber}) async {
    print('Fetching data with IP Number: $ipNumber');

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

          bool isSearching = (ipNumber != null && ipNumber.isNotEmpty) ||
              (phoneNumber != null && phoneNumber.isNotEmpty);

          if (isSearching) {
            if (ipNumber != null && ipTicketData['ipTicket'] == ipNumber) {
              matches = true;
            } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
              if (patientData['phone1'] == phoneNumber ||
                  patientData['phone2'] == phoneNumber) {
                matches = true;
              }
            }
          } else {
            if (patientData['isIP'] == true &&
                ipTicketData['discharged'] != true) {
              matches = true;
            }
          }

          if (matches) {
            String tokenNo = '';
            String tokenDate = '';
            List<Map<String, dynamic>> todayPrescribedMedicines = [];

            try {
              final prescribedSnapshot = await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(patientId)
                  .collection('ipTickets')
                  .doc(ipTicketData['ipTicket'])
                  .collection('prescribedMedicines')
                  .get();

              for (var doc in prescribedSnapshot.docs) {
                final data = doc.data();
                if (data['date'] == todayString && data.containsKey('items')) {
                  todayPrescribedMedicines.add({
                    'docId': doc.id,
                    'items': data['items'],
                    'medicineGiven': data['medicineGiven'] ?? false,
                  });
                }
              }
            } catch (e) {
              print('Error fetching prescribed medicines: $e');
            }

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
            if ((ipNumber == null || ipNumber.isEmpty) &&
                (phoneNumber == null || phoneNumber.isEmpty) &&
                ipTicketData['discharged'] == true) {
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
              'Token No': tokenNo,
              'OP Number': patientData['opNumber'] ?? 'N/A',
              'IP Ticket': ipTicketData['ipTicket'] ?? 'N/A',
              'Name':
                  '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                      .trim(),
              'Place': patientData['city'] ?? 'N/A',
              'Doctor Name': ipTicketData['doctorName'] ?? 'N/A',
              'Specialization': ipTicketData['specialization'] ?? 'N/A',
              'Actions': Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IpBillingEntry(
                              medications: todayPrescribedMedicines,
                              opNumber: patientData['opNumber'] ?? 'N/A',
                              patientName:
                                  '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? 'N/A'}'
                                      .trim(),
                              roomWard: detailsData?['ipAdmission']
                                              ?['roomType'] !=
                                          null &&
                                      detailsData?['ipAdmission']
                                              ?['roomNumber'] !=
                                          null
                                  ? "${detailsData!['ipAdmission']['roomType']} ${detailsData['ipAdmission']['roomNumber']}"
                                  : 'N/A',
                              place: patientData['city'] ?? 'N/A',
                              phone: patientData['phone1'],
                              ipTicket: ipTicketData['ipTicket'],
                              doctorName: ipTicketData['doctorName'],
                              specialization: ipTicketData['specialization'],
                            ),
                          ),
                        );
                      },
                      child: const CustomText(text: 'Open')),
                  TextButton(
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
                ],
              ),
            });

            found = true;
            break;
          }
        }
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token No']) ?? 0;
        int tokenB = int.tryParse(b['Token No']) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  late Timer? _timer;

  void onSearchPressed() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _ipTicket.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              TimeDateWidget(text: 'IP Billings'),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PharmacyTextField(
                    hintText: 'IP Ticket Number',
                    width: screenWidth * 0.15,
                    controller: _ipTicket,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(ipNumber: _ipTicket.text);
                      onSearchPressed();
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  PharmacyTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.15,
                    controller: _phoneNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  PharmacyButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(phoneNumber: _phoneNumber.text);
                      onSearchPressed();
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomDataTable(
                headers: headers,
                tableData: tableData,
                rowColorResolver: (row) {
                  if (row['Status'] == 'abscond') {
                    return Colors.red.shade200;
                  }

                  return Colors.transparent;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
