import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/lab/patients_lab_details.dart';
import 'package:foxcare_lite/presentation/module/lab/reports_search.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/lab/lab_module_drawer.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'dashboard.dart';
import 'lab_testqueue.dart';

class IpLabAccounts extends StatefulWidget {
  const IpLabAccounts({super.key});

  @override
  State<IpLabAccounts> createState() => _IpLabAccounts();
}

class _IpLabAccounts extends State<IpLabAccounts> {
  int selectedIndex = 5;

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  final List<String> headers = [
    'Report Date',
    'Report No',
    'OP Number',
    'IP Ticket',
    'Name',
    'Total Amount',
    'Collected',
    'Balance',
  ];
  bool isLoading = false;
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      List<Map<String, dynamic>> fetchedData = [];
      DocumentSnapshot? lastPatientDoc;
      const int batchSize = 15; // Adjust as needed

      while (true) {
        Query query =
            FirebaseFirestore.instance.collection('patients').limit(batchSize);
        if (lastPatientDoc != null) {
          query = query.startAfterDocument(lastPatientDoc);
        }

        final QuerySnapshot patientsSnapshot = await query.get();

        if (patientsSnapshot.docs.isEmpty) {
          // No more patients to fetch, break the loop
          break;
        }

        for (var patientDoc in patientsSnapshot.docs) {
          final patientData = patientDoc.data() as Map<String, dynamic>;

          final ipTicketsSnapshot =
              await patientDoc.reference.collection('ipTickets').get();

          for (var ticketDoc in ipTicketsSnapshot.docs) {
            final ticketData = ticketDoc.data();
            final ticketId = ticketDoc.id;

            final examSnapshot = await patientDoc.reference
                .collection('ipTickets')
                .doc(ticketId)
                .collection('Examination')
                .get();

            for (var examDoc in examSnapshot.docs) {
              final examData = examDoc.data();

              if (!examData.containsKey('reportNo') ||
                  !examData.containsKey('reportDate')) continue;

              final String reportDate = examData['reportDate'].toString();

              // Filter by date range if provided
              if (fromDate != null &&
                  toDate != null &&
                  (reportDate.compareTo(fromDate) < 0 ||
                      reportDate.compareTo(toDate) > 0)) {
                continue;
              }

              fetchedData.add({
                'Report Date': reportDate,
                'Report No': examData['reportNo']?.toString() ?? 'N/A',
                'Name':
                    '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                        .trim(),
                'IP Ticket': ticketData['ipTicket']?.toString() ?? 'N/A',
                'OP Number': patientData['opNumber']?.toString() ?? 'N/A',
                'Total Amount': examData['labTotalAmount']?.toString() ?? '0',
                'Collected': examData['labCollected']?.toString() ?? '0',
                'Balance': examData['labBalance']?.toString() ?? '0',
              });
            }
          }
        }

        // Update last document to paginate in next loop iteration
        lastPatientDoc = patientsSnapshot.docs.last;
        // Sort by report number ascending
        fetchedData.sort((a, b) {
          int aNo = int.tryParse(a['Report No'].toString()) ?? 0;
          int bNo = int.tryParse(b['Report No'].toString()) ?? 0;
          return aNo.compareTo(bNo);
        });

        setState(() {
          tableData = List.from(fetchedData);
        });
        // Small delay to avoid Firestore rate limits and keep UI responsive
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error fetching IP ticket data: $e');
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  int _totalTotalAmount() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Total Amount'];
        if (value == null) return sum;

        if (value is String) {
          return sum + (double.tryParse(value)?.toInt() ?? 0);
        } else if (value is num) {
          return sum + value.toInt();
        }

        return sum;
      },
    );
  }

  int _totalCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Collected'];
        if (value == null) return sum;

        if (value is String) {
          return sum + (double.tryParse(value)?.toInt() ?? 0);
        } else if (value is num) {
          return sum + value.toInt();
        }

        return sum;
      },
    );
  }

  int _totalBalance() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Balance'];
        if (value == null) return sum;

        if (value is String) {
          return sum + (double.tryParse(value)?.toInt() ?? 0);
        } else if (value is num) {
          return sum + value.toInt();
        }

        return sum;
      },
    );
  }

  @override
  void initState() {
    fetchData();
    _totalTotalAmount();
    _totalCollected();
    _totalBalance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Laboratory Dashboard'),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: LabModuleDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300,
              color: Colors.blue.shade100,
              child: LabModuleDrawer(
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
              padding: const EdgeInsets.all(16.0),
              child: dashboard(),
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
            top: screenHeight * 0.01,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.01),
                    child: Column(
                      children: [
                        CustomText(
                          text: " IP Ticket Accounts",
                          size: screenWidth * 0.03,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      image: const DecorationImage(
                        image: AssetImage('assets/foxcare_lite_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Row(
                    children: [
                      isLoading
                          ? Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: Lottie.asset(
                                  'assets/button_loading.json', // replace with your actual path
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          : CustomButton(
                              label: 'Search',
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });

                                fetchData(
                                  fromDate: _fromDateController.text,
                                  toDate: _toDateController.text,
                                ).then((_) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.045,
                            ),
                    ],
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_fromDateController.text.isEmpty &&
                      _toDateController.text.isEmpty)
                    const CustomText(text: 'Collection Report Of Date ')
                  else if (_fromDateController.text.isNotEmpty &&
                      _toDateController.text.isNotEmpty)
                    CustomText(
                        text:
                            'Collection Report Of Date : ${_fromDateController.text} To ${_toDateController.text}')
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: screenWidth * 0.35),
                    CustomText(
                      text: 'Total : ',
                    ),
                    SizedBox(width: screenWidth * 0.06),
                    CustomText(
                      text: '${_totalTotalAmount()}',
                    ),
                    SizedBox(width: screenWidth * 0.075),
                    CustomText(
                      text: '${_totalCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.08),
                    CustomText(
                      text: '${_totalBalance()}',
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05)
            ],
          ),
        ),
      ),
    );
  }
}
