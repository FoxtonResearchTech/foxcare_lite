import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';
import '../snackBar/snakbar.dart';
import '../text/primary_text.dart';
import '../textField/primary_textField.dart';

class IpAdmitAdditionalAmount extends StatefulWidget {
  final String? docID;
  final Future<void> Function()? fetchData;

  IpAdmitAdditionalAmount({this.docID, super.key, this.fetchData});

  @override
  State<IpAdmitAdditionalAmount> createState() =>
      _IpAdmitAdditionalAmountState();
}

class _IpAdmitAdditionalAmountState extends State<IpAdmitAdditionalAmount> {
  TextEditingController additionalAmount = TextEditingController();
  TextEditingController reasonForAdditionalAmount = TextEditingController();
  final dateTime = DateTime.now();

  Future<void> additionalPaymentAmount(String docID) async {
    try {
      DocumentReference paymentDocRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(docID)
          .collection('ipAdmissionPayments')
          .doc('payments');

      DocumentSnapshot paymentSnapshot = await paymentDocRef.get();
      double currentTotalAmount = 0.0;

      if (paymentSnapshot.exists && paymentSnapshot.data() != null) {
        var data = paymentSnapshot.data() as Map<String, dynamic>;
        String existingAmountStr = data['ipAdmissionTotalAmount'] ?? "0";

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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Payment Amount'),
      content: Container(
        width: 300,
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomTextField(
              controller: additionalAmount,
              hintText: 'Amount',
              width: 250,
            ),
            CustomTextField(
              controller: reasonForAdditionalAmount,
              hintText: 'Reason',
              width: 250,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            additionalPaymentAmount(widget.docID.toString());
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
}
