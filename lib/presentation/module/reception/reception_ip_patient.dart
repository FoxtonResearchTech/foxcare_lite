import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/patient_history_dialog.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../utilities/constants.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class ReceptionIpPatient extends StatefulWidget {
  final String patientID;
  final String ipNumber;
  final String date;
  final String name;
  final String age;
  final String place;
  final String doctor;
  final String specialization;
  final String dob;
  final String sex;
  final String bloodGroup;
  final String phone1;
  final String phone2;
  final String address;
  final String pincode;
  final String primaryInfo;
  final String temperature;
  final String bloodPressure;
  final String sugarLevel;

  const ReceptionIpPatient({
    Key? key,
    required this.patientID,
    required this.name,
    required this.age,
    required this.place,
    required this.primaryInfo,
    required this.address,
    required this.pincode,
    required this.temperature,
    required this.bloodPressure,
    required this.sugarLevel,
    required this.ipNumber,
    required this.date,
    required this.doctor,
    required this.specialization,
    required this.dob,
    required this.sex,
    required this.bloodGroup,
    required this.phone1,
    required this.phone2,
  }) : super(key: key);
  @override
  State<ReceptionIpPatient> createState() => _ReceptionIpPatient();
}

class _ReceptionIpPatient extends State<ReceptionIpPatient> {
  final dateTime = DateTime.now();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _sugarLevelController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _diagnosisSignsController =
      TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _ipAdmissionTotalAmount = TextEditingController();
  final TextEditingController _ipAdmissionCollected = TextEditingController();
  final TextEditingController _ipAdmissionBalance = TextEditingController();
  final TextEditingController _paymentDetails = TextEditingController();

  String? selectedPaymentMode;

  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();

  int selectedIndex = 1;
  String? selectedValue;
  String? selectedIPAdmissionValue;
  bool _isSwitched = false;

  List<String> roomStatus = [];
  List<String> wardStatus = [];
  List<String> viproomStatus = [];
  List<String> ICUStatus = [];
  String? selectedRoom;

  Future<void> fetchRoomData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('totalRoom')
          .doc('status')
          .get();

