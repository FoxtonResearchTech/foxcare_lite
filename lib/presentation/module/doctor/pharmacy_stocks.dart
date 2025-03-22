import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_rx_list.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../../../utilities/widgets/snackBar/snakbar.dart';
import '../../../utilities/widgets/table/data_table.dart';
import '../../../utilities/widgets/text/primary_text.dart';
import '../../../utilities/widgets/textField/primary_textField.dart';
import 'ip_patients_details.dart';

class PharmacyStocks extends StatefulWidget {
  const PharmacyStocks({super.key});

  @override
  State<PharmacyStocks> createState() => _PharmacyStocks();
}

class _PharmacyStocks extends State<PharmacyStocks> {
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
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
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
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Doctor - Consultation',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SanFrancisco',
              fontSize: 24,
            ),
          ),
        ),
        buildDrawerItem(0, 'Home', () {}, Iconsax.mask),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(1, ' OP Patient', () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => DoctorRxList()));
        }, Iconsax.receipt),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(2, 'IP Patients', () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => IpPatientsDetails()));
        }, Iconsax.add_circle),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(3, 'Pharmacy Stocks', () {}, Iconsax.add_circle),
        Divider(height: 5, color: Colors.grey),
        buildDrawerItem(4, 'Logout', () {
          // Handle logout action
        }, Iconsax.logout),
      ],
    );
  }

  Widget buildDrawerItem(
      int index, String title, VoidCallback onTap, IconData icon) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor: Colors.blueAccent.shade100,
      // Highlight color for the selected item
      leading: Icon(
        icon, // Replace with actual icons
        color: selectedIndex == index ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
            color: selectedIndex == index ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w700,
            fontFamily: 'SanFrancisco'),
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.01),
          child: Column(
            children: [
              Row(
                children: [
                  CustomText(text: 'Product List', size: screenWidth * 0.012),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
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
              CustomDataTable(headers: headers, tableData: filteredProducts),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
