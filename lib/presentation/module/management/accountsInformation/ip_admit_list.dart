import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class IpAdmitList extends StatefulWidget {
  @override
  State<IpAdmitList> createState() => _IpAdmitList();
}

class _IpAdmitList extends State<IpAdmitList> {
  final dateTime = DateTime.now();

  int selectedIndex = 10;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  TextEditingController _ipNumber = TextEditingController();

  TextEditingController amount = TextEditingController();
  TextEditingController collected = TextEditingController();
  TextEditingController balanceAmount = TextEditingController();
  bool isLoading = false;
  bool isIPLoading = false;
  DateTime now = DateTime.now();
  final List<String> headers = [
    'IP Ticket',
    'OP No',
    'IP Admission Date',
    'Room Allotment Date',
    'Name',
    'City',
    'Doctor Name',
    'Total Amount',
    'Collected',
    'Balance',
  ];
  List<Map<String, dynamic>> tableData = [];

  void _updateBalance() {
    double totalAmount = double.tryParse(amount.text) ?? 0.0;
    double paidAmount = double.tryParse(collected.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceAmount.text = balance.toStringAsFixed(2);
  }

  Future<void> fetchData({
    String? ipNumber,
    String? singleDate,
    String? fromDate,
    String? toDate,
    int pageSize = 20,
  }) async {
    try {
      DocumentSnapshot? lastPatientDoc;
      bool hasMore = true;
      List<Map<String, dynamic>> fetchedData = [];

      final ipNumberLower = ipNumber?.toLowerCase();

      while (hasMore) {
        Query query =
            FirebaseFirestore.instance.collection('patients').limit(pageSize);

        if (lastPatientDoc != null) {
          query = query.startAfterDocument(lastPatientDoc);
        }

        final patientQuerySnapshot = await query.get();

        if (patientQuerySnapshot.docs.isEmpty) {
          // No more docs
          break;
        }

        for (var doc in patientQuerySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          final ipTicketsSnapshot = await doc.reference
              .collection('ipTickets')
              .where('discharged', isEqualTo: false)
              .get();

          for (var ipTicketDoc in ipTicketsSnapshot.docs) {
            final ipData = ipTicketDoc.data();
            final String? roomAllotmentDateStr =
                ipData['roomAllotmentDate']?.toString();

            bool match = true;

            if ((ipNumber != null && ipNumber.isNotEmpty) ||
                (singleDate != null && singleDate.isNotEmpty) ||
                (fromDate != null &&
                    fromDate.isNotEmpty &&
                    toDate != null &&
                    toDate.isNotEmpty)) {
              match = false;

              // Case-insensitive ipTicket check
              if (ipNumber != null &&
                  ipNumber.isNotEmpty &&
                  ipData['ipTicket'].toString().toLowerCase() ==
                      ipNumberLower) {
                match = true;
              } else if (singleDate != null &&
                  singleDate.isNotEmpty &&
                  roomAllotmentDateStr == singleDate) {
                match = true;
              } else if (fromDate != null &&
                  fromDate.isNotEmpty &&
                  toDate != null &&
                  toDate.isNotEmpty &&
                  roomAllotmentDateStr != null &&
                  roomAllotmentDateStr.compareTo(fromDate) >= 0 &&
                  roomAllotmentDateStr.compareTo(toDate) <= 0) {
                match = true;
              }
            }

            if (!match) continue;

            // Fetch admission payments details doc for this ipTicket
            final detailsDoc = await doc.reference
                .collection('ipAdmissionPayments')
                .doc('payments${ipData['ipTicket'].toString()}')
                .get();

            Map<String, dynamic>? detailsData =
                detailsDoc.exists ? detailsDoc.data() : null;

            double ipAdmissionTotalAmount = double.tryParse(
                    detailsData?['ipAdmissionTotalAmount'] ?? '0') ??
                0;
            double ipAdmissionCollected =
                double.tryParse(detailsData?['ipAdmissionCollected'] ?? '0') ??
                    0;
            double balance = ipAdmissionTotalAmount - ipAdmissionCollected;

            fetchedData.add({
              'IP Ticket': ipData['ipTicket']?.toString() ?? '',
              'OP No': data['opNumber']?.toString() ?? 'N/A',
              'IP Admission Date': ipData['ipAdmitDate']?.toString() ?? '',
              'Room Allotment Date': roomAllotmentDateStr ?? '',
              'Name':
                  '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                      .trim(),
              'City': data['city']?.toString() ?? 'N/A',
              'Doctor Name': ipData['doctorName']?.toString() ?? '',
              'Total Amount': ipAdmissionTotalAmount.toStringAsFixed(2),
              'Collected': ipAdmissionCollected.toStringAsFixed(2),
              'Balance': balance.toStringAsFixed(2),
            });
          }
        }

        lastPatientDoc = patientQuerySnapshot.docs.last;

        // Sort by IP Ticket number (integer)
        fetchedData.sort((a, b) {
          int tokenA = int.tryParse(a['IP Ticket'].toString()) ?? 0;
          int tokenB = int.tryParse(b['IP Ticket'].toString()) ?? 0;
          return tokenA.compareTo(tokenB);
        });

        // Update UI incrementally
        setState(() {
          tableData = List.from(fetchedData);
        });

        if (patientQuerySnapshot.docs.length < pageSize) {
          hasMore = false;
        } else {
          // Delay before loading next page
          await Future.delayed(const Duration(milliseconds: 100));
        }
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

  int _totalAmountCollected() {
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
          value = double.tryParse(value) ?? 0.0;
        }
        if (value is double) {
          value = value.toInt();
        }
        return sum + (value as int);
      },
    );
  }

  @override
  void initState() {
    fetchData();
    _totalAmountCollected();
    _totalCollected();
    _totalBalance();
    amount.addListener(_updateBalance);
    collected.addListener(_updateBalance);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
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
              title: const CustomText(
                text: 'Accounts Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementAccountsDrawer(
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
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ManagementAccountsDrawer(
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
              padding: const EdgeInsets.only(left: 16, right: 16),
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
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "IP Admit List",
                          size: screenWidth * .025,
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
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'IP Number',
                        size: screenWidth * 0.0125,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        hintText: '',
                        width: screenWidth * 0.15,
                        controller: _ipNumber,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      isIPLoading
                          ? SizedBox(
                              width: screenWidth * 0.09,
                              height: screenWidth * 0.025,
                              child: Lottie.asset(
                                'assets/button_loading.json', // Ensure the file path is correct
                                fit: BoxFit.contain,
                              ),
                            )
                          : CustomButton(
                              label: 'Search',
                              onPressed: () async {
                                setState(() => isIPLoading = true);
                                await fetchData(ipNumber: _ipNumber.text);
                                setState(() => isIPLoading = false);
                              },
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.025,
                            ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                children: [
                  // CustomTextField(
                  //   onTap: () {
                  //     _selectDate(context, _dateController);
                  //     _fromDateController.clear();
                  //     _toDateController.clear();
                  //   },
                  //   icon: Icon(Icons.date_range),
                  //   controller: _dateController,
                  //   hintText: 'Date',
                  //   width: screenWidth * 0.15,
                  // ),
                  // SizedBox(width: screenHeight * 0.02),
                  // CustomButton(
                  //   label: 'Search',
                  //   onPressed: () {
                  //     fetchData(singleDate: _dateController.text);
                  //   },
                  //   width: screenWidth * 0.08,
                  //   height: screenWidth * 0.02,
                  // ),
                  // SizedBox(width: screenHeight * 0.02),
                  // CustomText(text: 'OR'),
                  // SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () {
                      _selectDate(context, _fromDateController);
                      _dateController.clear();
                    },
                    icon: const Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () {
                      _selectDate(context, _toDateController);
                      _dateController.clear();
                    },
                    icon: const Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  isLoading
                      ? SizedBox(
                          width: screenWidth * 0.09,
                          height: screenWidth * 0.03,
                          child: Lottie.asset(
                            'assets/button_loading.json', // Ensure the file path is correct
                            fit: BoxFit.contain,
                          ),
                        )
                      : CustomButton(
                          label: 'Search',
                          onPressed: () async {
                            setState(() => isLoading = true);

                            await fetchData(
                              fromDate: _fromDateController.text,
                              toDate: _toDateController.text,
                            );
                            setState(() => isLoading = false);
                          },
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.025,
                        ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  if (_dateController.text.isEmpty &&
                      _fromDateController.text.isEmpty &&
                      _toDateController.text.isEmpty)
                    const CustomText(text: 'Collection Report Of Date ')
                  else if (_dateController.text.isNotEmpty)
                    CustomText(
                        text:
                            'Collection Report Of Date : ${_dateController.text} ')
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
                columnWidths: {
                  2: FixedColumnWidth(screenWidth * 0.1),
                  3: FixedColumnWidth(screenWidth * 0.1),
                  6: FixedColumnWidth(screenWidth * 0.07),
                  7: FixedColumnWidth(screenWidth * 0.07),
                },
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
                    SizedBox(width: screenWidth * 0.38),
                    const CustomText(
                      text: 'Total : ',
                    ),
                    SizedBox(width: screenWidth * 0.086),
                    CustomText(
                      text: '${_totalAmountCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.08),
                    CustomText(
                      text: '${_totalCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.083),
                    CustomText(
                      text: '${_totalBalance()}',
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
