import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/pharmacyInformation/pharmacy_total_sales.dart';
import 'package:foxcare_lite/presentation/module/management/accountsInformation/surgery_ot_icu_collection.dart';
import 'package:foxcare_lite/presentation/module/management/generalInformation/general_information_op_Ticket.dart';
import 'package:foxcare_lite/presentation/module/management/patientsInformation/management_register_patient.dart';
import 'package:foxcare_lite/presentation/module/management/user/user_account_creation.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:foxcare_lite/utilities/widgets/image/custom_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/colors.dart';
import '../../../../utilities/widgets/buttons/primary_button.dart';
import '../../../../utilities/widgets/drawer/management/accounts/management_accounts_drawer.dart';
import '../../../../utilities/widgets/payment/payment_dialog.dart';
import '../../../../utilities/widgets/table/data_table.dart';
import '../../../../utilities/widgets/text/primary_text.dart';
import '../../../../utilities/widgets/textField/primary_textField.dart';
import '../management_dashboard.dart';
import 'hospital_direct_purchase.dart';
import 'hospital_direct_purchase_still_pending.dart';
import 'ip_admission_collection.dart';
import 'ip_admit.dart';
import 'ip_admit_list.dart';
import 'lab_collection.dart';
import 'new_patient_register_collection.dart';
import 'op_ticket_collection.dart';
import 'other_expense.dart';

class IpAdmissionCollection extends StatefulWidget {
  @override
  State<IpAdmissionCollection> createState() => _IpAdmissionCollection();
}

