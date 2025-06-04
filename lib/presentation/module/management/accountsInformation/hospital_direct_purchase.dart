import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/constants.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class HospitalDirectPurchase extends StatefulWidget {
  @override
  State<HospitalDirectPurchase> createState() => _HospitalDirectPurchase();
}

class _HospitalDirectPurchase extends State<HospitalDirectPurchase> {
  int selectedIndex = 4;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  bool isLoading = false;
  //ADD BILL
  TextEditingController purchaseDate = TextEditingController();
  TextEditingController billNo = TextEditingController();
  TextEditingController fromParty = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController description = TextEditingController();

  TextEditingController payedDate = TextEditingController();

  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController collectedAmountController =
      TextEditingController();
  final TextEditingController currentlyPayingAmount = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController paymentDetails = TextEditingController();
  String? selectedPaymentMode;
  double _originalCollected = 0.0;
  final dateTime = DateTime.now();
  DateTime now = DateTime.now();
  final List<String> headers = [
    'Purchase Date',
    'Bill NO',
    'From Party',
    'Phone',
    'City',
    'Description',
    'Amount',
    'Collected',
    'Balance',
    'Transactions',
  ];
  List<Map<String, dynamic>> tableData = [];

  final List<String> historyHeaders = [
    'Payment Mode',
    'Payment Details',
    'Payed Date',
    'Payed Time',
    'Collected',
    'Balance',
  ];
  List<Map<String, dynamic>> historyTableData = [];

