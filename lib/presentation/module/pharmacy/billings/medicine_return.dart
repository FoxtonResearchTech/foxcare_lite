import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';
import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../../../utilities/widgets/snackBar/snakbar.dart';
import '../tools/manage_pharmacy_info.dart';
import 'counter_sales.dart';
import 'ip_billing.dart';

class MedicineReturn extends StatefulWidget {
  const MedicineReturn({super.key});

  @override
  State<MedicineReturn> createState() => _MedicineReturn();
}

class _MedicineReturn extends State<MedicineReturn> {
  TextEditingController date = TextEditingController();
  TextEditingController patientName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController billNo = TextEditingController();

  double totalAmount = 0.0;
  double taxPercentage = 12;
  double gstPercentage = 10;
  double taxAmount = 0.00;
  double gstAmount = 0.00;
  double totalGst = 0.00;
  double grandTotal = 0.00;

  final List<String> headers1 = [
    'Bill NO',
    'Patient Name',
    'OP NO / IP NO / Counter',
    'Bill Date',
    'Action',
  ];
  List<Map<String, dynamic>> tableData1 = [];
  final List<String> headers2 = [
    'Product Name',
    'Type',
    'Batch',
    'EXP',
    'HSN',
    'Purchased Quantity',
    'MRP',
    'Price',
    'GST',
    'Amount',
    'Purchased Amount',
    'Returning Qut',
    'Returning Cost'
  ];
  List<Map<String, dynamic>> tableData2 = [];
  Future<void> medicineReturn() async {
    try {
      DocumentReference billingRef = FirebaseFirestore.instance
          .collection('pharmacy')
          .doc('billing')
          .collection('medicinereturn')
          .doc();
      List<Map<String, dynamic>> updatedTableData = tableData1.map((item) {
        return {
          'Bill NO': item['Bill NO'] ?? 'N/A',
          'Patient Name': item['Patient Name'] ?? 'N/A',
          'OP NO / IP NO / Counter': item['OP NO / IP NO / Counter'] ?? 'N/A',
          'Bill Date': item['Bill Date'] ?? 'N/A',
        };
      }).toList();
      updatedTableData = tableData2.map((item) {
        return {
          'Product Name': item['Product Name'] ?? 'N/A',
          'Type': item['Type'] ?? 'N/A',
          'Batch': item['Batch'] ?? 'N/A',
          'EXP': item['EXP'] ?? 'N/A',
          'HSN': item['HSN'] ?? 'N/A',
          'Quantity': item['Quantity'] ?? '0',
          'MPS': item['MPS'] ?? 'N/A',
          'Price': item['Price'] ?? 'N/A',
          'Gst': item['Gst'] ?? '0%',
          'Amount': item['Amount'] ?? '0.00',
          'Purchased Amount': item['Purchased Amount'] ?? '0.00',
          'Returning Qut': item['Returning Qut'] ?? '0',
          'Returning Cost': item['Returning Cost'] ?? '0.00',
        };
      }).toList();
      Map<String, dynamic> billingData = {
        'billNo': billNo.text,
        'billDate': date.text,
        'patientName': patientName.text,
        'phoneNumber': phoneNumber.text,
        'totalAmount': totalAmount,
        'taxAmount': taxAmount,
        'gstAmount': gstAmount,
        'totalGst': totalGst,
        'grandTotal': grandTotal,
        'items': updatedTableData,
      };

      await billingRef.set(billingData);
      for (var product in tableData2) {
        String productName = product['Product Name'];
        String batch = product['Batch'];
        String hsn = product['HSN'];

        double Quantity =
            double.tryParse(product['Returning Qut'].toString()) ?? 0;

        print('Return Quantity: $Quantity');

        if (Quantity > 0) {
          QuerySnapshot<Map<String, dynamic>> productSnapshot =
              await FirebaseFirestore.instance
                  .collection('stock')
                  .doc('Products')
                  .collection('AddedProducts')
                  .where('productName', isEqualTo: productName)
                  .where('batchNumber', isEqualTo: batch)
                  .where('hsnCode', isEqualTo: hsn)
                  .get();

          if (productSnapshot.docs.isEmpty) {
            print(
                'No matching product found for $productName, Batch: $batch, HSN: $hsn');
          } else {
            print('Found ${productSnapshot.docs.length} matching products.');

            for (var doc in productSnapshot.docs) {
              double currentQuantity =
                  double.tryParse(doc['quantity'].toString()) ?? 0;

              double updatedQuantity =
                  (currentQuantity - Quantity).clamp(0, double.infinity);

              print(
                  'Current Quantity: $currentQuantity, Updated Quantity: $updatedQuantity');

              await FirebaseFirestore.instance
                  .collection('stock')
                  .doc('Products')
                  .collection('AddedProducts')
                  .doc(doc.id)
                  .update({
                'quantity': updatedQuantity.toString(),
              });
            }
          }
        }
      }

      CustomSnackBar(context,
          message: 'Medicine Return data submitted successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      CustomSnackBar(context,
          message: 'Failed to submit Medicine Return data',
          backgroundColor: Colors.red);

      print('Error submitting billing data: $e');
    }
  }

