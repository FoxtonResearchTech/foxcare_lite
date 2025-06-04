import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../utilities/colors.dart';
import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class OtherExpense extends StatefulWidget {
  @override
  State<OtherExpense> createState() => _OtherExpense();
}

class _OtherExpense extends State<OtherExpense> {
  int selectedIndex = 6;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  bool isLoading = false;
  //ADD BILL
  TextEditingController billDate = TextEditingController();
  TextEditingController billNo = TextEditingController();
  TextEditingController fromParty = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController particular = TextEditingController();

  TextEditingController amount = TextEditingController();
  TextEditingController collected = TextEditingController();
  TextEditingController balanceAmount = TextEditingController();

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
    'Bill Date',
    'Bill NO',
    'Party Name',
    'Phone',
    'City',
    'Particular',
    'Address',
    'Amount',
    'Collected',
    'Balance',
    'Pay'
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

  void _payingAmountListener() {
    double paying = double.tryParse(currentlyPayingAmount.text) ?? 0.0;
    double total = double.tryParse(totalAmountController.text) ?? 0.0;

    double newCollected = _originalCollected + paying;
    double newBalance = total - newCollected;

    collectedAmountController.text = newCollected.toStringAsFixed(2);
    balanceController.text = newBalance.toStringAsFixed(2);
  }