      if (doc.exists) {
        setState(() {
          roomStatus = List<String>.from(doc['roomStatus']);
          wardStatus = List<String>.from(doc['wardStatus']);
          viproomStatus = List<String>.from(doc['viproomStatus']);
          ICUStatus = List<String>.from(doc['ICUStatus']);
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> updateRoomAvailability() async {
    try {
      await FirebaseFirestore.instance
          .collection('totalRoom')
          .doc('status')
          .update({
        "roomStatus": roomStatus,
        "ICUStatus": ICUStatus,
        "viproomStatus": viproomStatus,
        "wardStatus": wardStatus,
      });
      CustomSnackBar(context,
          message: 'Room data updated successfully!',
          backgroundColor: Colors.green);
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  @override
  void initState() {
    fetchRoomData();
    _ipAdmissionTotalAmount.addListener(_updateBalance);
    _ipAdmissionCollected.addListener(_updateBalance);
    super.initState();
  }

  void _updateBalance() {
    double totalAmount = double.tryParse(_ipAdmissionTotalAmount.text) ?? 0.0;
    double paidAmount = double.tryParse(_ipAdmissionCollected.text) ?? 0.0;
    double balance = totalAmount - paidAmount;

    _ipAdmissionBalance.text = balance.toStringAsFixed(0);
  }

  @override
  void dispose() {
    super.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _sugarLevelController.dispose();
    _notesController.dispose();
    _diagnosisSignsController.dispose();
    _symptomsController.dispose();
    _scrollController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
  }

  Future<void> _savePrescriptionData() async {
    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('ipPrescription')
          .doc('details')
          .set({
        'date': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'time': dateTime.hour.toString() +
            '-' +
            dateTime.minute.toString().padLeft(2, '0') +
            '-' +
            dateTime.second.toString().padLeft(2, '0'),
        'ipAdmissionTotalAmount': _ipAdmissionTotalAmount.text,
        'ipAdmissionCollected': _ipAdmissionCollected.text,
        'ipAdmissionBalance': _ipAdmissionBalance.text,
        'ipAdmission': {
          'roomType': selectedIPAdmissionValue,
          'roomNumber': selectedRoom
        },
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('ipTickets')
          .doc(widget.ipNumber)
          .set({
        'roomAllotmentDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'ipAdmissionTotalAmount': _ipAdmissionTotalAmount.text,
        'ipAdmissionCollected': _ipAdmissionCollected.text,
        'ipAdmissionBalance': _ipAdmissionBalance.text,
        'ipAdmission': {
          'roomType': selectedIPAdmissionValue,
          'roomNumber': selectedRoom
        },
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientID)
          .collection('ipTickets')
          .doc(widget.ipNumber)
          .collection('ipAdmitPayments')
          .doc()
          .set({
        'collected': _ipAdmissionCollected.text,
        'balance': _ipAdmissionBalance.text,
        'paymentMode': selectedPaymentMode,
        'paymentDetails': _paymentDetails.text,
        'payedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
        'payedTime': dateTime.hour.toString() +
            ':' +
            dateTime.minute.toString().padLeft(2, '0'),
      });

      CustomSnackBar(context,
          message: 'Details saved successfully!',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to save: $e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: "IP Patient Prescription",
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: AppColors.appBar,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.06,
            left: screenWidth * 0.07,
            right: screenWidth * 0.07,
            bottom: screenWidth * 0.08,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'IP Admission ',
                    size: screenWidth * 0.03,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'IP Ticket No : ',
                        size: screenWidth * 0.02,
                      ),
                      CustomText(
                        text: widget.ipNumber,
                        size: screenWidth * 0.02,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomText(
                        text: 'Admission Date : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: dateTime.year.toString() +
                            '-' +
                            dateTime.month.toString().padLeft(2, '0') +
                            '-' +
                            dateTime.day.toString().padLeft(2, '0'),
                        size: screenWidth * 0.015,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      CustomText(
                        text: 'Admission Time : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: dateTime.hour.toString() +
                            ':' +
                            dateTime.minute.toString().padLeft(2, '0') +
                            ':' +
                            dateTime.second.toString().padLeft(2, '0'),
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  CustomText(
                    text: 'Doctor Name : ',
                    size: screenWidth * 0.015,
                  ),
                  CustomText(
                    text: widget.doctor,
                    size: screenWidth * 0.015,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  CustomText(
                    text: 'Specialization : ',
                    size: screenWidth * 0.015,
                  ),
                  CustomText(
                    text: widget.specialization,
                    size: screenWidth * 0.015,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                children: [
                  CustomText(
                    text: 'Patient Information ',
                    size: screenWidth * 0.023,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Name : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.name,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.2),
                  Row(
                    children: [
                      CustomText(
                        text: 'OP Number : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.patientID,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Age : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.age,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  Row(
                    children: [
                      CustomText(
                        text: 'DOB : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.dob,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  Row(
                    children: [
                      CustomText(
                        text: 'Sex : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.sex,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  Row(
                    children: [
                      CustomText(
                        text: 'Blood Group : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.bloodGroup,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Phone 1 : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.phone1,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  Row(
                    children: [
                      CustomText(
                        text: 'Phone 2 : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.phone2,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: 'Address : ',
                        size: screenWidth * 0.015,
                      ),
                      CustomText(
                        text: widget.address,
                        size: screenWidth * 0.015,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Finding & Treatment ',
                        size: screenWidth * 0.02,
                        color: AppColors.blue,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      CustomText(
                        text: '         * ${widget.primaryInfo}',
                        size: screenWidth * 0.015,
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomText(
                    text: 'Admissions : ',
                    size: screenWidth * 0.02,
                    color: AppColors.blue,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.03),
                    child: SizedBox(
                      height: screenHeight * 0.04,
                      width: screenWidth * 0.2,
                      child: CustomDropdown(
                        label: 'Select IP Admission Room',
                        items: ['All', 'Room', 'Ward Room', 'VIP Room', 'ICU'],
                        selectedItem: selectedIPAdmissionValue,
                        onChanged: (value) {
                          setState(() {
                            selectedIPAdmissionValue = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(child: getAdmissionWidget()),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Container(
                padding: EdgeInsets.only(left: screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Payments',
                      color: AppColors.blue,
                      size: screenWidth * 0.02,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 50, right: 50),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Total Amount ',
                                    size: screenWidth * 0.012,
                                  ),
                                  SizedBox(height: 7),
                                  CustomTextField(
                                    hintText: '',
                                    controller: _ipAdmissionTotalAmount,
                                    width: screenWidth * 0.2,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Collected ',
                                    size: screenWidth * 0.012,
                                  ),
                                  SizedBox(height: 7),
                                  CustomTextField(
                                    hintText: '',
                                    controller: _ipAdmissionCollected,
                                    width: screenWidth * 0.2,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Balance ',
                                    size: screenWidth * 0.012,
                                  ),
                                  SizedBox(height: 7),
                                  CustomTextField(
                                    hintText: '',
                                    controller: _ipAdmissionBalance,
                                    width: screenWidth * 0.2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Payment Mode ',
                                    size: screenWidth * 0.012,
                                  ),
                                  SizedBox(height: 7),
                                  SizedBox(
                                    width: screenWidth * 0.2,
                                    child: CustomDropdown(
                                      width: screenWidth * 0.05,
                                      label: '',
                                      items: Constants.paymentMode,
                                      onChanged: (value) {
                                        setState(
                                          () {
                                            selectedPaymentMode = value;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'Payment Details ',
                                    size: screenWidth * 0.012,
                                  ),
                                  SizedBox(height: 7),
                                  CustomTextField(
                                    hintText: '',
                                    controller: _paymentDetails,
                                    width: screenWidth * 0.2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: CustomButton(
                    label: 'Admit',
                    onPressed: () {
                      final collectedAmountText =
                          _ipAdmissionCollected.text.trim();
                      final totalAmountText =
                          _ipAdmissionTotalAmount.text.trim();
                      if (selectedIPAdmissionValue == 'All') {
                        CustomSnackBar(context,
                            message: 'Please Choose Valid Room',
                            backgroundColor: Colors.orange);

                        return;
                      }
                      // Validate collected amount is not empty
                      if (collectedAmountText.isEmpty) {
                        CustomSnackBar(context,
                            message: 'Please enter the collected amount',
                            backgroundColor: Colors.orange);

                        return;
                      }

                      // Validate total amount is not empty (optional)
                      if (totalAmountText.isEmpty) {
                        CustomSnackBar(context,
                            message: 'Please enter the total amount',
                            backgroundColor: Colors.orange);

                        return;
                      }

                      // Parse and validate amount
                      final collectedAmount =
                          double.tryParse(collectedAmountText);
                      if (collectedAmount == null || collectedAmount < 0) {
                        CustomSnackBar(context,
                            message: 'Please enter a valid collected amount',
                            backgroundColor: Colors.orange);

                        return;
                      }
                      _savePrescriptionData();
                      updateRoomAvailability();
                    },
                    width: screenWidth * 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAdmissionWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    switch (selectedIPAdmissionValue) {
      case 'All':
        return Container(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.03),
              Scrollbar(
                controller: _scrollController, // Attach the ScrollController
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    children: [
                      Text(
                        'Rooms : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Wrap(
                        spacing: 10, // Horizontal spacing between rooms
                        runSpacing: 10, // Vertical spacing between rooms
                        children: List.generate(roomStatus.length, (index) {
                          return GestureDetector(
                            onTap: (roomStatus[index] == "booked" ||
                                    roomStatus[index] == "available")
                                ? null
                                : () {
                                    // Handle booking or toggling logic
                                  },
                            child: InkWell(
                              child: Container(
                                width: 50,
                                // Set a fixed width for each room box
                                height: 60,
                                // Set a fixed height for each room box
                                decoration: BoxDecoration(
                                  color: roomStatus[index] == 'booked'
                                      ? AppColors.blue
                                      : roomStatus[index] == 'available'
                                          ? AppColors.lightBlue
                                          : AppColors.roomDisabled,

                                  borderRadius: BorderRadius.circular(2),
                                  //border: Border.all(color: Colors.black, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SanFrancisco',
                                      ),
                                    ),
                                    Icon(
                                      Icons.bed_sharp,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                // if (roomStatus[index] != 'disabled') {
                                //   setState(() {
                                //     roomStatus[index] = 'booked';
                                //   });
                                //   print('${index + 1} pressed');
                                // }
                              },
                              onDoubleTap: () {
                                // if (roomStatus[index] != 'disabled') {
                                //   setState(() {
                                //     roomStatus[index] = 'available';
                                //   });
                                // }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Scrollbar(
                thumbVisibility: true,
                controller: _scrollController1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController1,
                  child: Row(
                    children: [
                      Text(
                        'Wards : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Wrap(
                        spacing: 10, // Horizontal spacing between rooms
                        runSpacing: 10, // Vertical spacing between rooms
                        children: List.generate(wardStatus.length, (index) {
                          return GestureDetector(
                            onTap: (wardStatus[index] == "booked" ||
                                    wardStatus[index] == "available")
                                ? null
                                : () {
                                    // Handle booking or toggling logic
                                  },
                            child: InkWell(
                              child: Container(
                                width: 50,
                                // Set a fixed width for each room box
                                height: 60,
                                // Set a fixed height for each room box
                                decoration: BoxDecoration(
                                  color: wardStatus[index] == 'booked'
                                      ? AppColors.blue
                                      : wardStatus[index] == 'available'
                                          ? AppColors.lightBlue
                                          : AppColors.roomDisabled,
                                  borderRadius: BorderRadius.circular(2),
                                  //border: Border.all(color: Colors.black, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SanFrancisco',
                                      ),
                                    ),
                                    Icon(
                                      Icons.bed_sharp,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                // if (wardStatus[index] != 'disabled') {
                                //   setState(() {
                                //     wardStatus[index] = 'booked';
                                //   });
                                //   print('${index + 1} pressed');
                                // }
                              },
                              onDoubleTap: () {
                                // if (wardStatus[index] != 'disabled') {
                                //   setState(() {
                                //     wardStatus[index] = 'available';
                                //   });
                                // }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Scrollbar(
                thumbVisibility: true,
                controller: _scrollController2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController2,
                  child: Row(
                    children: [
                      Text(
                        'VIP Rooms : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                      Wrap(
                        spacing: 10, // Horizontal spacing between rooms
                        runSpacing: 10, // Vertical spacing between rooms
                        children: List.generate(viproomStatus.length, (index) {
                          return GestureDetector(
                            onTap: (viproomStatus[index] == "booked" ||
                                    viproomStatus[index] == "available")
                                ? null
                                : () {
                                    // Handle booking or toggling logic
                                  },
                            child: InkWell(
                              child: Container(
                                width: 50,
                                // Set a fixed width for each room box
                                height: 60,
                                // Set a fixed height for each room box
                                decoration: BoxDecoration(
                                  color: viproomStatus[index] == 'booked'
                                      ? AppColors.blue
                                      : viproomStatus[index] == 'available'
                                          ? AppColors.lightBlue
                                          : AppColors.roomDisabled,
                                  borderRadius: BorderRadius.circular(2),
                                  //border: Border.all(color: Colors.black, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SanFrancisco',
                                      ),
                                    ),
                                    Icon(
                                      Icons.bed_sharp,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                // if (viproomStatus[index] != 'disabled') {
                                //   setState(() {
                                //     viproomStatus[index] = 'booked';
                                //   });
                                //   print('${index + 1} pressed');
                                // }
                              },
                              onDoubleTap: () {
                                // if (viproomStatus[index] != 'disabled') {
                                //   setState(() {
                                //     viproomStatus[index] = 'available';
                                //   });
                                // }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Scrollbar(
                thumbVisibility: true,
                controller: _scrollController3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController3,
                  child: Row(
                    children: [
                      Text(
                        'ICU : ',
                        style: TextStyle(
                          fontFamily: 'SanFrancisco',
                        ),
                      ),
                      SizedBox(
                        width: 45,
                      ),
                      Wrap(
                        spacing: 10, // Horizontal spacing between rooms
                        runSpacing: 10, // Vertical spacing between rooms
                        children: List.generate(ICUStatus.length, (index) {
                          return GestureDetector(
                            onTap: (ICUStatus[index] == "booked" ||
                                    ICUStatus[index] == "available")
                                ? null
                                : () {
                                    // Handle booking or toggling logic
                                  },
                            child: InkWell(
                              child: Container(
                                width: 50,
                                // Set a fixed width for each room box
                                height: 60,
                                // Set a fixed height for each room box
                                decoration: BoxDecoration(
                                  color: ICUStatus[index] == 'booked'
                                      ? AppColors.blue
                                      : ICUStatus[index] == 'available'
                                          ? AppColors.lightBlue
                                          : AppColors.roomDisabled,
                                  borderRadius: BorderRadius.circular(2),
                                  //border: Border.all(color: Colors.black, width: 1),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SanFrancisco',
                                      ),
                                    ),
                                    Icon(
                                      Icons.bed_sharp,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                // if (ICUStatus[index] != 'disabled') {
                                //   setState(() {
                                //     ICUStatus[index] = 'booked';
                                //   });
                                //   print('${index + 1} pressed');
                                // }
                              },
                              onDoubleTap: () {
                                // if (ICUStatus[index] != 'disabled') {
                                //   setState(() {
                                //     ICUStatus[index] = 'available';
                                //   });
                                // }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        );
      case 'Room':
        return Scrollbar(
          controller: _scrollController, // Attach the ScrollController
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: [
                Text(
                  'Rooms : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Wrap(
                  spacing: 10, // Horizontal spacing between rooms
                  runSpacing: 10, // Vertical spacing between rooms
                  children: List.generate(roomStatus.length, (index) {
                    return GestureDetector(
                      onTap: (roomStatus[index] == "booked" ||
                              roomStatus[index] == "available")
                          ? null
                          : () {
                              // Handle booking or toggling logic
                            },
                      child: InkWell(
                        child: Container(
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
                          // Set a fixed height for each room box
                          decoration: BoxDecoration(
                            color: roomStatus[index] == 'booked'
                                ? AppColors.blue
                                : roomStatus[index] == 'available'
                                    ? AppColors.lightBlue
                                    : AppColors.roomDisabled,
                            borderRadius: BorderRadius.circular(2),
                            //border: Border.all(color: Colors.black, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SanFrancisco',
                                ),
                              ),
                              Icon(
                                Icons.bed_sharp,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (roomStatus[index] != 'disabled') {
                            setState(() {
                              roomStatus[index] = 'booked';
                              selectedRoom = (index + 1).toString();
                            });
                            print('${index + 1} pressed');
                          }
                        },
                        onDoubleTap: () {
                          if (roomStatus[index] != 'disabled') {
                            setState(() {
                              roomStatus[index] = 'available';
                            });
                          }
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      case 'Ward Room':
        return Scrollbar(
          thumbVisibility: true,
          controller: _scrollController1,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController1,
            child: Row(
              children: [
                Text(
                  'Wards : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Wrap(
                  spacing: 10, // Horizontal spacing between rooms
                  runSpacing: 10, // Vertical spacing between rooms
                  children: List.generate(wardStatus.length, (index) {
                    return GestureDetector(
                      onTap: (wardStatus[index] == "booked" ||
                              wardStatus[index] == "available")
                          ? null
                          : () {
                              // Handle booking or toggling logic
                            },
                      child: InkWell(
                        child: Container(
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
                          // Set a fixed height for each room box
                          decoration: BoxDecoration(
                            color: wardStatus[index] == 'booked'
                                ? AppColors.blue
                                : wardStatus[index] == 'available'
                                    ? AppColors.lightBlue
                                    : AppColors.roomDisabled,
                            borderRadius: BorderRadius.circular(2),
                            //border: Border.all(color: Colors.black, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SanFrancisco',
                                ),
                              ),
                              Icon(
                                Icons.bed_sharp,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (wardStatus[index] != 'disabled') {
                            setState(() {
                              wardStatus[index] = 'booked';
                              selectedRoom = (index + 1).toString();
                            });
                            print('${index + 1} pressed');
                          }
                        },
                        onDoubleTap: () {
                          if (wardStatus[index] != 'disabled') {
                            setState(() {
                              wardStatus[index] = 'available';
                            });
                          }
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      case 'VIP Room':
        return Scrollbar(
          thumbVisibility: true,
          controller: _scrollController2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController2,
            child: Row(
              children: [
                Text(
                  'VIP Rooms : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
                Wrap(
                  spacing: 10, // Horizontal spacing between rooms
                  runSpacing: 10, // Vertical spacing between rooms
                  children: List.generate(viproomStatus.length, (index) {
                    return GestureDetector(
                      onTap: (viproomStatus[index] == "booked" ||
                              viproomStatus[index] == "available")
                          ? null
                          : () {
                              // Handle booking or toggling logic
                            },
                      child: InkWell(
                        child: Container(
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
                          // Set a fixed height for each room box
                          decoration: BoxDecoration(
                            color: viproomStatus[index] == 'booked'
                                ? AppColors.blue
                                : viproomStatus[index] == 'available'
                                    ? AppColors.lightBlue
                                    : AppColors.roomDisabled,
                            borderRadius: BorderRadius.circular(2),
                            //border: Border.all(color: Colors.black, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SanFrancisco',
                                ),
                              ),
                              Icon(
                                Icons.bed_sharp,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (viproomStatus[index] != 'disabled') {
                            setState(() {
                              viproomStatus[index] = 'booked';
                              selectedRoom = (index + 1).toString();
                            });
                            print('${index + 1} pressed');
                          }
                        },
                        onDoubleTap: () {
                          if (viproomStatus[index] != 'disabled') {
                            setState(() {
                              viproomStatus[index] = 'available';
                            });
                          }
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      case 'ICU':
        return Scrollbar(
          thumbVisibility: true,
          controller: _scrollController3,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController3,
            child: Row(
              children: [
                Text(
                  'ICU : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
                SizedBox(
                  width: 45,
                ),
                Wrap(
                  spacing: 10, // Horizontal spacing between rooms
                  runSpacing: 10, // Vertical spacing between rooms
                  children: List.generate(ICUStatus.length, (index) {
                    return GestureDetector(
                      onTap: (ICUStatus[index] == "booked" ||
                              ICUStatus[index] == "available")
                          ? null
                          : () {
                              // Handle booking or toggling logic
                            },
                      child: InkWell(
                        child: Container(
                          width: 50,
                          // Set a fixed width for each room box
                          height: 60,
                          // Set a fixed height for each room box
                          decoration: BoxDecoration(
                            color: ICUStatus[index] == 'booked'
                                ? AppColors.blue
                                : ICUStatus[index] == 'available'
                                    ? AppColors.lightBlue
                                    : AppColors.roomDisabled,
                            borderRadius: BorderRadius.circular(2),
                            //border: Border.all(color: Colors.black, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SanFrancisco',
                                ),
                              ),
                              Icon(
                                Icons.bed_sharp,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (ICUStatus[index] != 'disabled') {
                            setState(() {
                              ICUStatus[index] = 'booked';
                              selectedRoom = (index + 1).toString();
                            });
                            print('${index + 1} pressed');
                          }
                        },
                        onDoubleTap: () {
                          if (ICUStatus[index] != 'disabled') {
                            setState(() {
                              ICUStatus[index] = 'available';
                            });
                          }
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      default:
        return Container(); // Empty by default
    }
  }
}
