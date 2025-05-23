import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _composition = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _referredByDoctor = TextEditingController();
  final TextEditingController _additionalInformation = TextEditingController();
  String? selectedCategoryFilter;
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
  String? selectedCategory;

  Future<void> updateProduct(String docId) async {
    try {
      Map<String, dynamic> data = {
        'productName': _productName.text,
        'composition': _composition.text,
        'category': selectedCategory,
        'companyName': _companyName.text,
        'referredByDoctor': _referredByDoctor.text,
        'additionalInformation': _additionalInformation.text,
      };
      await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('AddedProducts')
          .doc(docId)
          .update(data);
      clearFields();
      CustomSnackBar(context,
          message: 'Product Updated successfully',
          backgroundColor: Colors.green);
      fetchData();
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed To Add Product', backgroundColor: Colors.red);
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
          'Category': data['category'],
          'Company': data['companyName'],
          'Composition': data['composition'],
          'Action': TextButton(
              onPressed: () {
                final selectedProduct = data;
                final docId = doc.id;

                _productName.text = selectedProduct['productName'] ?? '';
                _composition.text = selectedProduct['composition'] ?? '';
                _companyName.text = selectedProduct['companyName'] ?? '';
                _referredByDoctor.text =
                    selectedProduct['referredByDoctor'] ?? '';
                _additionalInformation.text =
                    selectedProduct['additionalInformation'] ?? '';

                setState(() {
                  selectedCategory = selectedProduct['category'] ?? 'Medicine';
                });

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: CustomText(
                        text: 'Add Product',
                        size: 25,
                      ),
                      content: Container(
                        width: 600,
                        height: 325,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 500,
                                    height: 300,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            PharmacyTextField(
                                              controller: _productName,
                                              hintText: 'Product Name',
                                              width: 200,
                                            ),
                                            SizedBox(
                                              width: 200,
                                              child: PharmacyDropDown(
                                                  label: 'Category',
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
                                                  selectedItem:
                                                      selectedCategory,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedCategory = value;
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            PharmacyTextField(
                                              controller: _composition,
                                              hintText: 'Composition',
                                              width: 200,
                                            ),
                                            PharmacyTextField(
                                              controller: _companyName,
                                              hintText: 'Company Name',
                                              width: 200,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            PharmacyTextField(
                                              controller: _referredByDoctor,
                                              hintText: 'Referred by Doctor',
                                              width: 200,
                                            ),
                                            PharmacyTextField(
                                              controller:
                                                  _additionalInformation,
                                              hintText:
                                                  'Additional Information',
                                              width: 200,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            updateProduct(docId);
                            Navigator.of(context).pop();
                          },
                          child: CustomText(
                            text: 'Submit ',
                            color: AppColors.secondaryColor,
                            size: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: CustomText(
                            text: 'Cancel',
                            color: AppColors.secondaryColor,
                            size: 14,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: CustomText(text: 'Edit')),
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

    filteredProducts = List.from(allProducts);
  }

  void clearFields() {
    _productName.clear();
    _composition.clear();

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
              TimeDateWidget(text: 'Product List'),
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
              CustomDataTable(headers: headers, tableData: filteredProducts),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
