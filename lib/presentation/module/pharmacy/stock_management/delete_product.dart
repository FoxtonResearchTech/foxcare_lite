import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/dropDown/primary_dropDown.dart';
import '../tools/manage_pharmacy_info.dart';

class DeleteProduct extends StatefulWidget {
  const DeleteProduct({super.key});

  @override
  State<DeleteProduct> createState() => _DeleteProduct();
}

class _DeleteProduct extends State<DeleteProduct> {
  String? selectedCategory;
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
    'Action',
  ];

  List<Map<String, dynamic>> allProducts = [];

  List<Map<String, dynamic>> filteredProducts = [];
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
          'id': doc.id, // Store document ID for deletion
          'Product Name': data['productName'],
          'HSN Code': data['hsnCode'],
          'Category': data['category'],
          'Company': data['companyName'],
          'Composition': data['composition'],
          'Type': data['type'],
          'Action': TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Deletion Confirmation'),
                    content: const CustomText(
                        text: 'Are you sure you want to delete?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('stock')
                                .doc('Products')
                                .collection('AddedProducts')
                                .doc(doc.id)
                                .delete();

                            Navigator.of(context).pop(); // Close dialog

                            fetchData();
                            CustomSnackBar(context,
                                message: 'Product Deleted',
                                backgroundColor: Colors.green);
                          } catch (e) {
                            CustomSnackBar(context,
                                message: 'Product not Deleted',
                                backgroundColor: Colors.red);
                          }
                        },
                        child: const CustomText(text: 'Delete'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const CustomText(text: 'Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const CustomText(text: 'Delete'),
          ),
        });
      }

      setState(() {
        allProducts = fetchedData;
        filteredProducts = List.from(allProducts);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
                CustomText(text: 'Delete Product', size: screenWidth * 0.012),
              ]),
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
                        selectedCategory = value;
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
}
