import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../utilities/colors.dart';
import '../../../../utilities/constants.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';

class OpTicketCollection extends StatefulWidget {
  @override
  State<OpTicketCollection> createState() => _OpTicketCollection();
}

class _OpTicketCollection extends State<OpTicketCollection> {
  // To store the index of the selected drawer item
  int selectedIndex = 1;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  int hoveredIndex = -1;
  bool isLoading = false;
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

  final List<String> headers = [
    'OP Ticket',
    'OP No',
    'Date',
    'Name',
    'City',
    'Doctor Name',
    'Total Amount',
    'Collected',
    'Balance',
    'Pay'
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
        Query query =
            FirebaseFirestore.instance.collection('patients').limit(pageSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          print("No more patient records found");
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final docRef = doc.reference;

          final opTicketsSnapshot = await docRef.collection('opTickets').get();

          for (var ticketDoc in opTicketsSnapshot.docs) {
            final ticketData = ticketDoc.data();
            final ticketDate = ticketData['tokenDate']?.toString();

            if (singleDate != null && ticketDate != singleDate) continue;

            if (fromDate != null &&
                toDate != null &&
                (ticketDate == null ||
                    ticketDate.compareTo(fromDate) < 0 ||
                    ticketDate.compareTo(toDate) > 0)) {
              continue;
            }

            double opAmount = double.tryParse(
                    ticketData['opTicketTotalAmount']?.toString() ?? '0') ??
                0;
            double opAmountCollected = double.tryParse(
                    ticketData['opTicketCollectedAmount']?.toString() ?? '0') ??
                0;
            double balance = opAmount - opAmountCollected;

            allFetchedData.add({
              'OP Ticket': ticketDoc.id,
              'OP No': data['opNumber']?.toString() ?? 'N/A',
              'Date': ticketData['tokenDate']?.toString() ?? 'N/A',
              'Name':
                  '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                      .trim(),
              'City': data['city']?.toString() ?? 'N/A',
              'Doctor Name': ticketData['doctorName']?.toString() ?? 'N/A',
              'Total Amount': opAmount.toString(),
              'Collected': opAmountCollected.toString(),
              'Balance': balance,
              'Pay': TextButton(
                onPressed: () async {
                  await historyData(
                      opNumber: data['opNumber'].toString(),
                      opTicket: ticketData['opTicket'].toString());
                  paymentDetails.clear();

                  double originalCollected = double.tryParse(
                          ticketData['opTicketCollectedAmount']?.toString() ??
                              '0') ??
                      0.0;
                  double total = double.tryParse(
                          ticketData['opTicketTotalAmount']?.toString() ??
                              '0') ??
                      0.0;

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
                                const SizedBox(height: 25),
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
                                            controller:
                                                collectedAmountController,
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
                                const SizedBox(height: 50),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomText(
                                          text: 'Paying Amount ',
                                          size: 20,
                                        ),
                                        const SizedBox(height: 7),
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
                                        const CustomText(
                                          text: 'Payment Mode ',
                                          size: 20,
                                        ),
                                        const SizedBox(height: 7),
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
                                        const CustomText(
                                          text: 'Payment Details ',
                                          size: 20,
                                        ),
                                        const SizedBox(height: 7),
                                        CustomTextField(
                                          hintText: '',
                                          controller: paymentDetails,
                                          width: 175,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
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
                                  opTicket: ticketData['opTicket'].toString(),
                                  opNumber: data['opNumber'].toString(),
                                  opAmount:
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
        }

        lastDoc = snapshot.docs.last;

        setState(() {
          tableData = List.from(allFetchedData);
          _totalAmountCollected();
          _totalCollected();
          _totalBalance();
        });

        if (snapshot.docs.length < pageSize) {
          break;
        }

        await Future.delayed(delayBetweenPages);
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> historyData(
      {required String opNumber, required String opTicket}) async {
    try {
      DocumentReference patientDoc = FirebaseFirestore.instance
          .collection('patients')
          .doc(opNumber)
          .collection('opTickets')
          .doc(opTicket);

      QuerySnapshot snapshot =
          await patientDoc.collection('opTicketPayments').get();

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

  Future<void> savePayment({
    required String opNumber,
    required String opTicket,
    required String opAmount,
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
          .collection('patients')
          .doc(opNumber)
          .collection('opTickets')
          .doc(opTicket)
          .update({
        'opTicketTotalAmount': opAmount,
        'opTicketCollectedAmount': collected,
        'opTicketBalance': balance,
      });
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(opNumber)
          .collection('opTickets')
          .doc(opTicket)
          .collection('opTicketPayments')
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
                          text: "OP Ticket Collection ",
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
              SizedBox(height: screenHeight * 0.06),
            ],
          ),
        ),
      ),
    );
  }
}
