import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  TextEditingController reasonForAdditionalAmount = TextEditingController();

  ScrollController _scrollController1 = ScrollController();

  final dateTime = DateTime.now();
  List<Map<String, dynamic>> amountTimeline = [];

  Future<void> fetchAmountTimeline() async {
    if (widget.docId == null || widget.docId!.isEmpty) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.docId)
          .collection('ipAdmissionPayments')
          .doc('payments')
          .collection('additionalAmount')
          .get();

      List<Map<String, dynamic>> tempAmountTimeline = [];
      for (var doc in querySnapshot.docs) {
        if (doc.id == "payments") {
          print("Skipping document: payment");
          continue;
        }

        print("Fetched document: ${doc.id}");

        tempAmountTimeline.add({
          "time": doc["time"] ?? "00:00",
          "date": doc["date"] ?? "1970-01-01", // default to epoch if missing
          "reason": doc["reason"] ?? "Unknown",
          "amount": doc["additionalAmount"] ?? "₹0",
        });
      }

      tempAmountTimeline.sort((a, b) {
        DateTime dateTimeA = DateTime.parse("${a["date"]} ${a["time"]}");
        DateTime dateTimeB = DateTime.parse("${b["date"]} ${b["time"]}");
        return dateTimeB.compareTo(dateTimeA);
      });

      setState(() {
        amountTimeline = tempAmountTimeline;
      });

      print("Final sorted payment list: $amountTimeline");
    } catch (error) {
      print("Error fetching payments: $error");
    }
  }

  Future<void> additionalPaymentAmount(String docID, String? ipTicket) async {
    try {
      DocumentReference paymentDocRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments');

      DocumentSnapshot paymentSnapshot = await paymentDocRef.get();
      double currentTotalAmount = 0.0;
      String existingCollectedAmount = "0";

      if (paymentSnapshot.exists && paymentSnapshot.data() != null) {
        var data = paymentSnapshot.data() as Map<String, dynamic>;
        String existingAmountStr = data['ipAdmissionTotalAmount'] ?? "0";
        existingCollectedAmount = data['ipAdmissionCollected'] ?? "0";

        currentTotalAmount = double.tryParse(existingAmountStr) ?? 0.0;
      }

      double additionalAmt = double.tryParse(additionalAmount.text) ?? 0.0;

      String newTotalAmount = (currentTotalAmount + additionalAmt).toString();

      await paymentDocRef.update({
        'ipAdmissionTotalAmount': newTotalAmount,
      });

      await paymentDocRef.collection('additionalAmount').doc().set({
        'additionalAmount': additionalAmount.text,
        'reason': reasonForAdditionalAmount.text,
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

  @override
  void initState() {
    fetchAmountTimeline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: Text('Add Payment Amount'),
      content: Container(
        width: screenWidth * 0.25,
        height: screenHeight * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomTextField(
              controller: additionalAmount,
              hintText: 'Amount',
              width: screenWidth * 0.18,
            ),
            CustomTextField(
              controller: reasonForAdditionalAmount,
              hintText: 'Reason',
              width: screenWidth * 0.18,
            ),
            SizedBox(height: screenHeight * 0.010),
            if (widget.timeLine == true)
              Center(
                child: SizedBox(
                  height: screenHeight * 0.175,
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
            SizedBox(height: screenHeight * 0.010),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            additionalPaymentAmount(widget.docId.toString(), widget.ipTicket);
            widget.fetchData!();
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

  Widget _buildPaymentTimeline() {
    return amountTimeline.isEmpty
        ? const Center(child: CustomText(text: "No Additional Amount Found"))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: amountTimeline.map((amount) {
                return Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.money,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CustomText(text: amount["date"]),
                        CustomText(
                          text: '₹' + amount["amount"],
                        ),
                        Expanded(
                          child: CustomText(
                            text: amount["reason"],
                          ),
                        ),
                      ],
                    ),
                    if (amount != amountTimeline.last)
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
