import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'dart:async';

import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'op_billing_entry.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/text/primary_text.dart';

class OpBilling extends StatefulWidget {
  const OpBilling({super.key});

  @override
  State<OpBilling> createState() => _OpBilling();
}

class _OpBilling extends State<OpBilling> {
  final TextEditingController _opNumber = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  bool opNumberSearch = false;
  bool phoneNumberSearch = false;
  final List<String> headers = [
    'Token No',
    'OP Ticket',
    'OP Number',
    'Name',
    'Place',
    'Doctor Name',
    'Specialization',
    'Actions',
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? opNumber,
    String? phoneNumber,
    int batchSize = 10,
  }) async {
    print(
        'Fetching data with OP Number: $opNumber, Phone Number: $phoneNumber');

    try {
      List<Map<String, dynamic>> fetchedData = [];

      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      DocumentSnapshot? lastPatientDoc;

      bool moreData = true;

      while (moreData) {
        Query<Map<String, dynamic>> patientQuery =
            FirebaseFirestore.instance.collection('patients').limit(batchSize);

        if (lastPatientDoc != null) {
          patientQuery = patientQuery.startAfterDocument(lastPatientDoc);
        }

        final QuerySnapshot<Map<String, dynamic>> patientSnapshot =
            await patientQuery.get();

        if (patientSnapshot.docs.isEmpty) {
          moreData = false;
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

          bool found = false;

          for (var opTicketDoc in opTicketsSnapshot.docs) {
            final opTicketData = opTicketDoc.data();
            if (!opTicketData.containsKey('medicinePrescribedDate')) continue;

            // Fix case insensitive matching for opNumber and phoneNumber
            bool matches = false;

            String opTicketOpNumber =
                (opTicketData['opTicket'] ?? '').toString().toLowerCase();

            String? searchOpNumber = opNumber?.toLowerCase();

            if (patientData['isIP'] == false) {
              if (searchOpNumber != null &&
                  opTicketOpNumber == searchOpNumber) {
                matches = true;
              } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
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

              bool isAbscond = opTicketData['status'] == 'abscond';
              bool medicineGiven = opTicketData['medicineGiven'] ?? false;

              // Find latest medicinePrescribedDate in tickets (optional)
              DateTime? latestMedicineDate;

              for (var opTicketDoc in opTicketsSnapshot.docs) {
                final data = opTicketDoc.data();
                if (data['medicinePrescribedDate'] != null) {
                  try {
                    final date = DateTime.parse(data['medicinePrescribedDate']);
                    if (latestMedicineDate == null ||
                        date.isAfter(latestMedicineDate)) {
                      latestMedicineDate = date;
                    }
                  } catch (e) {
                    print(
                        'Invalid date format in medicinePrescribedDate: ${data['medicinePrescribedDate']}');
                  }
                }
              }

              if (opNumber != null ||
                  (phoneNumber != null && phoneNumber.isNotEmpty) ||
                  !medicineGiven) {
                fetchedData.add({
                  'Token No': tokenNo,
                  'OP Number': patientData['opNumber'] ?? 'N/A',
                  'OP Ticket': opTicketData['opTicket'] ?? 'N/A',
                  'Name':
                      '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                          .trim(),
                  'Place': patientData['city'] ?? 'N/A',
                  'Status': opTicketData['status'] ?? 'N/A',
                  'Doctor Name': opTicketData['doctorName'] ?? 'N/A',
                  'Specialization': opTicketData['specialization'] ?? 'N/A',
                  'Medication': opTicketData['Medications'] ?? [],
                  'Actions': Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {
                            final List<Map<String, dynamic>> medications =
                                List<Map<String, dynamic>>.from(
                              opTicketData['prescribedMedicines'] ?? [],
                            );

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (
                              context,
                            ) =>
                                    OpBillingEntry(
                                      patientName:
                                          '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                                              .trim(),
                                      opTicket:
                                          opTicketData['opTicket'] ?? 'N/A',
                                      opNumber:
                                          patientData['opNumber'] ?? 'N/A',
                                      place: patientData['city'] ?? 'N/A',
                                      phone: patientData['phone1'] ?? 'N/A',
                                      doctorName:
                                          opTicketData['doctorName'] ?? 'N/A',
                                      specialization:
                                          opTicketData['specialization'] ??
                                              'N/A',
                                      medications: medications,
                                    )));
                          },
                          child: const CustomText(text: 'Open')),
                      TextButton(
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
                              fetchData();
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
                  )
                });
              }
              found = true;
              break;
            }
          }
        }

        // Update lastPatientDoc for next batch pagination
        lastPatientDoc = patientSnapshot.docs.last;

        // Sort current fetched data by Token No
        fetchedData.sort((a, b) {
          int tokenA = int.tryParse(a['Token No']) ?? 0;
          int tokenB = int.tryParse(b['Token No']) ?? 0;
          return tokenB.compareTo(tokenA);
        });

        // Update UI incrementally after each batch
        setState(() {
          tableData = List.from(fetchedData);
        });

        // Add a small delay between batches to avoid rate limiting (optional)
        await Future.delayed(const Duration(milliseconds: 100));

        // If less than batch size docs returned, no more data
        if (patientSnapshot.docs.length < batchSize) {
          moreData = false;
        }
      }
    } catch (e) {
      print('Error fetching data paginated: $e');
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
  }

  @override
  void dispose() {
    _opNumber.dispose();
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
              TimeDateWidget(text: 'OP Billings'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'OP Ticket Number',
                        size: screenWidth * 0.011,
                      ),
                      SizedBox(height: screenWidth * 0.007),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.15,
                        controller: _opNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      opNumberSearch
                          ? SizedBox(
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/button_loading.json',
                                ),
                              ),
                            )
                          : PharmacyButton(
                              label: 'Search',
                              onPressed: () async {
                                setState(() => opNumberSearch = true);
                                await fetchData(opNumber: _opNumber.text);
                                setState(() => opNumberSearch = false);

                                onSearchPressed();
                              },
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.025,
                            ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Phone Number',
                        size: screenWidth * 0.011,
                      ),
                      SizedBox(height: screenWidth * 0.007),
                      PharmacyTextField(
                        hintText: 'Phone Number',
                        width: screenWidth * 0.15,
                        controller: _phoneNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      phoneNumberSearch
                          ? SizedBox(
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/button_loading.json',
                                ),
                              ),
                            )
                          : PharmacyButton(
                              label: 'Search',
                              onPressed: () async {
                                setState(() => phoneNumberSearch = true);
                                await fetchData(phoneNumber: _phoneNumber.text);
                                setState(() => phoneNumberSearch = false);

                                onSearchPressed();
                              },
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.025,
                            ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              LazyDataTable(
                headers: headers,
                tableData: tableData,
                rowColorResolver: (row) {
                  if (row['Status'] == 'abscond') {
                    return Colors.red.shade300;
                  }

                  return Colors.transparent;
                },
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
