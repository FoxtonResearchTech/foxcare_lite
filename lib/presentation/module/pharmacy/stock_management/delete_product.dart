import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
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

  final List<String> headers = [
    'Product Name',
    'Category',
    'Company',
    'Composition',
    'Action',
  ];

  List<Map<String, dynamic>> allProducts = [];

  List<Map<String, dynamic>> filteredProducts = [];
  Future<void> fetchData() async {
    try {
      const int batchSize = 20;
      List<Map<String, dynamic>> allFetchedData = [];
      QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;

      bool hasMore = true;

      while (hasMore) {
        Query<Map<String, dynamic>> query = FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .limit(batchSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data();
          allFetchedData.add({
            'id': doc.id,
            'Product Name': data['productName'],
            'HSN Code': data['hsnCode'],
            'Category': data['category'],
            'Company': data['companyName'],
            'Composition': data['composition'],
            'Action': TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Confirm Bill Submission'),
                      ],
                    ),
                    content: const Text(
                      'Are you sure you want to submit the bill?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('stock')
                        .doc('Products')
                        .collection('AddedProducts')
                        .doc(doc.id)
                        .delete();

                    Navigator.of(context).pop();
                    fetchData(); // Reload data
                    CustomSnackBar(context,
                        message: 'Product Deleted',
                        backgroundColor: Colors.green);
                  } catch (e) {
                    CustomSnackBar(context,
                        message: 'Product not Deleted',
                        backgroundColor: Colors.red);
                  }
                }
              },
              child: const CustomText(
                text: 'Delete',
              ),
            ),
          });
        }

        // Update the UI incrementally after each batch
        setState(() {
          allProducts.addAll(allFetchedData);
          filteredProducts = List.from(allProducts);
        });

        allFetchedData.clear(); // clear current batch
        lastDoc = snapshot.docs.last;

        await Future.delayed(
            const Duration(milliseconds: 100)); // Optional delay
      }
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
                    .contains(companyName.toLowerCase()));
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
          padding: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              TimeDateWidget(text: 'Delete Product'),
              Row(
                children: [
                  PharmacyDropDown(
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
                  PharmacyTextField(
                    hintText: 'Product Name',
                    width: screenWidth * 0.20,
                    onChanged: (value) {
                      productName = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  PharmacyTextField(
                    hintText: 'Company Name',
                    width: screenWidth * 0.20,
                    onChanged: (value) {
                      companyName = value;
                      filterProducts();
                    },
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  PharmacyButton(
                    label: 'Search',
                    onPressed: filterProducts,
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.045,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              LazyDataTable(headers: headers, tableData: filteredProducts),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
