import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/surgery_ot_icu_collection.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/payment/ip_admit_payment_dialog.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/payment/ip_admit_additional_amount.dart';
import '../../../../utilities/widgets/payment/payment_dialog.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../management_dashboard.dart';
import 'hospital_direct_purchase.dart';
import 'hospital_direct_purchase_still_pending.dart';

import 'ip_admission_collection.dart';
import 'ip_admit_list.dart';
import 'lab_collection.dart';
import 'new_patient_register_collection.dart';
import 'op_ticket_collection.dart';
import 'other_expense.dart';

class IpAdmit extends StatefulWidget {
  @override
  State<IpAdmit> createState() => _IpAdmit();
}

class _IpAdmit extends State<IpAdmit> {
  final dateTime = DateTime.now();

  int selectedIndex = 8;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  TextEditingController _ipNumber = TextEditingController();

  TextEditingController amount = TextEditingController();
  TextEditingController collected = TextEditingController();
  TextEditingController balanceAmount = TextEditingController();

  DateTime now = DateTime.now();
  final List<String> headers = [
    'OP Ticket',
    'IP No',
    'IP Admission Date',
    'Name',
    'City',
    'Doctor Name',
    'Total Amount',
    'Collected',
    'Balance',
    'Pay',
    'Add Amount',
  ];
  List<Map<String, dynamic>> tableData = [];

  void _updateBalance() {
    double totalAmount = double.tryParse(amount.text) ?? 0.0;
    double paidAmount = double.tryParse(collected.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    balanceAmount.text = balance.toStringAsFixed(2);
  }

  Future<void> addPaymentAmount(String docID) async {
    try {
      Map<String, dynamic> data = {
        'ipAdmissionTotalAmount': amount.text,
        'ipAdmissionCollected': collected.text,
        'ipAdmissionBalance': balanceAmount.text,
      };
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments')
          .set(data);
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments')
          .collection('additionalAmount')
          .doc()
          .set({
        'additionalAmount': amount.text,
        'reason': 'Initial Amount',
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'time': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      });
      CustomSnackBar(context,
          message: 'Additional Fees Added Successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Fees', backgroundColor: Colors.red);
    }
  }

  Future<void> fetchData(
      {String? ipNumber,
      String? singleDate,
      String? fromDate,
      String? toDate}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');
      if (ipNumber != null) {
        query = query.where('ipNumber', isEqualTo: ipNumber);
      } else if (singleDate != null) {
        query = query.where('date', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: fromDate)
            .where('date', isLessThanOrEqualTo: toDate);
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
        if (!data.containsKey('ipNumber')) continue;

        String tokenNo = '';
        bool hasIpPrescription = false;
        bool hasIpPayment = false;

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
          final ipPrescriptionSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .get();

          if (ipPrescriptionSnapshot.docs.isNotEmpty) {
            hasIpPrescription = true;
          }
        } catch (e) {
          print('Error fetching token No for patient ${doc.id}: $e');
        }

        if (hasIpPrescription) {
          final ipAdmissionSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipAdmissionPayments')
              .get();

          if (ipAdmissionSnapshot.docs.isNotEmpty) {
            hasIpPayment = true;
          }

          DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipAdmissionPayments')
              .doc('payments')
              .get();

          Map<String, dynamic>? detailsData = detailsDoc.exists
              ? detailsDoc.data() as Map<String, dynamic>?
              : null;
          String ipAdmissionTotalAmountStr =
              detailsData?['ipAdmissionTotalAmount'] ?? '0';
          String ipAdmissionCollectedStr =
              detailsData?['ipAdmissionCollected'] ?? '0';
          String ipAdmissionDate = detailsData?['date'] ?? 'N/A';

          double ipAdmissionTotalAmount =
              double.tryParse(ipAdmissionTotalAmountStr) ?? 0;
          double ipAdmissionCollected =
              double.tryParse(ipAdmissionCollectedStr) ?? 0;

          double balance = ipAdmissionTotalAmount - ipAdmissionCollected;

          fetchedData.add({
            'OP Ticket': tokenNo,
            'IP No': data['ipNumber']?.toString() ?? 'N/A',
            'IP Admission Date': ipAdmissionDate,
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'City': data['city']?.toString() ?? 'N/A',
            'Doctor Name': data['doctorName']?.toString() ?? 'N/A',
            'Total Amount': ipAdmissionTotalAmountStr,
            'Collected': ipAdmissionCollectedStr,
            'Balance': balance,
            'Pay': hasIpPayment
                ? TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return PaymentDialog(
                            timeLine: true,
                            patientID: data['opNumber'],
                            firstName: data['firstName'],
                            lastName: data['lastName'],
                            city: data['city'],
                            docId: doc.id,
                            totalAmount: ipAdmissionCollectedStr,
                            balance: balance.toString(),
                            fetchData: fetchData,
                          );
                        },
                      );
                    },
                    child: CustomText(text: 'Pay'),
                  )
                : TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Add Payment Amount'),
                            content: Container(
                              width: 300,
                              height: 250,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomTextField(
                                    controller: amount,
                                    hintText: 'Total Amount',
                                    width: 250,
                                  ),
                                  CustomTextField(
                                    controller: collected,
                                    hintText: 'Collected',
                                    width: 250,
                                  ),
                                  CustomTextField(
                                    controller: balanceAmount,
                                    hintText: 'Balance',
                                    width: 250,
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  addPaymentAmount(doc.id);
                                  fetchData(ipNumber: data['ipNumber']);
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return IpAdmitPaymentDialog(
                                          patientID: data['ipNumber'],
                                          firstName: data['firstName'],
                                          lastName: data['lastName'],
                                          city: data['city'],
                                          balance: collected.text,
                                          docId: doc.id,
                                        );
                                      });
                                },
                                child: CustomText(
                                  text: 'Submit ',
                                  color: AppColors.secondaryColor,
                                  size: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: CustomText(
                                  text: 'Cancel',
                                  color: AppColors.secondaryColor,
                                  size: 15,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: CustomText(text: 'Add Payment'),
                  ),
            'Add Amount': TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return IpAdmitAdditionalAmount(
                      docId: doc.id,
                      fetchData: fetchData,
                      timeLine: true,
                    );
                  },
                );
              },
              child: CustomText(text: 'Add'),
            ),
          });
        }
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
              title: CustomText(
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
              ), // Drawer minimized for mobile
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
              ), // Sidebar always open for web view
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
                    padding: EdgeInsets.only(top: screenWidth * 0.07),
                    child: Column(
                      children: [
                        CustomText(
                          text: "IP Admit ",
                          size: screenWidth * .015,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
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
                  CustomTextField(
                    hintText: 'IP Number',
                    width: screenWidth * 0.15,
                    controller: _ipNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(ipNumber: _ipNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
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
                children: [CustomText(text: 'Collection Report Of Date')],
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
      ),
    );
  }
}
