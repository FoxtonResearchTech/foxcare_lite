import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_dashboard.dart';
import 'package:foxcare_lite/presentation/module/doctor/pharmacy_stocks.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/doctor/doctor_module_drawer.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import '../doctor/ip_prescription.dart';
import 'doctor_rx_list.dart';

class IpPatientsDetails extends StatefulWidget {
  final String doctorName;
  const IpPatientsDetails({Key? key, required this.doctorName})
      : super(key: key);

  @override
  State<IpPatientsDetails> createState() => _IpPatientsDetails();
}

class _IpPatientsDetails extends State<IpPatientsDetails> {
  TextEditingController _ipNumber = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  DateTime now = DateTime.now();

  final List<String> headers1 = [
    'Token NO',
    'IP NO',
    'Name',
    'Age',
    'Place',
    'Primary Info',
    'Action',
    'Abscond',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;
  int selectedIndex = 2;
  String? roomNumber;
  String? roomType;

  @override
  void initState() {
    super.initState();
    fetchData();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   fetchData();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> endIP(String ipNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(ipNumber)
          .collection('ipPrescription')
          .doc('details')
          .get();

      String roomNumber = querySnapshot['ipAdmission']['roomNumber'];
      String roomType = querySnapshot['ipAdmission']['roomType'];

      int index = int.parse(roomNumber) - 1;

      DocumentReference totalRoomRef =
          FirebaseFirestore.instance.collection('totalRoom').doc('status');

      final totalRoomSnapshot = await totalRoomRef.get();

      if (totalRoomSnapshot.exists) {
        Map<String, dynamic> data =
            totalRoomSnapshot.data() as Map<String, dynamic>;

        List<bool> roomStatus = List<bool>.from(data['roomStatus']);
        List<bool> wardStatus = List<bool>.from(data['wardStatus']);
        List<bool> viproomStatus = List<bool>.from(data['viproomStatus']);
        List<bool> ICUStatus = List<bool>.from(data['ICUStatus']);

        if (roomType == "Ward Room") {
          wardStatus[index] = false;
        } else if (roomType == "VIP Room") {
          viproomStatus[index] = false;
        } else if (roomType == "ICU") {
          ICUStatus[index] = false;
        } else if (roomType == "Room") {
          roomStatus[index] = false;
        }

        await totalRoomRef.update({
          "roomStatus": roomStatus,
          "wardStatus": wardStatus,
          "viproomStatus": viproomStatus,
          "ICUStatus": ICUStatus,
        });

        CustomSnackBar(context, message: 'IP Ended Successfully');
      } else {
        CustomSnackBar(context, message: 'Total Room Data Not Found');
      }
    } catch (e) {
      CustomSnackBar(context, message: 'Cannot End IP');
      print("Error updating totalRoom: $e");
    }
  }

  Future<void> fetchData({String? ipNumber, String? phoneNumber}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (ipNumber != null) {
        query = query.where('ipNumber', isEqualTo: ipNumber);
      } else if (phoneNumber != null) {
        query = query.where(Filter.or(
          Filter('phone1', isEqualTo: phoneNumber),
          Filter('phone2', isEqualTo: phoneNumber),
        ));
      }

      final QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('ipNumber')) continue;
        if (!data.containsKey('tokenDate')) continue;

        String tokenNo = '';
        bool hasIpPrescription = false;

        try {
          final tokenSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('tokens')
              .doc('currentToken')
              .get();

          if (tokenSnapshot.exists) {
            final tokenData = tokenSnapshot.data();
            if (tokenData != null && tokenData['tokenNumber'] != null) {
              tokenNo = tokenData['tokenNumber'].toString();
            }
          }
          final ipPrescriptionSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .get();

          if (ipPrescriptionSnapshot.docs.isNotEmpty) {
            hasIpPrescription = true;
          }
        } catch (e) {
          print('Error fetching tokenNo for patient ${doc.id}: $e');
        }

        fetchedData.add({
          'Token NO': tokenNo,
          'OP NO': data['opNumber'] ?? 'N/A',
          'IP NO': data['ipNumber'] ?? 'N/A',
          'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
              .trim(),
          'Age': data['age'] ?? 'N/A',
          'Place': data['state'] ?? 'N/A',
          'Address': data['address1'] ?? 'N/A',
          'PinCode': data['pincode'] ?? 'N/A',
          'Status': data['status'] ?? 'N/A',
          'Primary Info': data['otherComments'] ?? 'N/A',
          'Action': hasIpPrescription
              ? TextButton(
                  onPressed: () {
                    endIP(data['ipNumber']);
                  },
                  child: const CustomText(text: 'End IP'),
                )
              : TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IpPrescription(
                          patientID: data['opNumber'] ?? 'N/A',
                          ipNumber: data['ipNumber'] ?? 'N/A',
                          name:
                              '${data['firstName'] ?? ''} ${data['lastName'] ?? 'N/A'}'
                                  .trim(),
                          age: data['age'] ?? 'N/A',
                          place: data['state'] ?? 'N/A',
                          address: data['address1'] ?? 'N/A',
                          pincode: data['pincode'] ?? 'N/A',
                          primaryInfo: data['otherComments'] ?? 'N/A',
                          temperature: data['temperature'] ?? 'N/A',
                          bloodPressure: data['bloodPressure'] ?? 'N/A',
                          sugarLevel: data['bloodSugarLevel'] ?? 'N/A',
                          phone1: data['phone1'],
                          phone2: data['phone2'],
                          sex: data['sex'],
                          bloodGroup: data['bloodGroup'],
                          firstName: data['firstName'],
                          lastName: data['lastName'],
                          dob: data['dob'],
                          doctorName: widget.doctorName,
                          date: data['tokenDate'],
                        ),
                      ),
                    );
                  },
                  child: const CustomText(text: 'Create')),
          'Abscond': TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(data['ipNumber'])
                      .update({'status': 'abscond'});

                  CustomSnackBar(context, message: 'Status updated to aborted');
                } catch (e) {
                  print(
                      'Error updating status for patient ${data['patientID']}: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update status')),
                  );
                }
              },
              child: const CustomText(text: 'Abort'))
        });
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['Token NO']) ?? 0;
        int tokenB = int.tryParse(b['Token NO']) ?? 0;
        return tokenA.compareTo(tokenB);
      });

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
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text(
                'OP Ticket Dashboard',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: DoctorModuleDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No AppBar for web view
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Sidebar width for larger screens
              color: Colors.blue.shade100,
              child: DoctorModuleDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: dashboard()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.03,
            right: screenWidth * 0.03,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'IP Prescription',
                        size: screenWidth * .04,
                      ),
                      CustomText(
                        text: 'Waiting Que',
                        size: screenWidth * .02,
                      ),
                    ],
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.15,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        image: const DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomText(
                    text: 'Dept : General Medicine',
                    size: screenWidth * .015,
                    color: AppColors.blue,
                  ),
                  SizedBox(width: screenWidth * 0.08),
                  CustomText(
                    text: 'Counter A',
                    size: screenWidth * .015,
                    color: AppColors.blue,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    hintText: 'IP Number',
                    width: screenWidth * 0.15,
                    controller: _ipNumber,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(ipNumber: _ipNumber.text);
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
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                tableData: tableData1,
                headers: headers1,
                rowColorResolver: (row) {
                  return row['Status'] == 'aborted'
                      ? Colors.red.shade200
                      : Colors.transparent;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
