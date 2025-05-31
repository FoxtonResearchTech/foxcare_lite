import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/pharmacy_drop_down.dart';
import 'package:foxcare_lite/utilities/widgets/dropDown/primary_dropDown.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/table/lazy_data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import 'package:lottie/lottie.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/refreshLoading/refreshLoading.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProduct();
}

class _AddProduct extends State<AddProduct> {
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _composition = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _additionalInformation = TextEditingController();
  final dateTime = DateTime.timestamp();
  List<String> doctors = [];
  String? selectedDoctor;
  bool isFiltering = false;
  final List<String> headers = [
    'Product Name',
    'Composition',
    'Category',
    'Company',
  ];
  List<Map<String, dynamic>> allProducts = [];

  List<Map<String, dynamic>> filteredProducts = [];

  Future<void> fetchRecentProducts() async {
    try {
      const int batchSize = 20;
      DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

      List<Map<String, dynamic>> allFetchedData = [];
      QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;

      bool hasMore = true;

      // Clear previous data before appending
      setState(() {
        allProducts.clear();
        filteredProducts.clear();
      });

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

          try {
            DateTime addedDate = DateTime.parse(data['productAddedDate']);

            if (addedDate.isAfter(thirtyDaysAgo)) {
              allFetchedData.add({
                'Product Name': data['productName'],
                'Category': data['category'],
                'Company': data['companyName'],
                'Composition': data['composition'],
                'Type': data['type'],
              });
            }
          } catch (e) {
            print("Invalid date format: ${data['productAddedDate']}");
            continue;
          }
        }

        // Append to UI table incrementally
        setState(() {
          allProducts = List.from(allFetchedData);
          filteredProducts = List.from(allProducts);
        });

        allFetchedData.clear();
        lastDoc = snapshot.docs.last;

        await Future.delayed(const Duration(milliseconds: 100)); // Smooth load
      }
    } catch (e) {
      print('Error fetching recent products: $e');
    }
  }

  String? selectedCategoryFilter;
  String productName = '';
  String companyName = '';
  String hsnCode = '';

  List<String> distributorsNames = [];
  String? selectedCategory;

  Future<void> addProduct() async {
    try {
      Map<String, dynamic> data = {
        'productName': _productName.text,
        'composition': _composition.text,
        'category': selectedCategory,
        'companyName': _companyName.text,
        'referredByDoctor': selectedDoctor,
        'additionalInformation': _additionalInformation.text,
        'productAddedDate': dateTime.year.toString() +
            '-' +
            dateTime.month.toString().padLeft(2, '0') +
            '-' +
            dateTime.day.toString().padLeft(2, '0'),
      };
      await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('AddedProducts')
          .doc()
          .set(data);
      clearFields();
      CustomSnackBar(context,
          message: 'Product Added Successfully', backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to Add Product', backgroundColor: Colors.red);
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
    } catch (e) {
      print('Error fetching distributors: $e');
    }
  }

  void clearFields() {
    _productName.clear();
    _composition.clear();

    _companyName.clear();
    selectedDoctor = null;
    _additionalInformation.clear();
  }

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

  @override
  void initState() {
    super.initState();
    fetchDistributors();
    fetchRecentProducts();
    filteredProducts = List.from(allProducts);
    fetchDoctors();
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
              TimeDateWidget(text: 'Add Product'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Column(
                    children: [
                      SizedBox(height: screenHeight * 0.0),
                      PharmacyButton(
                        label: 'Add',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: CustomText(
                                  text: 'Add Product',
                                  size: screenWidth * 0.016,
                                ),
                                content: Container(
                                  width: screenWidth * 0.5,
                                  height: screenHeight * 0.35,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: screenWidth * 0.5,
                                              height: screenHeight * 0.3,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Product Name',
                                                            size: screenWidth *
                                                                0.012,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.01),
                                                          PharmacyTextField(
                                                            controller:
                                                                _productName,
                                                            hintText: '',
                                                            width: screenWidth *
                                                                0.25,
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Category',
                                                            size: screenWidth *
                                                                0.012,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.01),
                                                          SizedBox(
                                                            width: screenWidth *
                                                                0.2,
                                                            child:
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
                                                                    selectedItem:
                                                                        selectedCategory,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        selectedCategory =
                                                                            value;
                                                                      });
                                                                    }),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: 'Composition',
                                                            size: screenWidth *
                                                                0.012,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.01),
                                                          PharmacyTextField(
                                                            controller:
                                                                _composition,
                                                            hintText: '',
                                                            width: screenWidth *
                                                                0.25,
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Company Name',
                                                            size: screenWidth *
                                                                0.012,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.01),
                                                          PharmacyTextField(
                                                            controller:
                                                                _companyName,
                                                            hintText: '',
                                                            width: screenWidth *
                                                                0.2,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Referred by Doctor',
                                                            size: screenWidth *
                                                                0.012,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.01),
                                                          SizedBox(
                                                            width: screenWidth *
                                                                0.25,
                                                            child:
                                                                PharmacyDropDown(
                                                                    label: '',
                                                                    items:
                                                                        doctors,
                                                                    selectedItem:
                                                                        selectedDoctor,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        selectedDoctor =
                                                                            value;
                                                                      });
                                                                    }),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text:
                                                                'Additional Information',
                                                            size: screenWidth *
                                                                0.012,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.01),
                                                          PharmacyTextField(
                                                            controller:
                                                                _additionalInformation,
                                                            hintText: '',
                                                            width: screenWidth *
                                                                0.2,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
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
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.045,
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
                          SizedBox(width: screenWidth * 0.12),
                          PharmacyButton(
                            label: 'Refresh',
                            onPressed: () async {
                              RefreshLoading(
                                context: context,
                                task: () async => await fetchRecentProducts(),
                              );
                            },
                            width: screenWidth * 0.1,
                            height: screenHeight * 0.045,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              Row(
                children: [
                  CustomText(
                    text: 'Products Added in Last 30 days',
                    size: screenWidth * 0.012,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              LazyDataTable(headers: headers, tableData: filteredProducts),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
