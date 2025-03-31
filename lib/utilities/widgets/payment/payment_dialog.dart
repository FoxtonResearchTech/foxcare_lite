import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../colors.dart';
import '../snackBar/snakbar.dart';
import '../text/primary_text.dart';
import '../textField/primary_textField.dart';

class PaymentDialog extends StatefulWidget {
  final String? billNo;
  final String? partyName;
  final String? patientID;
  final String? firstName;
  final String? lastName;
  final String? city;
  final String? balance;
  final String? totalAmount;
  final String? docId;
  final bool? timeLine;
  final Future<void> Function()? fetchData;
  PaymentDialog({
    this.patientID = '',
    this.firstName,
    this.lastName,
    this.balance,
    this.city,
    this.billNo,
    this.partyName,
    super.key,
    this.docId,
    this.timeLine = false,
    this.totalAmount,
    this.fetchData,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  TextEditingController collected = TextEditingController();
  TextEditingController balance = TextEditingController();
  ScrollController _scrollController1 = ScrollController();

  String _selectedPaymentMethod = '';
  bool isNotPatient = false;

  void checkPayer() {
    setState(() {
      if (widget.patientID == '') {
        isNotPatient = true;
      }
    });
  }

  final dateTime = DateTime.now();

  List<Map<String, dynamic>> payments = [];

  IconData getPaymentIcon(String method) {
    switch (method) {
      case "UPI":
        return Icons.qr_code;
      case "Credit Card":
        return Icons.credit_card;
      case "Debit Card":
        return Icons.credit_card_sharp;
      case "Net Banking":
        return Icons.account_balance;
      case "Cash":
        return Icons.money;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> addPaymentAmount(String docID) async {
    try {
      Map<String, dynamic> data = {
        'payedAmount': balance.text,
        'payedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'paymentMode': _selectedPaymentMethod,
        'payedTime': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      };
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc()
          .set(data);
      CustomSnackBar(context,
          message: 'Payment Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Payment', backgroundColor: Colors.red);
    }
  }

  Future<void> updateBalance(String docID, double amountPaid) async {
    if (docID.isEmpty) return;

    try {
      DocumentReference patientDoc = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments');

      DocumentSnapshot snapshot = await patientDoc.get();

      if (!snapshot.exists) {
        print("Payment document does not exist");
        return;
      }

      double currentBalance = double.tryParse(widget.balance ?? '0.00') ?? 0.0;
      double newBalance = currentBalance - amountPaid;

      double currentCollected = double.tryParse(
              snapshot["ipAdmissionCollected"]?.toString() ?? '0.00') ??
          0.0;
      double newCollected = currentCollected + amountPaid;

      await patientDoc.update({
        "ipAdmissionBalance": newBalance.toStringAsFixed(2),
        "ipAdmissionCollected": newCollected.toStringAsFixed(2),
      });

      setState(() {
        balance.text = '₹ ${newBalance.toStringAsFixed(2)}';
      });

      print("Balance and Collected amount updated successfully");
    } catch (e) {
      print("Error updating balance and collected amount: $e");
    }
  }

  Future<void> fetchPayments() async {
    if (widget.docId == null || widget.docId!.isEmpty) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.docId)
          .collection('ipAdmissionPayments')
          .get();

      List<Map<String, dynamic>> tempPayments = [];
      for (var doc in querySnapshot.docs) {
        if (doc.id == "payments") {
          print("Skipping document: payment");
          continue;
        }

        print("Fetched document: ${doc.id}");

        tempPayments.add({
          "date": doc["payedDate"] ?? "No Date",
          "method": doc["paymentMode"] ?? "Unknown",
          "paidAmount": doc["payedAmount"] ?? "₹0",
        });
      }

      setState(() {
        payments = tempPayments;
      });

      print("Final payment list: $payments");
    } catch (error) {
      print("Error fetching payments: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    checkPayer();
    balance.text = '₹ ${widget.balance ?? '0.00'}';
    fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: Center(
        child: CustomText(
          text: 'Payment Details',
          size: screenWidth * 0.015,
        ),
      ),
      content: Container(
        width: screenWidth * 0.3,
        height: screenHeight * 0.5,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: isNotPatient
                    ? 'Bill No: ${widget.billNo ?? 'N/A'}'
                    : 'OP Number: ${widget.patientID ?? 'N/A'}',
                size: screenWidth * 0.010,
              ),
              CustomText(
                  text: isNotPatient
                      ? 'Party Name: ${widget.partyName ?? 'N/A'}'
                      : 'Name: ${widget.firstName ?? 'N/A'} ${widget.lastName ?? 'N/A'}',
                  size: screenWidth * 0.010),
              CustomText(
                  text: 'City: ${widget.city ?? 'N/A'}',
                  size: screenWidth * 0.010),
              CustomText(
                  text: 'Balance: ${widget.balance ?? '0.00'}',
                  size: screenWidth * 0.010),
              SizedBox(height: screenHeight * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: 'Payable Amount:   ',
                    size: screenWidth * 0.012,
                    color: Colors.red,
                  ),
                  CustomTextField(
                      controller: balance,
                      hintText: '',
                      width: screenWidth * 0.08)
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              if (widget.timeLine == true)
                Center(
                  child: SizedBox(
                    height: screenHeight * 0.12,
                    width: screenWidth * 0.75,
                    child: Scrollbar(
                      controller: _scrollController1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController1,
                        child: _buildPaymentTimeline(),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: screenHeight * 0.015),
              CustomText(
                text: 'Select Payment Method:',
                size: screenWidth * 0.012,
                color: Colors.black87,
              ),
              Column(
                children: [
                  RadioListTile(
                    title: CustomText(text: 'UPI', size: screenWidth * 0.010),
                    value: 'UPI',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: CustomText(
                        text: 'Net Banking', size: screenWidth * 0.010),
                    value: 'Net Banking',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: CustomText(
                        text: 'Credit Card', size: screenWidth * 0.010),
                    value: 'Credit Card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: CustomText(
                        text: 'Debit Card', size: screenWidth * 0.010),
                    value: 'Debit Card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: CustomText(text: 'Cash', size: screenWidth * 0.010),
                    value: 'Cash',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value.toString();
                      });
                    },
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
            if (widget.timeLine == true) {
              await addPaymentAmount(widget.docId.toString());
              await updateBalance(widget.docId.toString(),
                  double.parse(balance.text.replaceAll('₹ ', '')));
              widget.fetchData!();
            } else {
              await addPaymentAmount(widget.docId.toString());
            }
          },
          child: CustomText(
            text: 'Pay',
            size: screenWidth * 0.012,
            color: AppColors.secondaryColor,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: CustomText(
            text: 'Close',
            size: screenWidth * 0.012,
            color: AppColors.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTimeline() {
    return payments.isEmpty
        ? const Center(child: CustomText(text: "No Payments Found"))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: payments.map((payment) {
                return Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            getPaymentIcon(payment["method"]),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomText(text: payment["date"]),
                        CustomText(
                          text: payment["paidAmount"],
                        ),
                      ],
                    ),
                    if (payment != payments.last)
                      Container(
                        width: 40,
                        height: 5,
                        color: Colors.grey,
                      ),
                  ],
                );
              }).toList(),
            ),
          );
  }
}
