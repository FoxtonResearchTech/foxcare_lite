import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
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
    'Action',
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

  Future<void> updateProduct(String docId) async {
    try {
      Map<String, dynamic> data = {
        'productName': _productName.text,
        'composition': _composition.text,
        'quantity': _quantity.text,
        'type': selectedType,
        'category': selectedCategory,
        'distributor': selectedDistributor,
        'hsnCode': _hsnCode.text,
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
          'HSN Code': data['hsnCode'],
          'Category': data['category'],
          'Company': data['companyName'],
          'Composition': data['composition'],
          'Type': data['type'],
          'Action': TextButton(
              onPressed: () {
                final selectedProduct = data;
                final docId = doc.id;

                _productName.text = selectedProduct['productName'] ?? '';
                _hsnCode.text = selectedProduct['hsnCode'] ?? '';
                _composition.text = selectedProduct['composition'] ?? '';
                _companyName.text = selectedProduct['companyName'] ?? '';
                _quantity.text = selectedProduct['quantity'] ?? '';
                _referredByDoctor.text =
                    selectedProduct['referredByDoctor'] ?? '';
                _additionalInformation.text =
                    selectedProduct['additionalInformation'] ?? '';

                // Assign dropdown values
                setState(() {
                  selectedType = selectedProduct['type'] ?? 'Tablet';
                  selectedCategory = selectedProduct['category'] ?? 'Medicine';
                  selectedDistributor =
                      selectedProduct['distributor'] ?? distributorsNames.first;
                });

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Add Product'),
                      content: Container(
                        width: 600,
                        height: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 550,
                                    height: 400,
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
                                            CustomTextField(
                                              controller: _productName,
                                              hintText: 'Product Name',
                                              width: 200,
                                            ),
                                            CustomTextField(
                                              controller: _quantity,
                                              hintText: 'Quantity',
                                              width: 200,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller: _composition,
                                              hintText: 'Composition',
                                              width: 200,
                                            ),
                                            SizedBox(
                                              width: 200,
                                              child: CustomDropdown(
                                                label: 'Type',
                                                items: const [
                                                  'Tablet',
                                                  'Device',
                                                  'Injection'
                                                ],
                                                selectedItem: selectedType,
                                                onChanged: (value) {
                                                  setState(
                                                    () {
                                                      selectedType = value;
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: CustomDropdown(
                                                  label: 'Category',
                                                  items: const [
                                                    'Medicine',
                                                    'Equipment',
                                                    'Supplements'
                                                  ],
                                                  selectedItem:
                                                      selectedCategory,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedCategory = value;
                                                    });
                                                  }),
                                            ),
                                            CustomTextField(
                                              controller: _hsnCode,
                                              hintText: 'HSN Code',
                                              width: 200,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextField(
                                              controller: _companyName,
                                              hintText: 'Company Name',
                                              width: 200,
                                            ),
                                            SizedBox(
                                              width: 200,
                                              child: CustomDropdown(
                                                label: 'Distributor',
                                                items: distributorsNames,
                                                selectedItem:
                                                    selectedDistributor,
                                                onChanged: (value) {
                                                  setState(
                                                    () {
                                                      selectedDistributor =
                                                          value;
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        CustomTextField(
                                          controller: _referredByDoctor,
                                          hintText: 'Referred by Doctor',
                                          width: 300,
                                        ),
                                        CustomTextField(
                                          controller: _additionalInformation,
                                          hintText: 'Additional Information',
                                          width: 300,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
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
}
