import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';

class SalesWiseStatement extends StatefulWidget {
  const SalesWiseStatement({super.key});

  @override
  State<SalesWiseStatement> createState() => _SalesWiseStatement();
}

class _SalesWiseStatement extends State<SalesWiseStatement> {
  final TextEditingController _refNo = TextEditingController();
  final TextEditingController _fromDate = TextEditingController();
  final TextEditingController _toDate = TextEditingController();

  final List<String> headers = [
    'Sl No',
    'Product Name',
    'Opening Stock',
    'Purchase',
    'Return',
    'Damage Return',
    'Expiry Return',
    'Sales',
    'Closing',
    'Sales value',
    'Closing Value'
  ];
  List<Map<String, dynamic>> tableData = [];

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByDateRange({
    String? from,
    String? to,
  }) async {
    try {
      int i = 1;
      DateTime? fromDateTime = (from != null && from.isNotEmpty)
          ? DateTime.parse('$from 00:00')
          : null;
      DateTime? toDateTime =
          (to != null && to.isNotEmpty) ? DateTime.parse('$to 23:59') : null;

      print('Fetching products from $fromDateTime to $toDateTime');

      final addedProductsSnapshot = await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('AddedProducts')
          .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var productDoc in addedProductsSnapshot.docs) {
        final productData = productDoc.data();
        final productId = productDoc.id;

        print('Checking product: ${productData['productName']}');

        // Fetch currentQty
        final qtySnapshot = await FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(productId)
            .collection('currentQty')
            .get();

        List<QueryDocumentSnapshot> filteredDocs =
            qtySnapshot.docs.where((doc) {
          final dateStr = doc['date'];
          String timeStr = doc['time'];
          try {
            List<String> timeParts = timeStr.split(':');
            String hour = timeParts[0].padLeft(2, '0');
            String minute = timeParts[1].padLeft(2, '0');
            String paddedTime = '$hour:$minute';

            final inputFormat = DateFormat('yyyy-MM-dd HH:mm');
            final combined = inputFormat.parse('$dateStr $paddedTime');

            if (fromDateTime != null && combined.isBefore(fromDateTime))
              return false;
            if (toDateTime != null && combined.isAfter(toDateTime))
              return false;

            return true;
          } catch (_) {
            return false;
          }
        }).toList();

        filteredDocs.sort((a, b) {
          try {
            String dateA = a['date'];
            String timeA = a['time'].padLeft(5, '0');
            String dateB = b['date'];
            String timeB = b['time'].padLeft(5, '0');

            final dtA = DateTime.parse('$dateA $timeA');
            final dtB = DateTime.parse('$dateB $timeB');

            return dtB.compareTo(dtA);
          } catch (_) {
            return 0;
          }
        });

        int latestQty = 0;
        if (filteredDocs.isNotEmpty) {
          latestQty =
              int.tryParse(filteredDocs.first['quantity'].toString()) ?? 0;
        }

        // PURCHASE ENTRY
        final purchaseEntrySnapshot = await FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .doc(productId)
            .collection('purchaseEntry')
            .get();

        int totalPurchaseQty = 0;

        for (var purchaseDoc in purchaseEntrySnapshot.docs) {
          final reportDateStr = purchaseDoc['reportDate'];
          if (reportDateStr != null) {
            try {
              DateTime reportDate = DateTime.parse(reportDateStr);
              if ((fromDateTime == null ||
                      !reportDate.isBefore(fromDateTime)) &&
                  (toDateTime == null || !reportDate.isAfter(toDateTime))) {
                totalPurchaseQty +=
                    int.tryParse(purchaseDoc['qtyWithoutFree'].toString()) ?? 0;
              }
            } catch (_) {}
          }
        }

        Future<int> sumReturnQty({
          required String collectionName,
          required String targetProductName,
          required DateTime? fromDateTime,
          required DateTime? toDateTime,
        }) async {
          int total = 0;

          try {
            final snapshot = await FirebaseFirestore.instance
                .collection('stock')
                .doc('Products')
                .collection(collectionName)
                .get();

            for (var doc in snapshot.docs) {
              final data = doc.data();
              final dateStr =
                  data['returnDate'] ?? data['billDate']; // use correct field

              if (dateStr != null) {
                try {
                  final billDate = DateTime.parse(dateStr);

                  if ((fromDateTime == null ||
                          !billDate.isBefore(fromDateTime)) &&
                      (toDateTime == null || !billDate.isAfter(toDateTime))) {
                    final entryProducts = List<Map<String, dynamic>>.from(
                        data['entryProducts'] ?? []);

                    for (var entry in entryProducts) {
                      if (entry['Product Name'] == targetProductName) {
                        int qty =
                            int.tryParse(entry['Quantity'].toString()) ?? 0;
                        int free = int.tryParse(entry['Free'].toString()) ?? 0;
                        total += qty + free;
                      }
                    }
                  }
                } catch (e) {
                  print('Error parsing date in $collectionName: $e');
                }
              }
            }
          } catch (e) {
            print('Error fetching $collectionName: $e');
          }

          return total;
        }

        final productName = productData['productName'] ?? '';

        final returnQty = await sumReturnQty(
          collectionName: 'StockReturn',
          targetProductName: productName,
          fromDateTime: fromDateTime,
          toDateTime: toDateTime,
        );

        final damageQty = await sumReturnQty(
          collectionName: 'DamageReturn',
          targetProductName: productName,
          fromDateTime: fromDateTime,
          toDateTime: toDateTime,
        );

        final expiryQty = await sumReturnQty(
          collectionName: 'ExpiryReturn',
          targetProductName: productName,
          fromDateTime: fromDateTime,
          toDateTime: toDateTime,
        );

        fetchedData.add({
          'Sl No': i++,
          'Product Name': productData['productName'] ?? 'N/A',
          'Opening Stock': latestQty,
          'Purchase': totalPurchaseQty,
          'Return': returnQty,
          'Damage Return': damageQty,
          'Expiry Return': expiryQty,
        });
      }

      setState(() {
        tableData = fetchedData;
      });

      print('Fetched Data: $fetchedData');
      return fetchedData;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  @override
  void initState() {
    fetchProductsByDateRange();
    super.initState();
  }

  @override
  void dispose() {
    _refNo.dispose();
    _fromDate.dispose();
    _toDate.dispose();
    super.dispose();
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
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              TimeDateWidget(text: 'Sales Wise Statement'),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'From Date',
                        size: screenWidth * 0.015,
                      ),
                      PharmacyTextField(
                        controller: _fromDate,
                        hintText: '',
                        width: screenWidth * 0.15,
                        icon: Icon(Icons.date_range),
                        onTap: () => _selectDate(context, _fromDate),
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'To Date',
                        size: screenWidth * 0.015,
                      ),
                      PharmacyTextField(
                        controller: _toDate,
                        hintText: '',
                        width: screenWidth * 0.15,
                        icon: Icon(Icons.date_range),
                        onTap: () => _selectDate(context, _toDate),
                      ),
                    ],
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.035),
                    child: PharmacyButton(
                      label: 'Select',
                      onPressed: () async {
                        await fetchProductsByDateRange(
                            from: _fromDate.text, to: _toDate.text);
                      },
                      width: screenWidth * 0.08,
                      height: screenHeight * 0.045,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.08),
              const Row(
                children: [CustomText(text: 'Available Party wise List')],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                padding: EdgeInsets.only(left: screenWidth * 0.32),
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    CustomText(
                      text: 'Total : ',
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
