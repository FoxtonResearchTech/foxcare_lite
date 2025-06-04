import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';

import '../../colors.dart';
import '../snackBar/snakbar.dart';
import '../text/primary_text.dart';
import '../textField/primary_textField.dart';

class IpAdmitAdditionalAmount extends StatefulWidget {
  final String? docId;
  final String? ipTicket;

  final Future<void> Function()? fetchData;
  final bool? timeLine;

  IpAdmitAdditionalAmount(
      {this.docId, super.key, this.fetchData, this.timeLine, this.ipTicket});

  @override
  State<IpAdmitAdditionalAmount> createState() =>
      _IpAdmitAdditionalAmountState();
}

class _IpAdmitAdditionalAmountState extends State<IpAdmitAdditionalAmount> {
  TextEditingController additionalAmount = TextEditingController();
  TextEditingController rate = TextEditingController();

  TextEditingController reasonForAdditionalAmount = TextEditingController();
  TextEditingController quantity = TextEditingController();

  TextEditingController totalAmount = TextEditingController();

  ScrollController _scrollController1 = ScrollController();

  final dateTime = DateTime.now();
  List<Map<String, dynamic>> amountTimeline = [];

  final List<String> ipAdditionalAmountHeader = [
    'SL No',
    'Description',
    'Rate',
    'Quantity',
    'Amount'
  ];
  List<Map<String, dynamic>> ipAdditionalAmountData = [];

  final List<String> currentIpAdditionalAmountHeader = [
    'SL No',
    'Description',
    'Rate',
    'Quantity',
    'Amount',
    'Delete',
  ];
  List<Map<String, dynamic>> currentIpAdditionalAmountData = [];
  bool validateForm1() {
    if (reasonForAdditionalAmount.text.isEmpty ||
        quantity.text.isEmpty ||
        rate.text.isEmpty) {
      CustomSnackBar(
        context,
        message: 'Please fill all required fields',
        backgroundColor: Colors.red,
      );
      return false;
    }
    return true;
  }

