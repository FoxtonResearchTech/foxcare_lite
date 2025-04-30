import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/manager/patient_info.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class EditDeletePatientInformation extends StatefulWidget {
  const EditDeletePatientInformation({super.key});

  @override
  State<EditDeletePatientInformation> createState() =>
      _EditDeletePatientInformation();
}

class _EditDeletePatientInformation
    extends State<EditDeletePatientInformation> {
  TextEditingController _opNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  final List<String> headers1 = [
    'OP NO',
    'Name',
    'Place',
    'Phone No',
    'DOB',
    'Edit',
    'Delete',
  ];
  List<Map<String, dynamic>> tableData1 = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData({String? opNumber, String? phoneNumber}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (opNumber != null) {
        query = query.where('opNumber', isEqualTo: opNumber);
      } else if (phoneNumber != null) {
        query = query.where(Filter.or(
          Filter('phone1', isEqualTo: phoneNumber),
          Filter('phone2', isEqualTo: phoneNumber),
        ));
      }
      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        print("No records found");
        setState(() {
          tableData1 = [];
        });
        return;
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('opNumber')) continue;
        fetchedData.add({
          'OP NO': data['opNumber'] ?? 'N/A',
          'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
              .trim(),
          'Place': data['city'] ?? 'N/A',
          'Phone No': data['phone1'] ?? 'N/A',
          'DOB': data['dob'] ?? 'N/A',
          'Edit': TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientInfo(
                      opNumberEdit: data['opNumber'] ?? 'N/A',
                      firstNameEdit: data['firstName'] ?? 'N/A',
                      middleNameEdit: data['middleName'] ?? 'N/A',
                      lastNameEdit: data['lastName'] ?? 'N/A',
                      sexEdit: data['sex'] ?? 'N/A',
                      ageEdit: data['age'] ?? 'N/A',
                      dobEdit: data['dob'] ?? 'N/A',
                      landmarkEdit: data['landmark'] ?? 'N/A',
                      address1Edit: data['address1'] ?? 'N/A',
                      address2Edit: data['address2'] ?? 'N/A',
                      cityEdit: data['city'] ?? 'N/A',
                      stateEdit: data['state'] ?? 'N/A',
                      pincodeEdit: data['pincode'] ?? 'N/A',
                      phone1Edit: data['phone1'] ?? 'N/A',
                      phone2Edit: data['phone2'] ?? 'N/A',
                      bloodGroupEdit: data['bloodGroup'] ?? 'N/A',
                      opAmountEdit: data['opAmount'] ?? 'N/A',
                      opAmountCollectedEdit: data['opAmountCollected'] ?? 'N/A',
                    ),
                  ),
                );
              },
              child: const CustomText(text: 'Edit')),
          'Delete': TextButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Deletion Conformation'),
                      content: Container(
                        width: 100,
                        height: 25,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                                text: 'Are you sure you want to delete ?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('patients')
                                    .doc(data['opNumber'])
                                    .collection('ipPrescription')
                                    .doc()
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection('patients')
                                    .doc(data['opNumber'])
                                    .collection('sampleData')
                                    .doc()
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection('patients')
                                    .doc(data['opNumber'])
                                    .collection('tokens')
                                    .doc()
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection('patients')
                                    .doc(data['opNumber'])
                                    .delete();

                                CustomSnackBar(context,
                                    message: 'Patient Deleted');
                              } catch (e) {
                                print(
                                    'Error updating status for patient ${data['patientID']}: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Failed to update status')),
                                );
                              }
                              Navigator.pop(context);
                            },
                            child: CustomText(text: 'Delete')),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: CustomText(text: 'Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const CustomText(text: 'Delete'))
        });
      }
      setState(() {
        tableData1 = fetchedData;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "Patient Information ",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'OP Number',
                    width: screenWidth * 0.15,
                    controller: _opNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(opNumber: _opNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  CustomTextField(
                    hintText: 'Phone Number',
                    width: screenWidth * 0.15,
                    controller: _phoneNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(phoneNumber: _phoneNumber.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData1,
                headers: headers1,
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                rowColorResolver: (row) {
                  return row['Status'] == 'aborted'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
