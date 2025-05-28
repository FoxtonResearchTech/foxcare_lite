import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/module/doctor/doctor_rx_list.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../utilities/widgets/buttons/primary_button.dart';
import '../../../utilities/widgets/drawer/doctor/doctor_module_drawer.dart';
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
  DateTime now = DateTime.now();

  int selectedIndex = 3;
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _composition = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _referredByDoctor = TextEditingController();
  final TextEditingController _additionalInformation = TextEditingController();
  String? selectedCategoryFilter;
  String productName = '';
  String companyName = '';

  final List<String> headers = [
    'Product Name',
    'Composition',
    'Category',
    'Company',
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
      List<Map<String, dynamic>> fetchedData = [];
      DocumentSnapshot? lastDoc;
      const int pageSize = 20;

      while (true) {
        Query<Map<String, dynamic>> query = FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .limit(pageSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          break; // No more documents to fetch
        }

        for (var doc in snapshot.docs) {
          final data = doc.data();
          fetchedData.add({
            'Product Name': data['productName'],
            'HSN Code': data['hsnCode'],
            'Quantity': data['quantity'],
            'Category': data['category'],
            'Company': data['companyName'],
            'Composition': data['composition'],
            'Type': data['type'],
          });
        }

        lastDoc = snapshot.docs.last;
        setState(() {
          allProducts = fetchedData;
          filteredProducts = List.from(allProducts);
        });
        // Optional delay between pages
        await Future.delayed(const Duration(milliseconds: 100));
      }
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
                    .contains(companyName.toLowerCase()));
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
              child: DoctorModuleDrawer(
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
                      'Tablets',
                      'Capsules',
                      'Powders',
                      'Solutions',
                      'Suspensions',
                      'Topical Medicines',
                      'Suppository',
                      'Injections',
                      'Inhales',
                      'Patches',
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
                  CustomButton(
                    label: 'Search',
                    onPressed: filterProducts,
                    width: screenWidth * 0.1,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              LazyDataTable(
                headerColor: Colors.white,
                headerBackgroundColor: AppColors.blue,
                headers: headers,
                tableData: filteredProducts,
              ),
              SizedBox(height: screenHeight * 0.05)
            ],
          ),
        ),
      ),
    );
  }
}
