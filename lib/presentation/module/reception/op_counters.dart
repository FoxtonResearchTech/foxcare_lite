import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/reception/patient_registration.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'admission_status.dart';
import 'doctor_schedule.dart';
import 'ip_admission.dart';
import 'ip_patients_admission.dart';
import 'op_ticket.dart';

class OpCounters extends StatefulWidget {
  const OpCounters({super.key});

  @override
  State<OpCounters> createState() => _OpCountersState();
}

class _OpCountersState extends State<OpCounters> {
  int selectedIndex = 3;
  List<bool> isCheckedList = [false];
  List<String?> selectedActionList = [null];
  List<String> actions = ['Cancel', 'Returned', 'Missing'];
  ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> counterData = [
    {
      'counter': 1,
      'doctor': 'Dr. Rajesh (General Phy)',
      'tokens': [20, 25, 30],
      'patients': [
        {
          'opNumber': 101,
          'name': 'John Doe',
          'age': 35,
          'phone': '1234567890',
          'token': 20
        },
        {
          'opNumber': 102,
          'name': 'Jane Smith',
          'age': 28,
          'phone': '9876543210',
          'token': 25
        },
        {
          'opNumber': 103,
          'name': 'Alice Brown',
          'age': 45,
          'phone': '1122334455',
          'token': 30
        },
      ],
    },
    {
      'counter': 2,
      'doctor': 'Dr. Lekshmi (Cardiology)',
      'tokens': [8, 9, 10],
      'patients': [
        {
          'opNumber': 201,
          'name': 'Bob Johnson',
          'age': 50,
          'phone': '6677889900',
          'token': 9
        },
      ],
    },
    {
      'counter': 3,
      'doctor': 'Dr. Babu (Orthopaedician)',
      'tokens': [2, 4, 19],
      'patients': [
        {
          'opNumber': 301,
          'name': 'Charlie Davis',
          'age': 60,
          'phone': '5566778899',
          'token': 4
        },
      ],
    },
  ];

  List<Map<String, dynamic>> missingTokens = [
    {
      'token': '20',
      'opNumber': 'OP123',
      'name': 'John Doe',
      'age': '45',
      'phone': '1234567890',
      'status': 'Missing', // Default dropdown value
    },
    {
      'token': '25',
      'opNumber': 'OP124',
      'name': 'Jane Doe',
      'age': '30',
      'phone': '0987654321',
      'status': 'Missing', // Default dropdown value
    },
    // Add more token data here...
  ];

  // List to store selected actions for each patient
  List<String?> selectedActions = [];

  @override
  void initState() {
    super.initState();
    // Initialize the selected actions list based on the number of patients
    selectedActions = List<String?>.filled(getTotalPatientCount(), null);
  }

  // Helper method to get the total number of patients
  int getTotalPatientCount() {
    return counterData.fold(0, (sum, counter) {
      // Cast 'patients' to List to ensure Dart understands the type
      List patients = counter['patients'] as List;
      return sum + patients.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(
                'OP Counter ',
                style: TextStyle(
                  fontFamily: 'SanFrancisco',
                ),
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
            child: SingleChildScrollView(
              child: dashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDrawerContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Reception',
            style: TextStyle(
              fontFamily: 'SanFrancisco',
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        // Drawer items here
        buildDrawerItem(0, 'Patient Registration', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PatientRegistration()),
          );
        }, Iconsax.mask),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(1, 'OP Ticket', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OpTicketPage()),
          );
        }, Iconsax.receipt),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(2, 'IP Admission', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => IpAdmissionPage()),
          );
        }, Iconsax.add_circle),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(3, 'OP Counters', () {}, Iconsax.square),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(4, 'Admission Status', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdmissionStatus()),
          );
        }, Iconsax.status),
        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(5, 'Doctor Visit Schedule', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => doctorSchedule()),
          );
        }, Iconsax.hospital),

        const Divider(
          height: 5,
          color: Colors.grey,
        ),
        buildDrawerItem(6, 'Ip Patients Admission', () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => IpPatientsAdmission()),
          );
        }, Icons.approval),
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
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OP Counter Status :',
              style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Text(
                  'Total Counters : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: CustomTextField(
                    hintText: 'Total Counters',
                    width: null,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Total Token Genenrated : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    hintText: 'Total Token Generated',
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  'Waiting Tokens : ',
                  style: TextStyle(
                    fontFamily: 'SanFrancisco',
                  ),
                ),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    hintText: 'Total Waiting Tokens',
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal, // Add horizontal scrolling for tables
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FixedColumnWidth(150.0), // Set fixed width for each column
                  1: FixedColumnWidth(150.0),
                  2: FixedColumnWidth(150.0),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Counter 1',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco',
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Counter 2',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco',
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Counter 3',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco',
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Dr. Rajesh (General Phy)',
                          style: TextStyle(
                            fontFamily: 'SanFrancisco',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Dr. Lekshmi (Cardiology)',
                          style: TextStyle(
                            fontFamily: 'SanFrancisco',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Dr. Babu (Orthopaedician)',
                          style: TextStyle(
                            fontFamily: 'SanFrancisco',
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '5, 20, 25, 30',
                          style: TextStyle(
                            fontFamily: 'SanFrancisco',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '8, 9, 10, 14',
                          style: TextStyle(
                            fontFamily: 'SanFrancisco',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '2, 4, 19, 31',
                          style: TextStyle(
                            fontFamily: 'SanFrancisco',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 30,
            ),

            // List of entries (replacing table)
            SizedBox(height: 20),
            Text(
              'Missing Tokens:',
              style: TextStyle(
                  fontFamily: 'SanFrancisco',
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Wrapping the ListView.builder in a SizedBox to give it constrained width
            SizedBox(
              width: MediaQuery.of(context).size.width /
                  1.4, // Provide a defined width for the ListView
              height: 400.0, // Provide a defined height for the ListView
              child: ListView.builder(
                itemCount: missingTokens.length, // Number of missing tokens
                itemBuilder: (context, index) {
                  final tokenData =
                      missingTokens[index]; // Token data for each row
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        // Token Number
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Token: ${tokenData['token']}',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco', fontSize: 16),
                          ),
                        ),
                        // OP Number
                        Expanded(
                          flex: 1,
                          child: Text(
                            'OP No: ${tokenData['opNumber']}',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco', fontSize: 16),
                          ),
                        ),
                        // Name
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Name: ${tokenData['name']}',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco', fontSize: 16),
                          ),
                        ),
                        // Age
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Age: ${tokenData['age']}',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco', fontSize: 16),
                          ),
                        ),
                        // Phone
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Phone: ${tokenData['phone']}',
                            style: TextStyle(
                                fontFamily: 'SanFrancisco', fontSize: 16),
                          ),
                        ),

                        // Action Dropdown
                        Expanded(
                          flex: 1,
                          child: DropdownButton<String>(
                            value:
                                tokenData['status'], // Default selected value
                            items: ['Missing', 'Not Interested', 'Returned']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontFamily: 'SanFrancisco',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                tokenData['status'] =
                                    newValue; // Update selected value
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
