import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProduct();
}

class _AddProduct extends State<AddProduct> {
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _composition = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _hsnCode = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _referredByDoctor = TextEditingController();
  final TextEditingController _additionalInformation = TextEditingController();

  final List<String> headers = [
    'Product Name',
    'HSN Code',
    'Category',
    'Company',
    'Composition',
    'Type',
  ];
  final List<Map<String, dynamic>> tableData = [
    {
      'Product Name': '',
      'HSN Code': '',
      'Category': '',
      'Company': '',
      'Composition': '',
      'Type': '',
    },
  ];
  List<String> distributorsNames = [];
  String? selectedType;
  String? selectedCategory;
  String? selectedDistributor;
  Future<void> addProduct() async {
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
          .doc()
          .set(data);
      clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product Added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed To Add Product"),
        backgroundColor: Colors.red,
      ));
    }
  }

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
      print(distributorsNames);
    } catch (e) {
      print('Error fetching distributors: $e');
    }
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

  @override
  void initState() {
    super.initState();
    fetchDistributors();
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
            top: screenHeight * 0.05,
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Add Product',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    hintText: 'Select Category',
                    width: screenWidth * 0.25,
                    icon: Icon(Icons.arrow_drop_down_sharp),
                  ),
                  CustomButton(
                    label: 'Add',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Add Product'),
                            content: Container(
                              width: screenWidth * 0.5,
                              height: screenHeight * 0.5,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenWidth * 0.5,
                                          height: screenHeight * 0.5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    controller: _productName,
                                                    hintText: 'Product Name',
                                                    width: screenWidth * 0.25,
                                                  ),
                                                  CustomTextField(
                                                    controller: _quantity,
                                                    hintText: 'Quantity',
                                                    width: screenWidth * 0.15,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    controller: _composition,
                                                    hintText: 'Composition',
                                                    width: screenWidth * 0.25,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.15,
                                                    child: CustomDropdown(
                                                      label: 'Type',
                                                      items: const [
                                                        'Tablet',
                                                        'Device',
                                                        'Injection'
                                                      ],
                                                      selectedItem:
                                                          selectedType,
                                                      onChanged: (value) {
                                                        setState(
                                                          () {
                                                            selectedType =
                                                                value;
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.15,
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
                                                            selectedCategory =
                                                                value;
                                                          });
                                                        }),
                                                  ),
                                                  CustomTextField(
                                                    controller: _hsnCode,
                                                    hintText: 'HSN Code',
                                                    width: screenWidth * 0.15,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomTextField(
                                                    controller: _companyName,
                                                    hintText: 'Company Name',
                                                    width: screenWidth * 0.25,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.15,
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
                                                width: screenWidth * 0.25,
                                              ),
                                              CustomTextField(
                                                controller:
                                                    _additionalInformation,
                                                hintText:
                                                    'Additional Information',
                                                width: screenWidth * 0.25,
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
                                onPressed: () => addProduct(),
                                child: CustomText(
                                  text: 'Submit ',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: CustomText(
                                  text: 'Cancel',
                                  color: AppColors.secondaryColor,
                                  size: screenWidth * 0.01,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    width: 100,
                    height: 40,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Product Name',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'Company Name',
                    width: screenWidth * 0.20,
                  ),
                  SizedBox(width: screenHeight * 0.3),
                  CustomTextField(
                    hintText: 'HSN Code',
                    width: screenWidth * 0.10,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              CustomDataTable(headers: headers, tableData: tableData),
              SizedBox(height: screenHeight * 0.06),
            ],
          ),
        ),
      ),
    );
  }
}
