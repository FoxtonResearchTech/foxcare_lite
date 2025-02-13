import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String? selectedCategory;
  String productName = '';
  String companyName = '';
  String hsnCode = '';

  final List<String> categories = [
    'All',
    'Medicine',
    'Equipment',
    'Supplements'
  ];

  final List<String> headers = [
    'Product Name',
    'HSN Code',
    'Category',
    'Company',
    'Composition',
    'Type',
    'Action',
  ];

  final List<Map<String, String>> allProducts = [
    {
      'Product Name': 'Paracetamol',
      'HSN Code': '3004',
      'Category': 'Medicine',
      'Company': 'ABC Pharma',
      'Composition': 'Acetaminophen',
      'Type': 'Tablet',
      'Action': '',
    },
    {
      'Product Name': 'Cetirizine ',
      'HSN Code': '3007',
      'Category': 'Medicine',
      'Company': 'ABC Pharma',
      'Composition': 'Acetaminophen',
      'Type': 'Tablet',
      'Action': '',
    },
    {
      'Product Name': 'X-Ray',
      'HSN Code': '9077',
      'Category': 'Equipment',
      'Company': 'XYZ Healthcare',
      'Composition': 'N/A',
      'Type': 'Device',
      'Action': '',
    }, {
      'Product Name': 'Thermometer',
      'HSN Code': '9025',
      'Category': 'Equipment',
      'Company': 'XYZ Healthcare',
      'Composition': 'N/A',
      'Type': 'Device',
      'Action': '',
    },
    {
      'Product Name': 'BP-Monitor',
      'HSN Code': '9000',
      'Category': 'Equipment',
      'Company': 'AAA Healthcare',
      'Composition': 'N/A',
      'Type': 'Device',
      'Action': '',
    },
    {
      'Product Name': 'Vitamin C',
      'HSN Code': '2106',
      'Category': 'Supplements',
      'Company': 'HealthPlus',
      'Composition': 'Ascorbic Acid',
      'Type': 'Tablet',
      'Action': '',
    },
  ];

  List<Map<String, String>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(allProducts);
  }

  void filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        return (selectedCategory == null ||
                selectedCategory == 'All' ||
                product['Category'] == selectedCategory) &&
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              Row(children: [
                CustomText(text: 'Product List', size: screenWidth * 0.012),
              ]),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomDropdown(
                    label: 'Select Category',
                    items: categories,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                      filterProducts();
                    },
                  )
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
}
