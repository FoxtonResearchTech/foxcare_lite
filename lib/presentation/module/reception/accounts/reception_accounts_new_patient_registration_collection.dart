import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/reception/accounts/reception_accounts_drawer.dart';
import '../../../../utilities/widgets/drawer/reception/reception_drawer.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class ReceptionAccountsNewPatientRegistrationCollection extends StatefulWidget {
  const ReceptionAccountsNewPatientRegistrationCollection({super.key});

  @override
  State<ReceptionAccountsNewPatientRegistrationCollection> createState() =>
      _ReceptionAccountsNewPatientRegistrationCollection();
}

class _ReceptionAccountsNewPatientRegistrationCollection
    extends State<ReceptionAccountsNewPatientRegistrationCollection> {
  int selectedIndex = 0;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  bool isLoading = false;

  DateTime now = DateTime.now();
  final List<String> headers = [
    'OP No',
    'Name',
    'City',
    'Total Amount',
    'Collected',
    'Balance',
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
    int pageSize = 20,
    Duration delayBetweenPages = const Duration(milliseconds: 100),
  }) async {
    try {
      DocumentSnapshot? lastDoc;
      List<Map<String, dynamic>> allFetchedData = [];

      while (true) {
        Query query = FirebaseFirestore.instance.collection('patients');

        if (singleDate != null) {
          query = query.where('opAdmissionDate', isEqualTo: singleDate);
          query = query.orderBy('opAdmissionDate');
        } else if (fromDate != null && toDate != null) {
          query = query
              .where('opAdmissionDate', isGreaterThanOrEqualTo: fromDate)
              .where('opAdmissionDate', isLessThanOrEqualTo: toDate)
              .orderBy('opAdmissionDate');
        } else {
          query = query;
        }

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        query = query.limit(pageSize);

        final QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          print("No more patient records found");
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (!data.containsKey('opNumber') ||
              !data.containsKey('opAdmissionDate')) {
            continue;
          }

          double opAmount =
              double.tryParse(data['opAmount']?.toString() ?? '0') ?? 0;
          double opAmountCollected =
              double.tryParse(data['opAmountCollected']?.toString() ?? '0') ??
                  0;
          double balance = opAmount - opAmountCollected;

          allFetchedData.add({
            'OP No': data['opNumber']?.toString() ?? 'N/A',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'City': data['city']?.toString() ?? 'N/A',
            'Total Amount': data['opAmount']?.toString() ?? '0',
            'Collected': data['opAmountCollected']?.toString() ?? '0',
            'Balance': balance,
          });
        }

        lastDoc = snapshot.docs.last;

        setState(() {
          tableData = List.from(allFetchedData);
        });

        // If fewer docs than pageSize, we reached the last page
        if (snapshot.docs.length < pageSize) {
          break;
        }

        await Future.delayed(delayBetweenPages);
      }
    } catch (e) {
      print('Error fetching patient data: $e');
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
            child: dashboard(),
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
        padding: EdgeInsets.only(
          left: screenWidth * 0.01,
          right: screenWidth * 0.02,
          bottom: screenWidth * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                        text: "New Patient Registration Collection",
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
                /*
                CustomTextField(
                  onTap: () {
                    _selectDate(context, _dateController);
                    _fromDateController.clear();
                    _toDateController.clear();
                  },
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
                 */
                CustomTextField(
                  onTap: () {
                    _selectDate(context, _fromDateController);
                    _dateController.clear();
                  },
                  icon: Icon(Icons.date_range),
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
                  icon: Icon(Icons.date_range),
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
                  width: screenWidth * 0.09,
                  height: screenWidth * 0.03,
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
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}