  Future<void> fetchIpAdditionalAmountData(
      String docID, String ipTicket) async {
    try {
      final List<Map<String, dynamic>> fetchedData = [];

      final additionalAmountCollection = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments$ipTicket')
          .collection('additionalAmount');

      final snapshot = await additionalAmountCollection.get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final List<dynamic>? detailsList = data['details'];

        if (detailsList != null) {
          for (var entry in detailsList) {
            if (entry is Map<String, dynamic>) {
              fetchedData.add(entry);
            }
          }
        }
      }

      setState(() {
        ipAdditionalAmountData = fetchedData;
      });

      print("Fetched data: $ipAdditionalAmountData");
    } catch (e) {
      print("Error fetching additional amount data: $e");
    }
  }

  Future<void> handleIpPayment(String docID, String? ipTicket) async {
    if (ipTicket == null) return;

    DocumentReference paymentDocRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(docID)
        .collection('ipAdmissionPayments')
        .doc('payments$ipTicket');

    DocumentSnapshot snapshot = await paymentDocRef.get();

    if (snapshot.exists) {
      await additionalPaymentAmount(docID, ipTicket);
    } else {
      await initialAmount(docID, ipTicket);
    }
  }

  Future<void> initialAmount(String docID, String? ipTicket) async {
    try {
      List<Map<String, dynamic>> cleanedData =
          currentIpAdditionalAmountData.map((entry) {
        final newEntry = Map<String, dynamic>.from(entry);
        newEntry.remove('Delete'); // Remove the IconButton
        return newEntry;
      }).toList();

      Map<String, dynamic> data = {
        'ipAdmissionTotalAmount': totalAmount.text,
        'ipAdmissionCollected': '0',
        'ipAdmissionBalance': totalAmount.text,
        'patientIpTicket': ipTicket,
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
      };
      DocumentReference ref = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments$ipTicket');

      await ref.set(data);
      await ref.collection('additionalAmount').doc().set({
        'details': cleanedData,
        'totalAmount': totalAmount.text,
        'ipTicket': ipTicket,
        'collectedTillNow': '0',
        'date':
            "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
        'time':
            "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
      });
      CustomSnackBar(context,
          message: 'Fees Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Fees', backgroundColor: Colors.red);
    }
  }

  Future<void> additionalPaymentAmount(String docID, String? ipTicket) async {
    try {
      List<Map<String, dynamic>> cleanedData =
          currentIpAdditionalAmountData.map((entry) {
        final newEntry = Map<String, dynamic>.from(entry);
        newEntry.remove('Delete'); // Remove the IconButton
        return newEntry;
      }).toList();

      DocumentReference paymentDocRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments$ipTicket');

      DocumentSnapshot paymentSnapshot = await paymentDocRef.get();
      double currentTotalAmount = 0.0;
      double currentCollectedAmount;

      String existingCollectedAmount = "0";

      if (paymentSnapshot.exists && paymentSnapshot.data() != null) {
        var data = paymentSnapshot.data() as Map<String, dynamic>;
        String existingAmountStr = data['ipAdmissionTotalAmount'] ?? "0";

        existingCollectedAmount = data['ipAdmissionCollected'] ?? "0";

        currentTotalAmount = double.tryParse(existingAmountStr) ?? 0.0;
      }

      double additionalAmt = double.tryParse(totalAmount.text) ?? 0.0;

      String newTotalAmount = (currentTotalAmount + additionalAmt).toString();
      String newBalance =
          (double.parse(newTotalAmount) - double.parse(existingCollectedAmount))
              .toString();

      await paymentDocRef.update({
        'ipAdmissionTotalAmount': newTotalAmount,
        'ipAdmissionBalance': newBalance,
      });

      await paymentDocRef.collection('additionalAmount').doc().set({
        'details': cleanedData,
        'totalAmount': totalAmount.text,
        'ipTicket': ipTicket,
        'collectedTillNow': existingCollectedAmount,
        'date':
            "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}",
        'time':
            "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
      });
      widget.fetchData!();

      CustomSnackBar(context,
          message: 'Fees Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Fees', backgroundColor: Colors.red);
    }
  }

  int _totalAmount() {
    return currentIpAdditionalAmountData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Amount'];
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

  void _updateAmount() {
    final qty = double.tryParse(quantity.text) ?? 0;
    final rt = double.tryParse(rate.text) ?? 0;
    final amount = qty * rt;

    additionalAmount.text = amount.toStringAsFixed(2);
  }

  @override
  void initState() {
    quantity.addListener(_updateAmount);
    rate.addListener(_updateAmount);
    totalAmount.addListener(_updateAmount);
    fetchIpAdditionalAmountData(
        widget.docId.toString(), widget.ipTicket.toString());
    super.initState();
  }

  @override
  void dispose() {
    quantity.dispose();
    rate.dispose();
    additionalAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: const Text('Add Payment Amount'),
      content: Container(
        width: screenWidth * 0.6,
        height: screenHeight * 0.6,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                CustomTextField(
                  controller: reasonForAdditionalAmount,
                  hintText: 'Description',
                  width: screenWidth * 0.18,
                ),
                CustomTextField(
                  controller: quantity,
                  hintText: 'Quantity',
                  width: screenWidth * 0.1,
                ),
                CustomTextField(
                  controller: rate,
                  hintText: 'Rate',
                  width: screenWidth * 0.12,
                ),
                CustomTextField(
                  controller: additionalAmount,
                  hintText: 'Amount',
                  width: screenWidth * 0.12,
                  readOnly: true,
                ),
                CustomButton(
                  label: 'Add',
                  onPressed: () {
                    if (validateForm1()) {
                      setState(() {
                        setState(() {
                          currentIpAdditionalAmountData.add({
                            'SL No': currentIpAdditionalAmountData.length + 1,
                            'Description': reasonForAdditionalAmount.text,
                            'Rate': rate.text,
                            'Quantity': quantity.text,
                            'Amount': additionalAmount.text,
                            'Delete': null,
                          });

                          int index = currentIpAdditionalAmountData.length - 1;

                          currentIpAdditionalAmountData[index]['Delete'] =
                              IconButton(
                            onPressed: () {
                              setState(() {
                                currentIpAdditionalAmountData.removeAt(index);
                                for (int i = 0;
                                    i < currentIpAdditionalAmountData.length;
                                    i++) {
                                  currentIpAdditionalAmountData[i]['SL No'] =
                                      i + 1;
                                }
                              });
                              _totalAmount();
                              totalAmount.text = _totalAmount().toString();
                            },
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                          );
                        });

                        reasonForAdditionalAmount.clear();
                        quantity.clear();
                        rate.clear();
                        additionalAmount.clear();
                        _totalAmount();
                        totalAmount.text = _totalAmount().toString();
                      });
                    }
                  },
                  width: screenWidth * 0.04,
                  height: screenHeight * 0.05,
                )
              ]),
              SizedBox(height: screenHeight * 0.04),
              if (currentIpAdditionalAmountData.isNotEmpty) ...[
                CustomDataTable(
                    headers: currentIpAdditionalAmountHeader,
                    tableData: currentIpAdditionalAmountData)
              ],
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomTextField(
                      controller: totalAmount,
                      hintText: 'Total Amount ',
                      width: screenWidth * 0.1),
                  SizedBox(
                    width: screenWidth * 0.01,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'History Of Additional Amount',
                    size: screenWidth * 0.012,
                  )
                ],
              ),
              if (ipAdditionalAmountData.isNotEmpty) ...[
                CustomDataTable(
                    headers: ipAdditionalAmountHeader,
                    tableData: ipAdditionalAmountData)
              ],
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (currentIpAdditionalAmountData.isEmpty) {
              CustomSnackBar(context,
                  message: 'Please enter Details',
                  backgroundColor: Colors.orange);

              return;
            }

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Confirm Submission'),
                  ],
                ),
                content: const Text(
                  'Are you sure you want to add additional amount?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await handleIpPayment(
                  widget.docId.toString(), widget.ipTicket.toString());

              widget.fetchData!();
            }
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
  }
}
