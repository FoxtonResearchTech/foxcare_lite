import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_rx_list.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'doctor_dashboard.dart';
import 'ip_patients_details.dart';

class PharmacyStocks extends StatefulWidget {
  const PharmacyStocks({super.key});

  @override
  State<PharmacyStocks> createState() => _PharmacyStocks();
}

class _PharmacyStocks extends State<PharmacyStocks> {
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

  int selectedIndex = 3;
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _composition = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _hsnCode = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _referredByDoctor = TextEditingController();
  final TextEditingController _additionalInformation = TextEditingController();
  String? selectedCategoryFilter;
  String productName = '';
  String companyName = '';
  String hsnCode = '';

  final List<String> headers = [
    'Product Name',
    'HSN Code',
    'Category',
    'Company',
    'Composition',
    'Type',
  ];

  List<Map<String, dynamic>> allProducts = [];

  List<Map<String, dynamic>> filteredProducts = [];
  String? selectedType;
  String? selectedCategory;

  String? selectedDistributor;
  List<String> distributorsNames = [];
  Future<void> fetchDistributors() async {
    try {
      QuerySnapshot<Map<String, dynamic>> distributorsSnapshot =
          await FirebaseFirestore.instance
              .collection('pharmacy')
              .doc('distributors')
              .collection('distributor')
              .get();
      List<String> distributors = [];

      for (var doc in distributorsSnapshot.docs) {
        distributors.add(doc['distributorName']);
      }
      setState(() {
        distributorsNames = distributors;
      });
    } catch (e) {
      print('Error fetching distributors: $e');
    }
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> stockSnapshot =
          await FirebaseFirestore.instance
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in stockSnapshot.docs) {
        final data = doc.data();
        fetchedData.add({
          'Product Name': data['productName'],
          'HSN Code': data['hsnCode'],
          'Category': data['category'],
          'Company': data['companyName'],
          'Composition': data['composition'],
          'Type': data['type'],
        });
      }

      setState(() {
        allProducts = fetchedData;
        filteredProducts = List.from(allProducts); // Update filtered list too
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDistributors();

    filteredProducts = List.from(allProducts);
  }

  void clearFields() {
    _productName.clear();
    _composition.clear();
    _quantity.clear();
    _hsnCode.clear();
    _companyName.clear();
    _referredByDoctor.clear();
    _additionalInformation.clear();
  }

  void filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        return (selectedCategoryFilter == null ||
                selectedCategoryFilter == 'All' ||
                product['Category'] == selectedCategoryFilter) &&
            (productName.isEmpty ||
                product['Product Name']!
                    .toLowerCase()
                    .contains(productName.toLowerCase())) &&
            (companyName.isEmpty ||
                product['Company']!
                    .toLowerCase()
                    .contains(companyName.toLowerCase())) &&
            (hsnCode.isEmpty ||
                product['HSN Code']!
                    .toLowerCase()
                    .contains(hsnCode.toLowerCase()));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('Reception Dashboard'),
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
                        Color(0xFF21b0d1),
                        Color(0xFF106ac2),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                              text: 'Hi',
                              size: 25,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Row(
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
                        CustomText(
                          text: 'MBBS,MD(General Medicine)',
                          size: 12,
                          color: Colors.white,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 200,
                              height: 25,
                              child: Center(
                                  child: CustomText(
                                text: 'General Medicine',
                                color: Color(0xFF106ac2),
                              )),
                              color: Colors.white,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 10),
                            CustomText(
                              text: '$formattedTime  ',
                              size: 30,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
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
              buildDrawerItem(0, 'Home', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DoctorDashboard()));
              }, Iconsax.mask),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(1, ' OP Patient', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DoctorRxList()));
              }, Iconsax.receipt),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(2, 'IP Patients', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IpPatientsDetails()));
              }, Iconsax.receipt),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(3, 'Pharmacy Stocks', () {}, Iconsax.add_circle),
              Divider(height: 5, color: Colors.white),
              buildDrawerItem(4, 'Logout', () {
                // Handle logout action
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
                decoration: BoxDecoration(
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
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                        image: AssetImage('assets/NIH_Logo.png'))),
              )
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 25,
          color: Color(0xFF106ac2),
          child: Center(
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
              ? const LinearGradient(
                  colors: [Color(0xFF21b0d1), Color(0xFF106ac2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : (hoveredIndex == index
                  ? const LinearGradient(
                      colors: [Color(0xFF42c4e3), Color(0xFF21b0d1)],
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
                : (hoveredIndex == index
                    ? Colors.white
                    : const Color(0xFF106ac2)),
          ),
          title: Text(
            title,
            style: TextStyle(
                color: selectedIndex == index
                    ? Colors.white
                    : (hoveredIndex == index
                        ? Colors.white
                        : const Color(0xFF106ac2)),
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: screenWidth * 0.01, right: screenWidth * 0.01),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      CustomText(
                        text: 'Product List',
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
                        image: DecorationImage(
                            image: AssetImage('assets/foxcare_lite_logo.png'))),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomDropdown(
                    label: 'Select Category',
                    items: const [
                      'All',
                      'Medicine',
                      'Equipment',
                      'Supplements',
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryFilter = value;
                      });
                      filterProducts();
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Product Name',
                    width: screenWidth * 0.20,
                    onChanged: (value) {
                      productName = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'Company Name',
                    width: screenWidth * 0.20,
                    onChanged: (value) {
                      companyName = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'HSN Code',
                    width: screenWidth * 0.10,
                    onChanged: (value) {
                      hsnCode = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomButton(
                    label: 'Search',
                    onPressed: filterProducts,
                    width: screenWidth * 0.1,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              CustomDataTable(
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                headers: headers,
                tableData: filteredProducts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