  Future<void> fetchData({String? billNo}) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<String> collections = ['ipbilling', 'opbilling', 'countersales'];

      List<QuerySnapshot> snapshots = await Future.wait(
        collections.map((collection) {
          Query query = firestore
              .collection('pharmacy')
              .doc('billing')
              .collection(collection);

          if (billNo != null) {
            query = query.where('billNo', isEqualTo: billNo);
          }

          return query.get();
        }),
      );

      List<Map<String, dynamic>> patientData = [];
      List<Map<String, dynamic>> medicineData = [];

      for (var snapshot in snapshots) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          if (data.isNotEmpty) {
            patientData.add({
              'Bill NO': data['billNo'] ?? 'N/A',
              'Patient Name': data['patientName'] ?? 'N/A',
              'OP NO / IP NO / Counter':
                  data['opNumber'] ?? data['ipNumber'] ?? 'Counter',
              'Bill Date': data['billDate'] ?? 'N/A',
              'Phone Number': data['phoneNumber'] ?? 'N/A',
              'Purchased Total': data['totalAmount'] ?? 'N/A',
              'Purchased Tax': data['taxAmount'] ?? 'N/A',
              'Purchased Gst': data['gstAmount'] ?? 'N/A',
              'Purchased Total Gst': data['totalGst'] ?? 'N/A',
              'Purchased Grand Total': data['grandTotal'] ?? 'N/A',
              'Action': TextButton(
                onPressed: () => medicineReturn(),
                child: CustomText(text: 'Return'),
              ),
            });
            for (var item in data['items']) {
              medicineData.add({
                'Product Name': item['Product Name'] ?? 'N/A',
                'Type': item['Type'] ?? 'N/A',
                'Batch': item['Batch'] ?? 'N/A',
                'EXP': item['EXP'] ?? 'N/A',
                'HSN': item['HSN'] ?? 'N/A',
                'Purchased Quantity': item['Quantity'] ?? 'N/A',
                'MRP': item['MPS'] ?? 'N/A',
                'Price': item['Price'] ?? 'N/A',
                'GST': item['Gst'] ?? 'N/A',
                'Amount': item['Amount'] ?? 'N/A',
                'Purchased Amount': item['Amount'],
                'Returning Qut': '',
                'Returning Cost': item['Returning Cost'],
              });
            }
          }
        }
      }

      if (patientData.isEmpty) {
        setState(() {
          tableData1 = [];
          resetTotals();
        });
        return;
      }
      if (medicineData.isEmpty) {
        setState(() {
          tableData2 = [];
          resetTotals();
        });
        return;
      }

      final firstEntry = patientData.first;
      setState(() {
        patientName.text = (firstEntry['firstName'] ?? '') +
            ' ' +
            (firstEntry['Patient Name'] ?? 'N/A');
        phoneNumber.text = firstEntry['Phone Number'] ?? 'N/A';
        date.text = firstEntry['Bill Date'] ?? 'N/A';
        tableData1 = patientData;
        tableData2 = medicineData;
        calculateTotals();

        if (billNo == null) {
          resetTotals();
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void calculateTotals() {
    totalAmount = tableData2.fold(0.0, (sum, item) {
      double returningCost =
          double.tryParse(item['Returning Cost']?.toString() ?? '0') ?? 0;
      double amount = double.tryParse(item['Amount']?.toString() ?? '0') ?? 0;

      return sum + (returningCost > 0 ? returningCost : amount);
    });

    taxAmount = (totalAmount * taxPercentage) / 100;
    gstAmount = (totalAmount * gstPercentage) / 100;
    totalGst = taxAmount + gstAmount;
    grandTotal = totalAmount + totalGst;

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));
    taxAmount = double.parse(taxAmount.toStringAsFixed(2));
    gstAmount = double.parse(gstAmount.toStringAsFixed(2));
    totalGst = double.parse(totalGst.toStringAsFixed(2));
    grandTotal = double.parse(grandTotal.toStringAsFixed(2));
  }

  void resetTotals() {
    totalAmount = 0.00;
    taxAmount = 0.00;
    gstAmount = 0.00;
    totalGst = 0.00;
    grandTotal = 0.00;
    patientName.clear();

    phoneNumber.clear();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.03),
                    child: Column(
                      children: [
                        CustomText(
                          text: "Medicine Return",
                          size: screenWidth * 0.0275,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.15,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      image: const DecorationImage(
                        image: AssetImage('assets/foxcare_lite_logo.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomTextField(
                    controller: billNo,
                    hintText: 'Bill No',
                    width: screenWidth * 0.25,
                    onChanged: (value) async {
                      setState(() {
                        tableData2 = [];
                        tableData1 = [];
                      });

                      fetchData(billNo: value);
                    },
                  ),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                    controller: date,
                    hintText: 'Date',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  CustomTextField(
                      controller: patientName,
                      hintText: 'Patient Name',
                      width: screenWidth * 0.25),
                  SizedBox(width: screenHeight * 0.5),
                  CustomTextField(
                      controller: phoneNumber,
                      hintText: 'Phone Number',
                      width: screenWidth * 0.25),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              CustomDataTable(
                tableData: tableData1,
                headers: headers1,
              ),
              SizedBox(height: screenHeight * 0.08),
              if (tableData2.isNotEmpty) ...[
                CustomDataTable(
                  tableData: tableData2,
                  headers: headers2,
                  editableColumns: ['Returning Qut'],
                  onValueChanged: (rowIndex, header, value) async {
                    if (header == 'Purchased Quantity') {
                      if (rowIndex >= 0 && rowIndex < tableData2.length) {
                        setState(() {
                          tableData2[rowIndex]['Purchased Quantity'] = value;

                          double quantity = double.tryParse(value) ?? 0;
                          double amountPerUnit = double.tryParse(
                                  tableData2[rowIndex]['Amount']?.toString() ??
                                      '0') ??
                              0;
                          double totalAmountForItem = quantity * amountPerUnit;

                          tableData2[rowIndex]['Amount'] =
                              totalAmountForItem.toStringAsFixed(2);

                          calculateTotals();
                        });
                      } else {
                        print("Error: rowIndex $rowIndex is out of range.");
                      }
                    }
                    if (header == 'Returning Qut') {
                      if (rowIndex >= 0 && rowIndex < tableData2.length) {
                        setState(() {
                          double returnQuantity = double.tryParse(value) ?? 0;
                          double pricePerUnit = double.tryParse(
                                  tableData2[rowIndex]['Price']?.toString() ??
                                      '0') ??
                              0;
                          double gstPercentage = double.tryParse(
                                  tableData2[rowIndex]['GST']
                                          ?.replaceAll('%', '') ??
                                      '0') ??
                              0;

                          double returnAmount = returnQuantity * pricePerUnit;
                          double returnGst =
                              (returnAmount * gstPercentage) / 100;
                          double returnTotal = returnAmount + returnGst;

                          tableData2[rowIndex]['Returning Cost'] =
                              returnTotal.toStringAsFixed(2);

                          calculateTotals();
                        });
                      } else {
                        print("Error: rowIndex $rowIndex is out of range.");
                      }
                    }
                  },
                ),
                Container(
                  padding: EdgeInsets.only(right: screenWidth * 0.08),
                  width: screenWidth,
                  height: screenHeight * 0.028,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: 'Total :$totalAmount ',
                        size: screenWidth * 0.0085,
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: screenWidth * 0.08),
                  width: screenWidth,
                  height: screenHeight * 0.025,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(text: '12% TAX :$taxAmount '),
                      CustomText(text: '10% GST : $gstAmount'),
                      CustomText(text: 'Total GST :$totalGst '),
                      CustomText(text: 'Grand Total :$grandTotal '),
                    ],
                  ),
                ),
              ],
              SizedBox(height: screenHeight * 0.08),
            ],
          ),
        ),
      ),
    );
  }
}
