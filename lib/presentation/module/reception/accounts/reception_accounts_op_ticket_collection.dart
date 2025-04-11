import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/reception/accounts/reception_accounts_drawer.dart';
import '../../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class ReceptionAccountsOpTicketCollection extends StatefulWidget {
  const ReceptionAccountsOpTicketCollection({super.key});

  @override
  State<ReceptionAccountsOpTicketCollection> createState() =>
      _ReceptionAccountsOpTicketCollection();
}

class _ReceptionAccountsOpTicketCollection
    extends State<ReceptionAccountsOpTicketCollection> {
  int selectedIndex = 1;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  int hoveredIndex = -1;

  DateTime now = DateTime.now();
  final List<String> headers = [
    'OP Ticket',
    'OP No',
    'Name',
    'City',
    'Doctor Name',
    'Total Amount',
    'Collected',
    'Balance',
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (singleDate != null) {
        query = query.where('tokenDate', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('tokenDate', isGreaterThanOrEqualTo: fromDate)
            .where('tokenDate', isLessThanOrEqualTo: toDate);
      }
      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          tableData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('opNumber')) continue;
        if (!data.containsKey('tokenDate')) continue;
        String tokenNo = '';

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
        } catch (e) {
          print('Error fetching token No for patient ${doc.id}: $e');
        }
        double opAmount =
            double.tryParse(data['opTicketTotalAmount']?.toString() ?? '0') ??
                0;
        double opAmountCollected = double.tryParse(
                data['opTicketCollectedAmount']?.toString() ?? '0') ??
            0;
        double balance = opAmount - opAmountCollected;

        fetchedData.add({
          'OP Ticket': tokenNo,
          'OP No': data['opNumber']?.toString() ?? 'N/A',
          'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
              .trim(),
          'City': data['city']?.toString() ?? 'N/A',
          'Doctor Name': data['doctorName']?.toString() ?? 'N/A',
          'Total Amount': data['opTicketTotalAmount']?.toString() ?? '0',
          'Collected': data['opTicketCollectedAmount']?.toString() ?? '0',
          'Balance': balance,
        });
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['OP Ticket'].toString()) ?? 0;
        int tokenB = int.tryParse(b['OP Ticket'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData = fetchedData;
      });
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
          value = int.tryParse(value) ?? 0;
        }
        return sum + (value as int);
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
          value = int.tryParse(value) ?? 0;
        }
        return sum + (value as int);
      },
    );
  }

  int _totalBalance() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Balance'];
        if (value == null) return sum;
        // Convert string to double safely
        if (value is String) {
          value = double.tryParse(value) ?? 0.0;
        }
        // Ensure value is double before conversion to int
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
              title: const Text(
                'Reception Dashboard',
                style: TextStyle(fontFamily: 'SanFrancisco'),
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: ReceptionAccountsDrawer(
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
              child: ReceptionAccountsDrawer(
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
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        height: screenHeight,
        padding: EdgeInsets.only(
          left: screenWidth * 0.01,
          right: screenWidth * 0.01,
          bottom: screenWidth * 0.01,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenWidth * 0.02),
                  child: Column(
                    children: [
                      CustomText(
                        text: "OP Ticket Collection",
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
                  onTap: () => _selectDate(context, _dateController),
                  icon: Icon(Icons.date_range),
                  controller: _dateController,
                  hintText: 'Date',
                  width: screenWidth * 0.15,
                ),
                SizedBox(width: screenHeight * 0.02),
                CustomButton(
                  label: 'Search',
                  onPressed: () {
                    fetchData(singleDate: _dateController.text);
                  },
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.02,
                ),
                SizedBox(width: screenHeight * 0.02),
                CustomText(text: 'OR'),
                SizedBox(width: screenHeight * 0.02),
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
                CustomButton(
                  label: 'Search',
                  onPressed: () {
                    fetchData(
                      fromDate: _fromDateController.text,
                      toDate: _toDateController.text,
                    );
                  },
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.02,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            const Row(
              children: [CustomText(text: 'Collection Report')],
            ),
            SizedBox(height: screenHeight * 0.04),
            CustomDataTable(
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
                  SizedBox(width: screenWidth * 0.38),
                  CustomText(
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
          ],
        ),
      ),
    );
  }
}
