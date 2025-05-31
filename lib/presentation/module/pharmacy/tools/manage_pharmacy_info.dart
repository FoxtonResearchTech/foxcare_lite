import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/refreshLoading/refreshLoading.dart';
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
  bool searching = false;
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

  Future<void> fetchData({String? pharmacyName}) async {
    try {
      const int batchSize = 10;
      DocumentSnapshot? lastDoc;
      bool hasMore = true;

      List<Map<String, dynamic>> allFetchedData = [];
      int i = 1;

      while (hasMore) {
        Query query = FirebaseFirestore.instance
            .collection('pharmacy')
            .doc('pharmacies')
            .collection('pharmacy')
            .limit(batchSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['pharmacyName']?.toString() ?? '';

          // Case-insensitive match in Dart
          if (pharmacyName == null ||
              pharmacyName.isEmpty ||
              name.toLowerCase().contains(pharmacyName.toLowerCase())) {
            allFetchedData.add({
              'SL No': i++,
              'Name': name,
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
                              title: const CustomText(
                                text: 'Edit Pharmacy',
                                size: 26,
                              ),
                              content: Container(
                                width: 725,
                                height: 550,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SingleChildScrollView(
                                            child: Container(
                                              width: 725,
                                              height: 1000,
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Pharmacy Name',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                pharmacyNameController,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 50),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Hospital Name',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                hospitalName,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomText(
                                                        text: 'Licence Details',
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'DL / No 1',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                dlNo1Controller,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 50),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'DL / No 2',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                dlNo2Controller,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'GST NO',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                gstNoController,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomText(
                                                        text: 'Address',
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Lane 1',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller: lane1,
                                                            hintText: '',
                                                            width: 220,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 25),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Lane 2',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller: lane2,
                                                            hintText: '',
                                                            width: 220,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 25),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Landmark',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                landMark,
                                                            hintText: '',
                                                            width: 225,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'City',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller: city,
                                                            hintText: '',
                                                            width: 220,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 25),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'State',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller: state,
                                                            hintText: '',
                                                            width: 220,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 25),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Pincode',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller: pinCode,
                                                            hintText: '',
                                                            width: 225,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Email-ID',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller: emailId,
                                                            hintText: '',
                                                            width: 220,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 25),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Phone 1',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                phoneNo1,
                                                            hintText: '',
                                                            width: 220,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 25),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Phone 2',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                phoneNo1,
                                                            hintText: '',
                                                            width: 225,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomText(
                                                        text: 'Bank Details',
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Bank Account Number',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                bankAccountNumber,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 50),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Bank Account Name',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                bankAccountName,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'IFSC',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller: ifsc,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 50),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Surf Code',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                surfCode,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Bank Name',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                bankName,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 50),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Branch Name',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                branchName,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Bank Phone No',
                                                            size: 15,
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          PharmacyTextField(
                                                            controller:
                                                                bankPhoneNo,
                                                            hintText: '',
                                                            width: 300,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
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
                                  onPressed: () async {
                                    await updatePharmacyInfo(docId);
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
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: const [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Confirm Deletion'),
                              ],
                            ),
                            content: const Text(
                              'Are you sure you want to delete?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await FirebaseFirestore.instance
                                .collection('pharmacy')
                                .doc('pharmacies')
                                .collection('pharmacy')
                                .doc(doc.id)
                                .delete();

                            Navigator.of(context).pop();

                            fetchData();
                            CustomSnackBar(context,
                                message: 'Pharmacy Deleted',
                                backgroundColor: Colors.green);
                          } catch (e) {
                            CustomSnackBar(context,
                                message: 'Pharmacy not Deleted',
                                backgroundColor: Colors.red);
                          }
                        }
                      },
                      child: const CustomText(text: 'Delete'))
                ],
              ),
            });
          }
        }

        lastDoc = snapshot.docs.last;

        setState(() {
          tableData = List.from(allFetchedData);
        });

        await Future.delayed(const Duration(milliseconds: 100));

        if (snapshot.docs.length < batchSize) {
          hasMore = false;
        }
      }

      if (allFetchedData.isEmpty) {
        print("No records found");
        setState(() {
          tableData = [];
        });
      }
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
              TimeDateWidget(text: 'Manage Pharmacy'),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Pharmacy Name',
                        size: screenWidth * 0.011,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.25,
                        controller: pharmacyName,
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.038),
                      searching
                          ? SizedBox(
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.045,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/button_loading.json',
                                ),
                              ),
                            )
                          : PharmacyButton(
                              height: screenHeight * 0.04,
                              label: 'Search',
                              onPressed: () async {
                                setState(() => searching = true);
                                await fetchData(
                                    pharmacyName: pharmacyName.text);
                                i = 1;
                                setState(() => searching = false);
                              },
                              width: screenWidth * 0.08),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.7),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      PharmacyButton(
                        label: 'Refresh',
                        onPressed: () async {
                          RefreshLoading(
                            context: context,
                            task: () async => await fetchData(),
                          );
                        },
                        height: screenWidth * 0.023,
                        width: screenWidth * 0.08,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              LazyDataTable(
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
