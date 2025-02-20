import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/new_patient_register_collection.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/management_register_patient.dart';
import 'package:foxcare_lite/presentation/module/management/user/user_account_creation.dart';
import 'package:foxcare_lite/presentation/module/management/wardRoomInformation/ward_rooms.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/colors.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import 'dental_billing.dart';
import 'dental_dashboard.dart';
import 'dental_dr_schedule.dart';
import 'dental_opTickets.dart';
import 'dental_patient_registration.dart';
import 'dental_pending_bills.dart';

class DentalAppointment extends StatefulWidget {
  @override
  State<DentalAppointment> createState() => _DentalAppointment();
}

class _DentalAppointment extends State<DentalAppointment> {
  TextEditingController _changeDate = TextEditingController();
  final dateTime = DateTime.now();
  String formatDate(DateTime dateTime) {
    return dateTime.day.toString().padLeft(2, '0') +
        getDaySuffix(dateTime.day) +
        ' ' +
        DateFormat('MMM').format(dateTime) +
        ' ' +
        dateTime.year.toString();
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _changeDate.text = formatDate(pickedDate); // Update text field
      });
    }
  }

  final appointmentHeaders = [
    'OP No',
    'Patient Name',
    'Schedule',
    'Status',
    'Procedure',
    'Action'
  ];
  final List<Map<String, dynamic>> appointmentTableData = [
    {
      'OP No': '',
      'Patient Name': '',
      'Schedule': '',
      'Status': '',
      'Procedure': '',
      'Action': Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(onPressed: () {}, child: CustomText(text: 'Edit')),
          TextButton(onPressed: () {}, child: CustomText(text: 'Delete')),
          TextButton(onPressed: () {}, child: CustomText(text: 'Confirm'))
        ],
      ),
    },
  ];
  final bookAppointmentHeaders = [
    'OP No',
    'Patient Name',
    'Age',
    'Address',
    'Phone No',
  ];
  final List<Map<String, dynamic>> bookAppointmentTableData = [
    {
      'OP No': '',
      'Patient Name': '',
      'Age': '',
      'Address': '',
      'Phone No': '',
    },
  ];
  int selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    _changeDate.text = formatDate(DateTime.now()); // Set default date
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const CustomText(
                text: 'FoxCare Dental',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: buildDrawerContent(), // Drawer minimized for mobile
            )
          : null, // No drawer for web view (permanently open)
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: buildDrawerContent(), // Sidebar always open for web view
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer content reused for both web and mobile
  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Appointment',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Home', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalDashboard()));
        }, Iconsax.mask),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'Appointment', () {}, Iconsax.receipt),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'Patient Registration', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DentalPatientRegistration()));
        }, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'OP Tickets', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalOptickets()));
        }, Iconsax.square),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(4, ' Billing', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalBilling()));
        }, Iconsax.status),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'DR. Schedule', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalDrSchedule()));
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(6, 'Pending Bills', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DentalPendingBills()));
        }, Iconsax.hospital),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(7, 'Logout', () {
          // Handle logout action
        }, Iconsax.logout),
      ],
    );
  }

  // Helper method to build drawer items with the ability to highlight the selected item
  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor:
          Colors.blueAccent.shade100, // Highlight color for the selected item
      leading: Icon(
        icon, // Replace with actual icons
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'SanFrancisco',
            color: selectedIndex == index ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w700),
      ),
      onTap: () {
        setState(() {
          selectedIndex = index; // Update the selected index
        });
        onTap();
      },
    );
  }

  // The form displayed in the body
  Widget dashboard() {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.025,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.25,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Appointment',
                    size: screenWidth * 0.02,
                  ),
                  CustomButton(
                    label: 'Book New Appointments',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Book Appointment'),
                            content: Container(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.7,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomTextField(
                                          hintText: 'OP Number',
                                          width: screenWidth * 0.1,
                                        ),
                                        CustomButton(
                                          label: 'Search',
                                          onPressed: () {},
                                          width: screenWidth * 0.1,
                                          height: screenHeight * 0.045,
                                        ),
                                        CustomTextField(
                                          hintText: 'Mobile Number',
                                          width: screenWidth * 0.1,
                                        ),
                                        CustomButton(
                                          label: 'Search',
                                          onPressed: () {},
                                          width: screenWidth * 0.1,
                                          height: screenHeight * 0.045,
                                        )
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.08),
                                    CustomDataTable(
                                        headers: bookAppointmentHeaders,
                                        tableData: bookAppointmentTableData),
                                    SizedBox(height: screenHeight * 0.08),
                                    Row(
                                      children: [
                                        CustomTextField(
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
                                          hintText: 'Schedule Date',
                                          width: screenWidth * 0.2,
                                        ),
                                        CustomTextField(
                                          hintText: 'Schedule Time',
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
                                          hintText: 'Common Issue',
                                          width: screenWidth * 0.2,
                                        ),
                                        CustomTextField(
                                          hintText: 'Procedure',
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
                                          hintText: 'Description ',
                                          width: screenWidth * 0.5,
                                          verticalSize: screenHeight * 0.05,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {},
                                child: CustomText(
                                  text: 'Submit ',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: CustomText(
                                  text: 'Cancel',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.05,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    horizontalSize: screenHeight * 0.12,
                    controller: _changeDate,
                    hintText: '',
                    width: screenWidth * 0.2,
                  ),
                  CustomButton(
                    label: 'Change Date',
                    onPressed: () {
                      _selectDate(context, _changeDate);
                    },
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.05,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                  headers: appointmentHeaders, tableData: appointmentTableData),
            ],
          ),
        ),
      ),
    );
  }
}
