import 'package:flutter/material.dart';
import '../../colors.dart';
import '../text/primary_text.dart';

class PaymentDialog extends StatefulWidget {
  final String? patientID;
  final String? firstName;
  final String? lastName;
  final String? city;
  final String? balance;

  PaymentDialog({
    this.patientID,
    this.firstName,
    this.lastName,
    this.balance,
    this.city,
    super.key,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _selectedPaymentMethod = '';

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
        height: screenHeight * 0.40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'OP Number: ${widget.patientID ?? 'N/A'}',
              size: screenWidth * 0.010,
            ),
            CustomText(
                text:
                    'Name: ${widget.firstName ?? 'N/A'} ${widget.lastName ?? 'N/A'}',
                size: screenWidth * 0.010),
            CustomText(
                text: 'City: ${widget.city ?? 'N/A'}',
                size: screenWidth * 0.010),
            SizedBox(height: screenHeight * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: 'Payable Amount: ₹${widget.balance ?? '0.00'}',
                  size: screenWidth * 0.012,
                  color: Colors.red,
                ),
              ],
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
                  title:
                      CustomText(text: 'Debit Card', size: screenWidth * 0.010),
                  value: 'Debit Card',
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
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            print("Processing Payment via $_selectedPaymentMethod");
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
}
