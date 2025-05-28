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

class LabAccounts extends StatefulWidget {
  const LabAccounts({super.key});

  @override
  State<LabAccounts> createState() => _LabAccountsState();
}

class _LabAccountsState extends State<LabAccounts> {
  int selectedIndex = 3;

  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();

  final List<String> headers = [
    'Report Date',
    'Report No',
    'Name',
    'OP Number',
    'OP Ticket',
    'Total Amount',
    'Collected',
    'Balance',
  ];
  bool isLoading = false;
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? fromDate,
    String? toDate,
    int pageSize = 20,
  }) async {
    try {
      Query query =
          FirebaseFirestore.instance.collection('patients').limit(pageSize);
      DocumentSnapshot? lastPatientDoc;
      bool hasMore = true;

      List<Map<String, dynamic>> allFetchedData = [];

      while (hasMore) {
        if (lastPatientDoc != null) {
          query = query.startAfterDocument(lastPatientDoc);
        }

        final patientsSnapshot = await query.get();

        if (patientsSnapshot.docs.isEmpty) {
          print("No more patient records found");
          break;
        }

        for (var patientDoc in patientsSnapshot.docs) {
          final patientData = patientDoc.data() as Map<String, dynamic>;

          final opTicketsSnapshot =
              await patientDoc.reference.collection('opTickets').get();

          for (var ticketDoc in opTicketsSnapshot.docs) {
            final ticketData = ticketDoc.data();
            if (!ticketData.containsKey('reportNo') ||
                !ticketData.containsKey('reportDate')) continue;

            final reportDate = ticketData['reportDate']?.toString();

            if (fromDate != null &&
                toDate != null &&
                (reportDate == null ||
                    reportDate.compareTo(fromDate) < 0 ||
                    reportDate.compareTo(toDate) > 0)) {
              continue;
            }

            allFetchedData.add({
              'Report Date': reportDate ?? 'N/A',
              'Report No': ticketData['reportNo']?.toString() ?? 'N/A',
              'Name':
                  '${patientData['firstName'] ?? 'N/A'} ${patientData['lastName'] ?? 'N/A'}'
                      .trim(),
              'OP Ticket': ticketData['opTicket']?.toString() ?? 'N/A',
              'OP Number': patientData['opNumber']?.toString() ?? 'N/A',
              'Total Amount': ticketData['labTotalAmount']?.toString() ?? '0',
              'Collected': ticketData['labCollected']?.toString() ?? '0',
              'Balance': ticketData['labBalance']?.toString() ?? '0',
            });
          }
        }

        // Update lastPatientDoc for next page
        lastPatientDoc = patientsSnapshot.docs.last;

        // If fewer docs returned than pageSize, this is the last page
        if (patientsSnapshot.docs.length < pageSize) {
          hasMore = false;
        }

        // Sort the data by Report No
        allFetchedData.sort((a, b) {
          int aNo = int.tryParse(a['Report No'].toString()) ?? 0;
          int bNo = int.tryParse(b['Report No'].toString()) ?? 0;
          return aNo.compareTo(bNo);
        });

        // Update UI after each batch
        setState(() {
          tableData = List.from(allFetchedData);
        });

        // Optional: small delay to throttle UI updates
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error fetching data: $e');
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
                          text: " OP Ticket Accounts",
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
              SizedBox(height: screenHeight * 0.04),
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