  Future<void> savePayment({
    required String docId,
    required String totalAmount,
    required String collected,
    required String balance,
    required String paymentMode,
    required String payingAmount,
  }) async {
    if (selectedPaymentMode == null ||
        paymentDetails.text.isEmpty ||
        currentlyPayingAmount.text.isEmpty) {
      CustomSnackBar(
        context,
        message: "Please fill all the required fields",
        backgroundColor: Colors.orange,
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('otherExpense')
          .doc(docId)
          .update({
        'amount': totalAmount,
        'collected': collected,
        'balance': balance,
      });
      await FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('otherExpense')
          .doc(docId)
          .collection('payments')
          .doc()
          .set({
        'collected': payingAmount,
        'balance': balance,
        'paymentMode': paymentMode,
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
      fetchData();
      Navigator.of(context).pop();
      CustomSnackBar(context,
          message: "Payment Updated Successfully",
          backgroundColor: Colors.green);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register patient: $e")),
      );
    }
  }

  Future<void> historyData({required String docId}) async {
    try {
      DocumentReference patientDoc = FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('otherExpense')
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

  Future<void> addBill() async {
    if (billDate.text.isEmpty) {
      CustomSnackBar(context,
          message: 'Please Enter Bill Date', backgroundColor: Colors.red);
      return;
    }

    try {
      Map<String, dynamic> data = {
        'billDate': billDate.text,
        'billNo': billNo.text,
        'partyName': fromParty.text,
        'phone': phone.text,
        'city': city.text,
        'address': address.text,
        'particular': particular.text,
        'amount': amount.text,
        'collected': collected.text,
        'balance': balanceAmount.text,
      };
      DocumentReference billRef = FirebaseFirestore.instance
          .collection('hospital')
          .doc('purchase')
          .collection('otherExpense')
          .doc();

      await billRef.set(data);

      await billRef.collection('payments').add({
        'collected': amount.text,
        'balance': balanceAmount.text,
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
      await fetchData();

      CustomSnackBar(context,
          message: 'Bill Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Bill', backgroundColor: Colors.red);
    }
  }

  Future<void> fetchData({
    String? singleDate,
    String? fromDate,
    String? toDate,
    int batchSize = 20, // number of docs per batch
  }) async {
    try {
      List<Map<String, dynamic>> allFetchedData = [];
      DocumentSnapshot? lastDoc;
      bool moreData = true;

      while (moreData) {
        Query query = FirebaseFirestore.instance
            .collection('hospital')
            .doc('purchase')
            .collection('otherExpense');

        if (singleDate != null) {
          query = query.where('billDate', isEqualTo: singleDate);
          query = query.orderBy('billDate');
        } else if (fromDate != null && toDate != null) {
          query = query
              .where('billDate', isGreaterThanOrEqualTo: fromDate)
              .where('billDate', isLessThanOrEqualTo: toDate)
              .orderBy('billDate');
        }

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        query = query.limit(batchSize);

        final snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          moreData = false;
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('billNo')) continue;
          if (!data.containsKey('billDate')) continue;

          double opAmount =
              double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
          double opAmountCollected =
              double.tryParse(data['collected']?.toString() ?? '0') ?? 0;
          double balance = opAmount - opAmountCollected;

          allFetchedData.add({
            'Bill Date': data['billDate'],
            'Bill NO': data['billNo'],
            'Party Name': data['partyName'],
            'Phone': data['phone'],
            'City': data['city'],
            'Address': data['address'],
            'Particular': data['particular'],
            'Amount': opAmount.toInt(),
            'Collected': opAmountCollected.toInt(),
            'Balance': balance.toInt(),
            'Pay': TextButton(
              onPressed: () async {
                await historyData(docId: doc.id.toString());
                paymentDetails.clear();

                double originalCollected =
                    double.tryParse(data['collected']?.toString() ?? '0') ??
                        0.0;
                double total =
                    double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0;

                setState(() {
                  _originalCollected = originalCollected;
                  totalAmountController.text = total.toStringAsFixed(2);
                  collectedAmountController.text =
                      originalCollected.toStringAsFixed(2);
                  balanceController.text =
                      (total - originalCollected).toStringAsFixed(2);
                  currentlyPayingAmount.text = '';
                });

                currentlyPayingAmount.removeListener(_payingAmountListener);
                currentlyPayingAmount.addListener(_payingAmountListener);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const CustomText(
                        text: 'Payment Details ',
                        size: 26,
                      ),
                      content: Container(
                        width: 750,
                        height: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 25),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(
                                        text: 'Total Amount',
                                        size: 20,
                                      ),
                                      const SizedBox(height: 5),
                                      CustomTextField(
                                          readOnly: true,
                                          controller: totalAmountController,
                                          hintText: '',
                                          width: 175),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(
                                        text: 'Collected',
                                        size: 20,
                                      ),
                                      const SizedBox(height: 5),
                                      CustomTextField(
                                          readOnly: true,
                                          controller: collectedAmountController,
                                          hintText: '',
                                          width: 175),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(
                                        text: 'Balance',
                                        size: 20,
                                      ),
                                      const SizedBox(height: 5),
                                      CustomTextField(
                                          readOnly: true,
                                          controller: balanceController,
                                          hintText: '',
                                          width: 175),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 50),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: 'Paying Amount ',
                                        size: 20,
                                      ),
                                      SizedBox(height: 7),
                                      CustomTextField(
                                        hintText: '',
                                        controller: currentlyPayingAmount,
                                        width: 175,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: 'Payment Mode ',
                                        size: 20,
                                      ),
                                      SizedBox(height: 7),
                                      SizedBox(
                                        width: 175,
                                        child: CustomDropdown(
                                          label: '',
                                          items: Constants.paymentMode,
                                          onChanged: (value) {
                                            setState(
                                              () {
                                                selectedPaymentMode = value;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: 'Payment Details ',
                                        size: 20,
                                      ),
                                      SizedBox(height: 7),
                                      CustomTextField(
                                        hintText: '',
                                        controller: paymentDetails,
                                        width: 175,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              CustomText(
                                text: 'History Of Payments',
                                size: 20,
                              ),
                              SizedBox(height: 10),
                              if (historyTableData.isNotEmpty) ...[
                                CustomDataTable(
                                    headers: historyHeaders,
                                    tableData: historyTableData),
                              ],
                              if (historyTableData.isEmpty) ...[
                                Center(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20),
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
                          onPressed: () async {
                            await savePayment(
                                docId: doc.id.toString(),
                                totalAmount:
                                    totalAmountController.text.toString(),
                                collected:
                                    collectedAmountController.text.toString(),
                                balance: balanceController.text.toString(),
                                paymentMode: selectedPaymentMode.toString(),
                                payingAmount:
                                    currentlyPayingAmount.text.toString());
                          },
                          child: CustomText(
                            text: 'Pay',
                            color: AppColors.secondaryColor,
                          ),
                        ),
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
                text: 'Pay',
                color: AppColors.blue,
              ),
            ),
          });
        }

        lastDoc = snapshot.docs.last;

        setState(() {
          tableData = List.from(allFetchedData);
        });

        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (allFetchedData.isEmpty) {
        print("No records found");
        setState(() {
          tableData = [];
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(amount.text) ?? 0.0;
    double paidAmount = double.tryParse(collected.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceAmount.text = balance.toStringAsFixed(2);
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
        var value = entry['Amount'];
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
        if (value is double) {
          value = value.toInt();
        }
        return sum + (value as int);
      },
    );
  }

  void clear() {
    billDate.clear();
    billNo.clear();
    fromParty.clear();
    phone.clear();
    city.clear();
    address.clear();
    amount.clear();
    collected.clear();
    balanceAmount.clear();
    particular.clear();
    paymentDetails.clear();
    currentlyPayingAmount.clear();
    selectedPaymentMode = null;
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
    amount.dispose();
    collected.dispose();
    balanceAmount.dispose();
    billDate.dispose();

    particular.dispose();
    billNo.dispose();
    fromParty.dispose();
    phone.dispose();
    city.dispose();
    address.dispose();
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
                          text: "Other Expense",
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
                    CustomText(text: 'Collection Report Of Date ')
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
                    SizedBox(),
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
                              height: screenHeight * 0.7,
                              width: screenWidth * 0.5,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Bill Date',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      onTap: () => _selectDate(
                                                          context, billDate),
                                                      icon: const Icon(
                                                          Icons.date_range),
                                                      controller: billDate,
                                                      hintText: '',
                                                      width: screenWidth * 0.15,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Bill No',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: billNo,
                                                      hintText: '',
                                                      width: screenWidth * 0.2,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.08),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Party name',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: fromParty,
                                                      hintText: '',
                                                      width: screenWidth * 0.2,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'City',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: city,
                                                      hintText: '',
                                                      width: screenWidth * 0.2,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.08),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Phone Number',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: phone,
                                                      hintText: '',
                                                      width: screenWidth * 0.2,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Address',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: address,
                                                      hintText: '',
                                                      width: screenWidth * 0.25,
                                                      verticalSize:
                                                          screenHeight * 0.035,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Particular',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: particular,
                                                      hintText: '',
                                                      width: screenWidth * 0.5,
                                                      verticalSize:
                                                          screenHeight * 0.035,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Total Amount',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: amount,
                                                      hintText: '',
                                                      width: screenWidth * 0.12,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.06),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Collected',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: collected,
                                                      hintText: '',
                                                      width: screenWidth * 0.12,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.06),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Balance',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller: balanceAmount,
                                                      hintText: '',
                                                      width: screenWidth * 0.12,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Payment Type',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    SizedBox(
                                                      height:
                                                          screenHeight * 0.04,
                                                      width: screenWidth * 0.2,
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
                                                SizedBox(
                                                    width: screenWidth * 0.08),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: 'Payment Details',
                                                      size: screenWidth * 0.012,
                                                    ),
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    CustomTextField(
                                                      controller:
                                                          paymentDetails,
                                                      hintText: '',
                                                      width: screenWidth * 0.2,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  await addBill();
                                },
                                child: CustomText(
                                  text: 'Submit',
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
