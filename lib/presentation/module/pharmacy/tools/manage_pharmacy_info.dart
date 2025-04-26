import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import 'manage_pharmacy_info.dart';

class ManagePharmacyInfo extends StatefulWidget {
  const ManagePharmacyInfo({super.key});

  @override
  State<ManagePharmacyInfo> createState() => _ManagePharmacyInfo();
}

class _ManagePharmacyInfo extends State<ManagePharmacyInfo> {
  TextEditingController pharmacyNameController = TextEditingController();
  TextEditingController hospitalName = TextEditingController();
  TextEditingController dlNo1Controller = TextEditingController();
  TextEditingController expiryDate1Controller = TextEditingController();
  TextEditingController dlNo2Controller = TextEditingController();
  TextEditingController expiryDate2Controller = TextEditingController();
  TextEditingController gstNoController = TextEditingController();
  TextEditingController lane1 = TextEditingController();
  TextEditingController lane2 = TextEditingController();
  TextEditingController landMark = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController phoneNo1 = TextEditingController();
  TextEditingController phoneNO2 = TextEditingController();
  TextEditingController bankAccountNumber = TextEditingController();
  TextEditingController bankAccountName = TextEditingController();
  TextEditingController ifsc = TextEditingController();
  TextEditingController surfCode = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController branchName = TextEditingController();
  TextEditingController bankPhoneNo = TextEditingController();
  TextEditingController pharmacyName = TextEditingController();

  int i = 1;
  final List<String> headers = [
    'SL No',
    'Name',
    'City',
    'Phone Number',
    'Hospital Name',
    'Action',
  ];
  List<Map<String, dynamic>> tableData = [];
  Future<void> updatePharmacyInfo(String docId) async {
    try {
      Map<String, dynamic> data = {
        'pharmacyName': pharmacyNameController.text,
        'hospitalName': hospitalName.text,
        'dlNo1': dlNo1Controller.text,
        'expiryDate1': expiryDate1Controller.text,
        'dlNo2': dlNo2Controller.text,
        'expiryDate2': expiryDate2Controller.text,
        'gstNo': gstNoController.text,
        'lane1': lane1.text,
        'lane2': lane2.text,
        'landMark': landMark.text,
        'city': city.text,
        'state': state.text,
        'pinCode': pinCode.text,
        'emailId': emailId.text,
        'phoneNo1': phoneNo1.text,
        'phoneNO2': phoneNO2.text,
        'bankAccountNumber': bankAccountNumber.text,
        'bankAccountName': bankAccountName.text,
        'ifsc': ifsc.text,
        'surfCode': surfCode.text,
        'bankName': bankName.text,
        'branchName': branchName.text,
        'bankPhoneNo': bankPhoneNo.text,
      };
      await FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('pharmacies')
          .collection('pharmacy')
          .doc(docId)
          .update(data);
      CustomSnackBar(context,
          message: 'Pharmacy Updated successfully',
          backgroundColor: Colors.green);
      fetchData();
      clearFields();
      i = 1;
      Navigator.of(context).pop();
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed To Updated Pharmacy', backgroundColor: Colors.red);
    }
  }

