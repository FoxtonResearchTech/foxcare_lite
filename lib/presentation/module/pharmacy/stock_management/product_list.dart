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
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/refreshLoading/refreshLoading.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _composition = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _additionalInformation = TextEditingController();
  String? selectedCategoryFilter;
  String productName = '';
  String companyName = '';
  List<String> doctors = [];
  String? selectedDoctor;
  bool isFiltering = false;
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
  void fetchDoctors() async {
    final employeesSnapshot =
        await FirebaseFirestore.instance.collection('employees').get();

    for (var doc in employeesSnapshot.docs) {
      if (doc['roles'] == 'Doctor') {
        final firstName = doc['firstName'] ?? '';
        final lastName = doc['lastName'] ?? '';
        final doctorName = '$firstName $lastName';

        if (!doctors.contains(doctorName)) {
          setState(() {
            doctors.add(doctorName);
          });
        }
      }
    }
  }

  Future<void> updateProduct(String docId) async {
    try {
      Map<String, dynamic> data = {
        'productName': _productName.text,
        'composition': _composition.text,
        'category': selectedCategory,
        'companyName': _companyName.text,
        'referredByDoctor': selectedDoctor,
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
      final CollectionReference productsCollection = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('AddedProducts');

      const int batchSize = 20;
      DocumentSnapshot? lastDoc;
      bool moreData = true;

      List<Map<String, dynamic>> fetchedData = [];

      while (moreData) {
        Query query = productsCollection.limit(batchSize);
        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isEmpty) {
          moreData = false;
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

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
                selectedDoctor = selectedProduct['referredByDoctor'] ?? '';
                _additionalInformation.text =
                    selectedProduct['additionalInformation'] ?? '';

                setState(() {
                  selectedCategory = selectedProduct['category'] ?? 'Medicine';
                });

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: CustomText(text: 'Add Product', size: 25),
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
                                    width: 600,
                                    height: 325,
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
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text: 'Product Name',
                                                    size: 20),
                                                SizedBox(height: 7),
                                                PharmacyTextField(
                                                  controller: _productName,
                                                  hintText: '',
                                                  width: 250,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text: 'Category', size: 20),
                                                SizedBox(height: 7),
                                                SizedBox(
                                                  width: 250,
                                                  child: PharmacyDropDown(
                                                    label: '',
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
                                                        selectedCategory =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text: 'Composition',
                                                    size: 20),
                                                SizedBox(height: 7),
                                                PharmacyTextField(
                                                  controller: _composition,
                                                  hintText: '',
                                                  width: 250,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text: 'Company Name',
                                                    size: 20),
                                                SizedBox(height: 7),
                                                PharmacyTextField(
                                                  controller: _companyName,
                                                  hintText: '',
                                                  width: 250,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text: 'Referred by Doctor',
                                                    size: 20),
                                                SizedBox(height: 7),
                                                SizedBox(
                                                  width: 250,
                                                  child: PharmacyDropDown(
                                                    label: '',
                                                    items: doctors,
                                                    selectedItem:
                                                        selectedDoctor,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedDoctor = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text:
                                                        'Additional Information',
                                                    size: 20),
                                                SizedBox(height: 7),
                                                PharmacyTextField(
                                                  controller:
                                                      _additionalInformation,
                                                  hintText: '',
                                                  width: 250,
                                                ),
                                              ],
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
              child: CustomText(text: 'Edit'),
            ),
          });
        }

        setState(() {
          allProducts = List.from(fetchedData);
          filteredProducts = List.from(allProducts);
        });

        // Small delay before loading next batch
        await Future.delayed(Duration(milliseconds: 100));

        // Set last doc for next batch
        lastDoc = snapshot.docs.last;

        // If batch is less than batch size, we've reached the end
        if (snapshot.docs.length < batchSize) {
          moreData = false;
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDoctors();
    filteredProducts = List.from(allProducts);
  }

  void clearFields() {
    _productName.clear();
    _composition.clear();

    _companyName.clear();
    selectedDoctor = null;
    _additionalInformation.clear();
  }

  void filterProducts() {
    setState(() {
      isFiltering = true;

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
    setState(() {
      isFiltering = false;
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Select Category',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      PharmacyDropDown(
                        label: '',
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
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Product Name',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.20,
                        onChanged: (value) {
                          productName = value;
                          filterProducts();
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Company Name',
                        size: screenWidth * 0.013,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      PharmacyTextField(
                        hintText: '',
                        width: screenWidth * 0.20,
                        onChanged: (value) {
                          companyName = value;
                          filterProducts();
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.035),
                      isFiltering
                          ? SizedBox(
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.04,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/button_loading.json',
                                ),
                              ),
                            )
                          : PharmacyButton(
                              label: 'Search',
                              onPressed: filterProducts,
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.045,
                            ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.07),
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.035),
                      Row(
                        children: [
                          SizedBox(width: screenWidth * 0.11),
                          PharmacyButton(
                            label: 'Refresh',
                            onPressed: () async {
                              RefreshLoading(
                                context: context,
                                task: () async => await fetchData(),
                              );
                            },
                            width: screenWidth * 0.08,
                            height: screenHeight * 0.04,
                          ),
                        ],
                      ),
                    ],
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
