import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:foxcare_lite/presentation/module/doctor/rx_prescription.dart';
import 'package:foxcare_lite/presentation/module/reception/appointments_op_ticket.dart';
import 'package:foxcare_lite/utilities/widgets/drawer/reception/reception_drawer.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/doctor/doctor_module_drawer.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';

class BookAppointments extends StatefulWidget {
  const BookAppointments({super.key});

  @override
  State<BookAppointments> createState() => _BookAppointments();
}

class _BookAppointments extends State<BookAppointments> {
  TextEditingController dateSearch = TextEditingController();

  TextEditingController opNumberSearch = TextEditingController();
  TextEditingController phoneNumberSearch = TextEditingController();

  TextEditingController appointmentDate = TextEditingController();
  TextEditingController appointmentTime = TextEditingController();

  final TextEditingController doctorName = TextEditingController();
  final TextEditingController specialization = TextEditingController();
  final TextEditingController patientName = TextEditingController();

  int selectedIndex = 6;

  String? selectedDoctor;
  bool isLoading = false;

  DateTime now = DateTime.now();

  final List<String> headers1 = [
    'SL No',
    'Date',
    'Time',
    'OP No',
    'Patient Name',
    'Phone',
    'City',
    'Doctor Name',
    'Specialization',
    'Action',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  Timer? _timer;
  int i = 1;
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm a');
  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Map<String, String> doctorSpecializationMap = {};
  List<String> doctorNames = [];

  @override
  void initState() {
    super.initState();
    fetchData(date: today);
    fetchDoctorAndSpecialization();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   fetchData();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> searchPatients(
      String opNumber,
      String phoneNumber, {
        int pageSize = 20,
        Duration delayBetweenPages = const Duration(milliseconds: 100),
      }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final lowerOp = opNumber.trim().toLowerCase();
    final lowerPhone = phoneNumber.trim().toLowerCase();
    DocumentSnapshot? lastDoc;
    DocumentSnapshot? matchedDoc;

    while (true) {
      Query query = firestore.collection('patients').limit(pageSize);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docOp = data['opNumber']?.toString().toLowerCase();
        final docPhone1 = data['phone1']?.toString().toLowerCase();
        final docPhone2 = data['phone2']?.toString().toLowerCase();

        if (docOp == lowerOp || docPhone1 == lowerPhone || docPhone2 == lowerPhone) {
          matchedDoc = doc;
          break;
        }
      }

      if (matchedDoc != null) break;

      lastDoc = snapshot.docs.last;
      await Future.delayed(delayBetweenPages);
    }

    if (matchedDoc != null) {
      final data = matchedDoc.data() as Map<String, dynamic>;
      setState(() {
        patientName.text = data['firstName'] ?? '';
        opNumberSearch.text = data['opNumber'] ?? '';
      });
    } else {
      setState(() {
        patientName.clear();
        opNumberSearch.clear();
      });
    }
  }


  Future<void> fetchDoctorAndSpecialization() async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      QuerySnapshot<Map<String, dynamic>> doctorsSnapshot =
          await FirebaseFirestore.instance
              .collection('employees')
              .where('roles', isEqualTo: 'Doctor')
              .get();

      if (doctorsSnapshot.docs.isNotEmpty) {
        doctorSpecializationMap.clear();
        doctorNames.clear();

        for (var doc in doctorsSnapshot.docs) {
          final data = doc.data();
          final doctor = data['firstName'] + ' ' + data['lastName'] ?? '';
          final spec = data['specialization'] ?? '';

          if (doctor.isNotEmpty) {
            doctorSpecializationMap[doctor] = spec;
            doctorNames.add(doctor);
          }
        }

        // Set default selected doctor and specialization
        final defaultDoctor = doctorNames.first;
        setState(() {
          selectedDoctor = defaultDoctor;
          doctorName.text = defaultDoctor;
          specialization.text = doctorSpecializationMap[defaultDoctor] ?? '';
        });
      } else {
        setState(() {
          doctorNames.clear();
          selectedDoctor = '';
          doctorName.text = '';
          specialization.text = '';
        });
      }
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<void> fetchData({String? date}) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        try {
          final appointmentDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('appointments')
              .doc('appointment')
              .get();

          final appointmentData = appointmentDoc.data();

          if (date != null && appointmentData?['appointmentDate'] != date) {
            continue;
          }

          fetchedData.add({
            'SL No': i++,
            'OP No': data['opNumber'] ?? 'N/A',
            'Date': appointmentData?['appointmentDate'] ?? 'N/A',
            'Time': appointmentData?['appointmentTime'] ?? 'N/A',
            'Patient Name': data['firstName'] ?? 'N/A',
            'Phone': data['phone1'] ?? 'N/A',
            'City': data['city'] ?? 'N/A',
            'Doctor Name': data['doctorName'] ?? 'N/A',
            'Specialization': data['specialization'] ?? 'N/A',
            'Action': Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AppointmentsOpTicket(
                                  patientId: data['opNumber'],
                                )));
                  },
                  child: CustomText(
                    text: 'Create',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: CustomText(
                    text: 'Delete',
                  ),
                ),
              ],
            )
          });
        } catch (e) {
          print('Error fetching appointment for patient ${doc.id}: $e');
        }
      }

      fetchedData.sort((a, b) {
        final dateTimeA = dateFormat.parse('${a['Date']} ${a['Time']}');
        final dateTimeB = dateFormat.parse('${b['Date']} ${b['Time']}');
        return dateTimeA.compareTo(dateTimeB);
      });

      setState(() {
        tableData1 = fetchedData;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  Future<void> saveAppointmentData(String patientID) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection('patients')
          .doc(patientID)
          .collection('appointments')
          .doc('appointment')
          .set({
        'appointmentDate': appointmentDate.text,
        'appointmentTime': appointmentTime.text,
        'doctorName': doctorName.text,
        'specialization': specialization.text,
      });
      clearFields();

      CustomSnackBar(context,
          message: 'Appointment booked successfully!',
          backgroundColor: Colors.green);
    } catch (e) {
      print('Error saving appointment: $e');
      CustomSnackBar(context,
          message: 'Failed to book appointment. Please try again later.',
          backgroundColor: Colors.red);
    }
  }

  void clearFields() {
    appointmentDate.clear();
    appointmentTime.clear();
    doctorName.clear();
    specialization.clear();
    patientName.clear();
    opNumberSearch.clear();
    phoneNumberSearch.clear();
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(
            now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
      );
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Doctor Dashboard'),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ReceptionDrawer(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300,
              color: Colors.blue.shade100,
              child: ReceptionDrawer(
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
            left: screenWidth * 0.02,
            right: screenWidth * 0.02,
            bottom: screenWidth * 0.1,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Book Appointments',
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
                  CustomTextField(
                    onTap: () => _selectDate(context, dateSearch),
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                    controller: dateSearch,
                    icon: Icon(Icons.date_range_outlined),
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  isLoading
                      ? SizedBox(
                    width: screenWidth * 0.04,
                    height: screenWidth * 0.04,
                    child: Lottie.asset(
                      'assets/button_loading.json',
                      repeat: true,
                    ),
                  )
                      : CustomButton(
                    label: 'Search',
                    onPressed: () async {
                      if (isLoading) return; // prevent double clicks
                      setState(() => isLoading = true);

                      await fetchData(date: dateSearch.text);
                      i = 1;

                      setState(() => isLoading = false);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.03,
                  ),


                  Expanded(child: SizedBox()),
                  CustomButton(
                    label: 'Book Appointments',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Book Appointment'),
                            content: Container(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.4,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomTextField(
                                          controller: opNumberSearch,
                                          hintText: 'OP Number',
                                          width: screenWidth * 0.1,
                                        ),
                                        CustomButton(
                                          label: 'Search',
                                          onPressed: () async {
                                            await searchPatients(
                                                opNumberSearch.text,
                                                phoneNumberSearch.text);
                                          },
                                          width: screenWidth * 0.1,
                                          height: screenHeight * 0.045,
                                        ),
                                        CustomTextField(
                                          controller: phoneNumberSearch,
                                          hintText: 'Mobile Number',
                                          width: screenWidth * 0.1,
                                        ),
                                        CustomButton(
                                          label: 'Search',
                                          onPressed: () async {
                                            await searchPatients(
                                                opNumberSearch.text,
                                                phoneNumberSearch.text);
                                          },
                                          width: screenWidth * 0.1,
                                          height: screenHeight * 0.045,
                                        )
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.08),
                                    Row(
                                      children: [
                                        CustomTextField(
                                          controller: patientName,
                                          hintText: 'Name',
                                          width: screenWidth * 0.2,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.04),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(
                                          controller: appointmentDate,
                                          hintText: 'Schedule Date',
                                          width: screenWidth * 0.2,
                                          icon: Icon(Icons.date_range_outlined),
                                          onTap: () => _selectDate(
                                              context, appointmentDate),
                                        ),
                                        CustomTextField(
                                          controller: appointmentTime,
                                          hintText: 'Schedule Time',
                                          icon:
                                              Icon(Icons.access_time_outlined),
                                          width: screenWidth * 0.2,
                                          onTap: () => _selectTime(
                                              context, appointmentTime),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.04),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomDropdown(
                                          width: 0.2,
                                          label: 'Doctor',
                                          items: doctorNames,
                                          selectedItem: selectedDoctor,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedDoctor = value;
                                              doctorName.text = value!;
                                              specialization.text =
                                                  doctorSpecializationMap[
                                                          value] ??
                                                      '';
                                            });
                                          },
                                        ),
                                        CustomTextField(
                                          controller: specialization,
                                          hintText: 'Specialization',
                                          width: screenWidth * 0.2,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.04),
                                  ],
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  await saveAppointmentData(
                                      opNumberSearch.text);
                                },
                                child: CustomText(
                                  text: 'Book Appointment ',
                                  color: AppColors.blue,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  clearFields();
                                  Navigator.of(context).pop();
                                },
                                child: CustomText(
                                  text: 'Cancel',
                                  color: AppColors.blue,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    width: screenWidth * 0.175,
                    height: screenWidth * 0.035,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              LazyDataTable(
                columnWidths: {
                  0: FixedColumnWidth(screenWidth * 0.04),
                  1: FixedColumnWidth(screenWidth * 0.07),
                  2: FixedColumnWidth(screenWidth * 0.06),
                  3: FixedColumnWidth(screenWidth * 0.08),
                  4: FixedColumnWidth(screenWidth * 0.1),
                  5: FixedColumnWidth(screenWidth * 0.05),
                  6: FixedColumnWidth(screenWidth * 0.05),
                  7: FixedColumnWidth(screenWidth * 0.085),
                  8: FixedColumnWidth(screenWidth * 0.1),
                  9: FixedColumnWidth(screenWidth * 0.1),
                },
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                tableData: tableData1,
                headers: headers1,
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