  Future<void> fetchData({
    String? pharmacyName,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('pharmacies')
          .collection('pharmacy');

      if (pharmacyName != null && pharmacyName.isNotEmpty) {
        query = query.where('pharmacyName', isEqualTo: pharmacyName);
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

        fetchedData.add({
          'SL No': i++,
          'Name': data['pharmacyName'],
          'City': data['city'],
          'Phone Number': data['phoneNo1'],
          'Hospital Name': data['hospitalName'],
          'Action': Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    final docId = doc.id;
                    pharmacyNameController.text = data['pharmacyName'];
                    hospitalName.text = data['hospitalName'];
                    dlNo1Controller.text = data['dlNo1'];
                    expiryDate1Controller.text = data['expiryDate1'];
                    dlNo2Controller.text = data['dlNo2'];
                    expiryDate2Controller.text = data['expiryDate2'];
                    gstNoController.text = data['gstNo'];
                    lane1.text = data['lane1'];
                    lane2.text = data['lane2'];
                    landMark.text = data['landMark'];
                    city.text = data['city'];
                    state.text = data['state'];
                    pinCode.text = data['pinCode'];
                    emailId.text = data['emailId'];
                    phoneNo1.text = data['phoneNo1'];
                    phoneNO2.text = data['phoneNO2'];
                    bankAccountNumber.text = data['bankAccountNumber'];
                    bankAccountName.text = data['bankAccountName'];
                    ifsc.text = data['ifsc'];
                    surfCode.text = data['surfCode'];
                    bankName.text = data['bankName'];
                    branchName.text = data['branchName'];
                    bankPhoneNo.text = data['bankPhoneNo'];
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Edit Pharmacy'),
                          content: Container(
                            width: 850,
                            height: 850,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SingleChildScrollView(
                                        child: Container(
                                          width: 850,
                                          height: 850,
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller:
                                                        pharmacyNameController,
                                                    hintText: 'Pharmacy Name',
                                                    width: 300,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: hospitalName,
                                                    hintText: 'Hospital Name',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: dlNo1Controller,
                                                    hintText: 'DL / No 1',
                                                    width: 300,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller:
                                                        expiryDate1Controller,
                                                    hintText: 'Expiry date',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: dlNo2Controller,
                                                    hintText: 'DL / No 2',
                                                    width: 300,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller:
                                                        expiryDate2Controller,
                                                    hintText: 'Expiry date',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: gstNoController,
                                                    hintText: 'GST NO',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 30),
                                              const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomText(
                                                      text: 'Pharmacy Address'),
                                                ],
                                              ),
                                              const SizedBox(height: 30),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: lane1,
                                                    hintText: 'Lane 1',
                                                    width: 300,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: lane2,
                                                    hintText: 'Lane 2',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: landMark,
                                                    hintText: 'Landmark',
                                                    width: 650,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: city,
                                                    hintText: 'City',
                                                    width: 200,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: state,
                                                    hintText: 'State',
                                                    width: 200,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: pinCode,
                                                    hintText: 'Pin code',
                                                    width: 200,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: emailId,
                                                    hintText: 'E-Mail ID',
                                                    width: 200,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: phoneNo1,
                                                    hintText: 'Phone NO 1',
                                                    width: 200,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: phoneNO2,
                                                    hintText: 'Phone Number 2',
                                                    width: 200,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 30),
                                              const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomText(
                                                      text: 'Bank Details'),
                                                ],
                                              ),
                                              const SizedBox(height: 30),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller:
                                                        bankAccountNumber,
                                                    hintText:
                                                        'Bank Account Number',
                                                    width: 300,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: bankAccountName,
                                                    hintText:
                                                        'Bank Account Name',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: ifsc,
                                                    hintText: 'IFSC',
                                                    width: 300,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: surfCode,
                                                    hintText: 'Surf Code',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: bankName,
                                                    hintText: 'Bank Name',
                                                    width: 300,
                                                  ),
                                                  const SizedBox(width: 50),
                                                  CustomTextField(
                                                    controller: branchName,
                                                    hintText: 'Branch Name',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  CustomTextField(
                                                    controller: bankPhoneNo,
                                                    hintText: 'Bank Phone No',
                                                    width: 300,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 50),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                updatePharmacyInfo(docId);
                              },
                              child: CustomText(
                                text: 'Submit ',
                                color: AppColors.secondaryColor,
                                size: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: CustomText(
                                text: 'Cancel',
                                color: AppColors.secondaryColor,
                                size: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const CustomText(text: 'Edit')),
              TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('pharmacy')
                          .doc('pharmacies')
                          .collection('pharmacy')
                          .doc(doc.id)
                          .delete();

                      Navigator.of(context).pop(); // Close dialog

                      fetchData();
                      CustomSnackBar(context,
                          message: 'Pharmacy Deleted',
                          backgroundColor: Colors.green);
                    } catch (e) {
                      CustomSnackBar(context,
                          message: 'Pharmacy not Deleted',
                          backgroundColor: Colors.red);
                    }
                  },
                  child: const CustomText(text: 'Delete'))
            ],
          ),
        });
      }

      setState(() {
        tableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void clearFields() {
    pharmacyNameController.clear();
    hospitalName.clear();
    dlNo1Controller.clear();
    expiryDate1Controller.clear();
    dlNo2Controller.clear();
    expiryDate2Controller.clear();
    gstNoController.clear();
    lane1.clear();
    lane2.clear();
    landMark.clear();
    city.clear();
    state.clear();
    pinCode.clear();
    emailId.clear();
    phoneNo1.clear();
    phoneNO2.clear();
    bankAccountNumber.clear();
    bankAccountName.clear();
    ifsc.clear();
    surfCode.clear();
    bankName.clear();
    branchName.clear();
    bankPhoneNo.clear();
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    pharmacyNameController.dispose();
    hospitalName.dispose();
    dlNo1Controller.dispose();
    expiryDate1Controller.dispose();
    dlNo2Controller.dispose();
    expiryDate2Controller.dispose();
    gstNoController.dispose();
    lane1.dispose();
    lane2.dispose();
    landMark.dispose();
    city.dispose();
    state.dispose();
    pinCode.dispose();
    emailId.dispose();
    phoneNo1.dispose();
    phoneNO2.dispose();
    bankAccountNumber.dispose();
    bankAccountName.dispose();
    ifsc.dispose();
    surfCode.dispose();
    bankName.dispose();
    branchName.dispose();
    bankPhoneNo.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
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
                          text: "Manage Pharmacy",
                          size: screenWidth * 0.0275,
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
                        image: AssetImage('assets/foxcare_lite_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomText(
                    text: 'Pharmacy List :',
                    size: screenWidth * 0.013,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Pharmacy Name',
                    width: screenWidth * 0.25,
                    controller: pharmacyName,
                  ),
                  SizedBox(width: screenHeight * 0.1),
                  CustomButton(
                      height: screenHeight * 0.04,
                      label: 'Search',
                      onPressed: () {
                        fetchData(pharmacyName: pharmacyName.text);
                        i = 1;
                      },
                      width: screenWidth * 0.08)
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