  Future<void> addBill() async {
    if (purchaseDate.text.isEmpty || payedDate.text.isEmpty) {
      CustomSnackBar(context,
          message: 'Please Enter Bill Date', backgroundColor: Colors.orange);
      return;
    }

    try {
      Map<String, dynamic> billData = {
        'purchaseDate': purchaseDate.text,
        'billNo': billNo.text,
        'fromParty': fromParty.text,
        'phone': phone.text,
        'city': city.text,
        'description': description.text,
        'amount': totalAmountController.text,
        'collected': collectedAmountController.text,
        'balance': balanceController.text,
        'payedDate': payedDate.text,
      };

      DocumentReference billRef = FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('directPurchase')
          .doc();

      await billRef.set(billData);

      await billRef.collection('payments').add({
        'collected': collectedAmountController.text,
        'balance': balanceController.text,
        'paymentMode': selectedPaymentMode,
        'paymentDetails': paymentDetails.text,
        'payedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'payedTime': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      });

      clear();
      CustomSnackBar(context,
          message: 'Bill Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Bill', backgroundColor: Colors.red);
    }
  }

  Future<void> historyData({required String docId}) async {
    try {
      DocumentReference patientDoc = FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('directPurchase')
          .doc(docId);

      QuerySnapshot snapshot = await patientDoc.collection('payments').get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          historyTableData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        fetchedData.add({
          'Payment Mode': data['paymentMode']?.toString() ?? 'N/A',
          'Payment Details': data['paymentDetails']?.toString() ?? 'N/A',
          'Payed Date': data['payedDate']?.toString() ?? 'N/A',
          'Payed Time': data['payedTime']?.toString() ?? 'N/A',
          'Collected': data['collected']?.toString() ?? 'N/A',
          'Balance': data['balance']?.toString() ?? 'N/A',
        });
      }

      fetchedData.sort((a, b) {
        String formatTime(String time) {
          List<String> parts = time.split(':');
          String hour = parts[0].padLeft(2, '0');
          String minute = parts.length > 1 ? parts[1] : '00';
          return '$hour:$minute';
        }

        String dateTimeStrA =
            '${a['Payed Date']} ${formatTime(a['Payed Time'])}';
        String dateTimeStrB =
            '${b['Payed Date']} ${formatTime(b['Payed Time'])}';

        DateTime dateTimeA = DateTime.tryParse(dateTimeStrA) ?? DateTime(0);
        DateTime dateTimeB = DateTime.tryParse(dateTimeStrB) ?? DateTime(0);

        return dateTimeA.compareTo(dateTimeB);
      });

      setState(() {
        historyTableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      List<Map<String, dynamic>> fetchedData = [];
      DocumentSnapshot? lastDoc;
      const int batchSize = 20;

      while (true) {
        Query query = FirebaseFirestore.instance
            .collection('hospital')
            .doc('purchase')
            .collection('directPurchase')
            .limit(batchSize);

        // Apply filters
        if (singleDate != null) {
          query = query.where('purchaseDate', isEqualTo: singleDate);
          // query = query.orderBy('purchaseDate');
        } else if (fromDate != null && toDate != null) {
          query = query
              .where('purchaseDate', isGreaterThanOrEqualTo: fromDate)
              .where('purchaseDate', isLessThanOrEqualTo: toDate)
              .orderBy('purchaseDate');
        }

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          // No more data to fetch
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('billNo')) continue;
          if (!data.containsKey('purchaseDate')) continue;

          double opAmount =
              double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
          double opAmountCollected =
              double.tryParse(data['collected']?.toString() ?? '0') ?? 0;
          double balance = opAmount - opAmountCollected;

          fetchedData.add({
            'Purchase Date': data['purchaseDate'],
            'Bill NO': data['billNo'],
            'From Party': data['fromParty'],
            'Phone': data['phone'],
            'City': data['city'],
            'Description': data['description'],
            'Amount': opAmount,
            'Collected': opAmountCollected,
            'Balance': balance,
            'Transactions': TextButton(
              onPressed: () async {
                await historyData(docId: doc.id.toString());

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const CustomText(
                        text: 'Payment History',
                        size: 26,
                      ),
                      content: Container(
                        width: 750,
                        height: 300,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomText(
                                text: 'History Of Payments',
                                size: 20,
                              ),
                              const SizedBox(height: 10),
                              if (historyTableData.isNotEmpty) ...[
                                CustomDataTable(
                                    headers: historyHeaders,
                                    tableData: historyTableData),
                              ],
                              if (historyTableData.isEmpty) ...[
                                const Center(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 100),
                                      CustomText(text: 'No Payment History'),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: CustomText(
                            text: 'Close',
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ],
                    );
                  },
                ).then((_) {
                  historyTableData.clear();
                });
              },
              child: CustomText(
                text: 'View',
                color: AppColors.blue,
              ),
            ),
          });
        }

        lastDoc = snapshot.docs.last;
        setState(() {
          tableData = List.from(fetchedData);
        });

        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (fetchedData.isEmpty) {
        print("No records found");
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double paidAmount = double.tryParse(collectedAmountController.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceController.text = balance.toStringAsFixed(2);
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
        final value = entry['Amount'];
        final intValue = (value is num)
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0;
        return sum + intValue;
      },
    );
  }

  int _totalCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        final value = entry['Collected'];
        final intValue = (value is num)
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0;
        return sum + intValue;
      },
    );
  }

  int _totalBalance() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        final value = entry['Balance'];
        final intValue = (value is num)
            ? value.toInt()
            : int.tryParse(value.toString()) ?? 0;
        return sum + intValue;
      },
    );
  }

  void clear() {
    purchaseDate.clear();
    billNo.clear();
    fromParty.clear();
    phone.clear();
    city.clear();
    description.clear();
    payedDate.clear();
    selectedPaymentMode = '';
    totalAmountController.clear();
    collectedAmountController.clear();
    currentlyPayingAmount.clear();
    balanceController.clear();
    paymentDetails.clear();
  }

  @override
  void initState() {
    fetchData();
    _totalAmountCollected();
    _totalCollected();
    _totalBalance();
    totalAmountController.addListener(_updateBalance);
    collectedAmountController.addListener(_updateBalance);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
    totalAmountController.dispose();
    collectedAmountController.dispose();
    currentlyPayingAmount.dispose();
    balanceController.dispose();
    paymentDetails.dispose();
    payedDate.dispose();
    purchaseDate.dispose();
    billNo.dispose();
    fromParty.dispose();
    phone.dispose();
    city.dispose();
    description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
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
          : null, // No drawer for web view (permanently open)
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
                          text: "Hospital Direct Purchase ",
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  else if (_fromDateController.text.isEmpty ||
                      _toDateController.text.isEmpty)
                    const SizedBox(),
                  CustomButton(
                    label: 'New Bill Entry',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: CustomText(
                                text: 'Add Bill', size: screenWidth * 0.017),
                            content: Container(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.5,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenWidth * 0.5,
                                          height: screenHeight * 0.5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Purchase Date',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        onTap: () =>
                                                            _selectDate(context,
                                                                purchaseDate),
                                                        icon: const Icon(
                                                            Icons.date_range),
                                                        controller:
                                                            purchaseDate,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.15,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Payed Date',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        onTap: () =>
                                                            _selectDate(context,
                                                                payedDate),
                                                        icon: const Icon(
                                                            Icons.date_range),
                                                        controller: payedDate,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.15,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Bill No',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller: billNo,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.2,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'From Party',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller: fromParty,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.2,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'City',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller: city,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.2,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Phone Number',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller: phone,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.2,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Total Amount',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller:
                                                            totalAmountController,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.15,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Collected',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller:
                                                            collectedAmountController,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.15,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Balance',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller:
                                                            balanceController,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.15,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Payment Type',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      SizedBox(
                                                        height:
                                                            screenHeight * 0.04,
                                                        width:
                                                            screenWidth * 0.2,
                                                        child: CustomDropdown(
                                                          label: '',
                                                          items: Constants
                                                              .paymentMode,
                                                          selectedItem:
                                                              selectedPaymentMode,
                                                          onChanged: (value) {
                                                            setState(
                                                              () {
                                                                selectedPaymentMode =
                                                                    value;
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                        text: 'Payment Details',
                                                        size:
                                                            screenWidth * 0.012,
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                      CustomTextField(
                                                        controller:
                                                            paymentDetails,
                                                        hintText: '',
                                                        width:
                                                            screenWidth * 0.2,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => addBill(),
                                child: CustomText(
                                  text: 'Submit ',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: CustomText(
                                  text: 'Cancel',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    width: screenWidth * 0.07,
                    height: screenHeight * 0.04,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
                columnWidths: {
                  5: FixedColumnWidth(screenWidth * 0.1),
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
