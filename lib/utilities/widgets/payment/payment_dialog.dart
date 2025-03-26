import 'package:flutter/material.dart';

import '../../colors.dart';
import '../text/primary_text.dart';

class PaymentDialog extends StatefulWidget {
  String? patientID;
  String? firstName;
  String? lastName;
  String? city;

  String? balance;

  PaymentDialog(
      {this.patientID,
      this.firstName,
      this.lastName,
      this.balance,
      this.city,
      super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: CustomText(
        text: 'Payment Details',
        size: 24,
      ),
      content: Container(
        width: 250,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'OP Number : ${widget.patientID ?? 'N/A'} '),
            CustomText(
                text:
                    'Name : ${widget.firstName ?? 'N/A'} ${widget.lastName ?? 'N/A'}'),
            CustomText(text: 'City : ${widget.city ?? 'N/A'}'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CustomText(text: 'Payable Amount :${widget.balance}')],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {},
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
  }
}
