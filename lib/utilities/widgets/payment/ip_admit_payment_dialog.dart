import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import '../../colors.dart';
import '../snackBar/snakbar.dart';
import '../text/primary_text.dart';

class IpAdmitPaymentDialog extends StatefulWidget {
  final String? billNo;
  final String? partyName;
  final String? patientID;
  final String? firstName;
  final String? lastName;
  final String? city;
  final String? balance;
  final String? docId;

  IpAdmitPaymentDialog({
    this.patientID = '',
    this.firstName,
    this.lastName,
    this.balance,
    this.city,
    this.billNo,
    this.partyName,
    super.key,
    this.docId,
  });

  @override
  State<IpAdmitPaymentDialog> createState() => _IpAdmitPaymentDialog();
}

class _IpAdmitPaymentDialog extends State<IpAdmitPaymentDialog> {
  TextEditingController collected = TextEditingController();
  TextEditingController balance = TextEditingController();

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

  @override
  void initState() {
    checkPayer();
    balance.text = '₹ ${widget.balance ?? '0.00'}';
    super.initState();
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
            addPaymentAmount(widget.docId.toString());
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