class _IpAdmissionCollection extends State<IpAdmissionCollection> {
  // To store the index of the selected drawer item
  int selectedIndex = 2;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  int hoveredIndex = -1;
  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  DateTime now = DateTime.now();
  final List<String> headers = [
    'OP Ticket',
    'IP No',
    'IP Admission Date',
    'Name',
    'City',
    'Doctor Name',
    'Total Amount',
    'Collected',
    'Balance',
    'Pay'
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData(
      {String? singleDate, String? fromDate, String? toDate}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('patients');

      if (singleDate != null) {
        query = query.where('date', isEqualTo: singleDate);
      } else if (fromDate != null && toDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: fromDate)
            .where('date', isLessThanOrEqualTo: toDate);
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
        if (!data.containsKey('ipNumber')) continue;

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
          print('Error fetching token No for patient ${doc.id}: $e');
        }

        if (hasIpPrescription) {
          DocumentSnapshot detailsDoc = await FirebaseFirestore.instance
              .collection('patients')
              .doc(doc.id)
              .collection('ipPrescription')
              .doc('details')
              .get();

          Map<String, dynamic>? detailsData = detailsDoc.exists
              ? detailsDoc.data() as Map<String, dynamic>?
              : null;
          String ipAdmissionTotalAmountStr =
              detailsData?['ipAdmissionTotalAmount'] ?? '0';
          String ipAdmissionCollectedStr =
              detailsData?['ipAdmissionCollected'] ?? '0';
          String ipAdmissionDate = detailsData?['date'] ?? 'N/A';

          double ipAdmissionTotalAmount =
              double.tryParse(ipAdmissionTotalAmountStr) ?? 0;
          double ipAdmissionCollected =
              double.tryParse(ipAdmissionCollectedStr) ?? 0;

          double balance = ipAdmissionTotalAmount - ipAdmissionCollected;

          fetchedData.add({
            'OP Ticket': tokenNo,
            'IP No': data['ipNumber']?.toString() ?? 'N/A',
            'IP Admission Date': ipAdmissionDate,
            'Name': '${data['firstName'] ?? 'N/A'} ${data['lastName'] ?? 'N/A'}'
                .trim(),
            'City': data['city']?.toString() ?? 'N/A',
            'Doctor Name': data['doctorName']?.toString() ?? 'N/A',
            'Total Amount': ipAdmissionTotalAmountStr,
            'Collected': ipAdmissionCollectedStr,
            'Balance': balance,
            'Pay': TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PaymentDialog(
                        patientID: data['opNumber'],
                        firstName: data['firstName'],
                        lastName: data['lastName'],
                        city: data['city'],
                        balance: balance.toString());
                  },
                );
              },
              child: CustomText(text: 'Pay'),
            ),
          });
        }
      }

      fetchedData.sort((a, b) {
        int tokenA = int.tryParse(a['OP Ticket'].toString()) ?? 0;
        int tokenB = int.tryParse(b['OP Ticket'].toString()) ?? 0;
        return tokenA.compareTo(tokenB);
      });

      setState(() {
        tableData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data: $e');
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  int _totalAmountCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Total Amount'];
        if (value == null) return sum;
        if (value is String) {
          value = int.tryParse(value) ?? 0;
        }
        return sum + (value as int);
      },
    );
  }

  int _totalCollected() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Collected'];
        if (value == null) return sum;
        if (value is String) {
          value = int.tryParse(value) ?? 0;
        }
        return sum + (value as int);
      },
    );
  }

  int _totalBalance() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Balance'];
        if (value == null) return sum;
        // Convert string to double safely
        if (value is String) {
          value = double.tryParse(value) ?? 0.0;
        }
        // Ensure value is double before conversion to int
        if (value is double) {
          value = value.toInt();
        }
        return sum + (value as int);
      },
    );
  }

  @override
  void initState() {
    fetchData();
    _totalAmountCollected();
    _totalCollected();
    _totalBalance();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
    _toDateController.dispose();
    _fromDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: CustomText(
                text: 'Accounts Information',
              ),
            )
          : null, // No AppBar for web view
      drawer: isMobile
          ? Drawer(
              child: ManagementAccountsDrawer(
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
              width: 300, // Fixed width for the sidebar
              color: Colors.blue.shade100,
              child: ManagementAccountsDrawer(
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
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDrawerContent() {
    String formattedTime = DateFormat('h:mm a').format(now);
    String formattedDate =
        '${getDayWithSuffix(now.day)} ${DateFormat('MMMM').format(now)}';
    String formattedYear = DateFormat('y').format(now);
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Container(
                height: 225,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lightBlue,
                        AppColors.blue,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Hi',
                              size: 25,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            CustomText(
                              text: 'Dr.Ramesh',
                              size: 30,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const CustomText(
                          text: 'MBBS,MD(General Medicine)',
                          size: 12,
                          color: Colors.white,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 200,
                              height: 25,
                              color: Colors.white,
                              child: Center(
                                  child: CustomText(
                                text: 'General Medicine',
                                color: AppColors.blue,
                              )),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            CustomText(
                              text: '$formattedTime  ',
                              size: 30,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: formattedDate,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                CustomText(
                                  text: formattedYear,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        )
                      ]),
                ),
              ),
              buildDrawerItem(0, 'New Patients Register Collection', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewPatientRegisterCollection()));
              }, Iconsax.mask),
              Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(1, 'OP Ticket Collection', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OpTicketCollection()));
              }, Iconsax.receipt),
              Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(
                  2, 'IP Admission Collection', () {}, Iconsax.add_circle),
              Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(3, 'Pharmacy Collection', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PharmacyTotalSales()));
              }, Iconsax.square),
              Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(4, 'Hospital Direct Purchase', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HospitalDirectPurchase()));
              }, Iconsax.status),
              Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(5, 'Hospital Direct Purchase Pending Still', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HospitalDirectPurchaseStillPending()));
              }, Iconsax.hospital),
              const Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(6, 'Other Expense', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OtherExpense()));
              }, Iconsax.hospital),
              const Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(7, 'Surgery | OT | ICU | Observation Collection',
                  () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SurgeryOtIcuCollection()));
              }, Iconsax.hospital),
              const Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(8, 'Lab Collection', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LabCollection()));
              }, Iconsax.hospital),
              const Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(9, 'IP Admit', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IpAdmit()));
              }, Iconsax.hospital),
              const Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(10, 'IP Admit List', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IpAdmitList()));
              }, Iconsax.hospital),
              const Divider(
                height: 5,
                color: Colors.grey,
              ),
              buildDrawerItem(11, 'Back To Management Dashboard', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManagementDashboard()));
              }, Iconsax.logout),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 45, right: 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: AssetImage('assets/hospital_logo_demo.png'))),
              ),
              SizedBox(
                width: 2.5,
                height: 50,
                child: Container(
                  color: Colors.grey,
                ),
              ),
              Container(
                width: 100,
                height: 50,
                decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: AssetImage('assets/NIH_Logo.png'))),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 25,
          color: AppColors.blue,
          child: const Center(
            child: CustomText(
              text: 'Main Road, Trivandrum-690001',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredIndex = -1;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: selectedIndex == index
              ? LinearGradient(
                  colors: [
                    AppColors.lightBlue,
                    AppColors.blue,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : (hoveredIndex == index
                  ? LinearGradient(
                      colors: [
                        AppColors.lightBlue,
                        AppColors.blue,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null),
          color: selectedIndex == index || hoveredIndex == index
              ? null
              : Colors.transparent,
        ),
        child: ListTile(
          selected: selectedIndex == index,
          selectedTileColor: Colors.transparent,
          leading: Icon(
            icon,
            color: selectedIndex == index
                ? Colors.white
                : (hoveredIndex == index ? Colors.white : AppColors.blue),
          ),
          title: Text(
            title,
            style: TextStyle(
                color: selectedIndex == index
                    ? Colors.white
                    : (hoveredIndex == index ? Colors.white : AppColors.blue),
                fontWeight: FontWeight.w700,
                fontFamily: 'SanFrancisco'),
          ),
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            onTap();
          },
        ),
      ),
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
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            bottom: screenWidth * 0.01,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.07),
                    child: Column(
                      children: [
                        CustomText(
                          text: "IP Admission Collection ",
                          size: screenWidth * .015,
                        ),
                      ],
                    ),
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
                    onTap: () => _selectDate(context, _dateController),
                    icon: Icon(Icons.date_range),
                    controller: _dateController,
                    hintText: 'Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(singleDate: _dateController.text);
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomText(text: 'OR'),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _fromDateController),
                    icon: Icon(Icons.date_range),
                    controller: _fromDateController,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomTextField(
                    onTap: () => _selectDate(context, _toDateController),
                    icon: Icon(Icons.date_range),
                    controller: _toDateController,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                  ),
                  SizedBox(width: screenHeight * 0.02),
                  CustomButton(
                    label: 'Search',
                    onPressed: () {
                      fetchData(
                        fromDate: _fromDateController.text,
                        toDate: _toDateController.text,
                      );
                    },
                    width: screenWidth * 0.08,
                    height: screenWidth * 0.02,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              const Row(
                children: [CustomText(text: 'Collection Report Of Date')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                headerBackgroundColor: AppColors.blue,
                headerColor: Colors.white,
                tableData: tableData,
                headers: headers,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: screenWidth * 0.38),
                    CustomText(
                      text: 'Total : ',
                    ),
                    SizedBox(width: screenWidth * 0.086),
                    CustomText(
                      text: '${_totalAmountCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.08),
                    CustomText(
                      text: '${_totalCollected()}',
                    ),
                    SizedBox(width: screenWidth * 0.083),
                    CustomText(
                      text: '${_totalBalance()}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
