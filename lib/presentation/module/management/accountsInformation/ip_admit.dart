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
  TextEditingController quantity = TextEditingController();
  TextEditingController reasonForAmount = TextEditingController();

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

  Future<void> fetchData({
    String? ipNumber,
    String? singleDate,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final patientQuerySnapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      if (patientQuerySnapshot.docs.isEmpty) {
        print("No patient records found");
        setState(() {
          tableData = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in patientQuerySnapshot.docs) {
        final data = doc.data();

        final ipTicketsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(doc.id)
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

            if (ipNumber != null &&
                ipNumber.isNotEmpty &&
                ipData['ipTicket'].toString() == ipNumber) {
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

          final ipPaymentDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipAdmissionPayments')
              .doc("payments${ipData['ipTicket'].toString()}")
              .get();

          bool hasIpPayment = ipPaymentDoc.exists;

          DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipAdmissionPayments')
              .doc('payments${ipData['ipTicket'].toString()}')
              .get();

          Map<String, dynamic>? detailsData = detailsDoc.exists
              ? detailsDoc.data() as Map<String, dynamic>?
              : null;
          final ipDetailsDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .doc('details')
              .get();

          final ipAdmission = ipDetailsDoc.data()?['ipAdmission'] ?? {};
          double ipAdmissionTotalAmount =
              double.tryParse(detailsData?['ipAdmissionTotalAmount'] ?? '0') ??
                  0;
          double ipAdmissionCollected =
              double.tryParse(detailsData?['ipAdmissionCollected'] ?? '0') ?? 0;
          double ipAdmissionBalanceAmount =
              double.tryParse(detailsData?['ipAdmissionBalance'] ?? '0') ?? 0;
          double balance = ipAdmissionTotalAmount - ipAdmissionCollected;

          fetchedData.add({
            'IP Ticket': ipData['ipTicket']?.toString() ?? '',
            'OP No': data['opNumber']?.toString() ?? 'N/A',
            'IP Admission Date': ipData['ipAdmitDate']?.toString() ?? '',
            'Room Allotment Date': roomAllotmentDateStr ?? '',
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'City': data['city']?.toString() ?? 'N/A',
            'Doctor Name': ipData['doctorName']?.toString() ?? '',
            'Total Amount': ipAdmissionTotalAmount.toStringAsFixed(2),
            'Collected': ipAdmissionCollected.toStringAsFixed(2),
            'Balance': balance.toStringAsFixed(2),
            'Pay': TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => PaymentDialog(
                    timeLine: true,
                    ipTicket: ipData['ipTicket'],
                    patientID: data['opNumber'],
                    firstName: data['firstName'],
                    lastName: data['lastName'],
                    doctorName: ipData['doctorName'],
                    specialization: ipData['specialization'],
                    bloodGroup: data['bloodGroup'],
                    address: data['address1'],
                    age: data['age'],
                    phoneNo: data['phone1'],
                    city: data['city'],
                    roomNo: ipAdmission['roomNo'],
                    roomType: ipAdmission['roomType'],
                    ipAdmitDate: ipData['ipAdmitDate'],
                    docId: doc.id,
                    totalBilledAmount: ipAdmissionTotalAmount.toString(),
                    totalCollectedAmount: ipAdmissionCollected.toString(),
                    totalBalanceAmount: ipAdmissionBalanceAmount.toString(),
                    totalAmount: ipAdmissionCollected.toString(),
                    balance: balance.toString(),
                    fetchData: fetchData,
                  ),
                );
              },
              child: CustomText(text: 'Pay'),
            ),
            'Add Amount': TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => IpAdmitAdditionalAmount(
                    ipTicket: ipData['ipTicket'].toString(),
                    docId: doc.id,
                    fetchData: fetchData,
                    timeLine: true,
                  ),
                );
              },
              child: CustomText(text: 'Add'),
            ),
          });
        }
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['IP Ticket'].toString()) ?? 0;
        int tokenB = int.tryParse(b['IP Ticket'].toString()) ?? 0;
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
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
