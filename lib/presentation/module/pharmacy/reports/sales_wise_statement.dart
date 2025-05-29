import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:foxcare_lite/utilities/widgets/buttons/pharmacy_button.dart';
import 'package:foxcare_lite/utilities/widgets/date_time.dart';
import 'package:foxcare_lite/utilities/widgets/snackBar/snakbar.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/pharmacy_text_field.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

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
  bool fromToDateSearching = false;
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
    'Closing value'
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
    int pageSize = 1,
  }) async {
    try {
      int i = 1;
      DateTime now = DateTime.now();

      // Opening Stock cutoff date
      DateTime openingStockCutoffDate;
      if (from != null && from.isNotEmpty) {
        openingStockCutoffDate = DateTime.parse('$from 00:00');
      } else {
        openingStockCutoffDate = now.subtract(const Duration(days: 1));
      }

      bool applyDateFilter =
          (from != null && from.isNotEmpty) && (to != null && to.isNotEmpty);

      DateTime? fromDateTime;
      DateTime? toDateTime;
      if (applyDateFilter) {
        fromDateTime = DateTime.parse('$from 00:00');
        toDateTime = DateTime.parse('$to 23:59');
      }

      print('Opening Stock cutoff: $openingStockCutoffDate');
      if (applyDateFilter) {
        print('Filtering purchase/return from $fromDateTime to $toDateTime');
      } else {
        print('No date filtering for purchase/return, summing all data');
      }

      List<Map<String, dynamic>> fetchedData = [];
      QueryDocumentSnapshot? lastProductDoc;

      bool moreDataAvailable = true;

      while (moreDataAvailable) {
        Query query = FirebaseFirestore.instance
            .collection('stock')
            .doc('Products')
            .collection('AddedProducts')
            .orderBy('productName')
            .limit(pageSize);

        if (lastProductDoc != null) {
          query = query.startAfterDocument(lastProductDoc);
        }

        final addedProductsSnapshot = await query.get();

        if (addedProductsSnapshot.docs.isEmpty) {
          // No more data
          moreDataAvailable = false;
          break;
        }

        for (var productDoc in addedProductsSnapshot.docs) {
          final productData = productDoc.data() as Map<String, dynamic>;
          final productId = productDoc.id;

          print('Checking product: ${productData['productName']}');

          // Calculate Opening Stock: sum qty records before openingStockCutoffDate
          final qtySnapshot = await FirebaseFirestore.instance
              .collection('stock')
              .doc('Products')
              .collection('AddedProducts')
              .doc(productId)
              .collection('currentQty')
              .get();

          List<QueryDocumentSnapshot> openingStockDocs =
              qtySnapshot.docs.where((doc) {
            final dateStr = doc['date'];
            final timeStr = doc['time'];
            try {
              final paddedTime = timeStr.padLeft(5, '0');
              final combined =
                  DateFormat('yyyy-MM-dd HH:mm').parse('$dateStr $paddedTime');
              return combined.isBefore(openingStockCutoffDate);
            } catch (_) {
              return false;
            }
          }).toList();

          openingStockDocs.sort((a, b) {
            try {
              final dtA = DateFormat('yyyy-MM-dd HH:mm')
                  .parse('${a['date']} ${a['time'].padLeft(5, '0')}');
              final dtB = DateFormat('yyyy-MM-dd HH:mm')
                  .parse('${b['date']} ${b['time'].padLeft(5, '0')}');
              return dtB.compareTo(dtA);
            } catch (_) {
              return 0;
            }
          });

          int openingStockQty = 0;
          if (openingStockDocs.isNotEmpty) {
            openingStockQty =
                int.tryParse(openingStockDocs.first['quantity'].toString()) ??
                    0;
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
            if (applyDateFilter) {
              final reportDateStr = purchaseDoc['reportDate'];
              if (reportDateStr != null && reportDateStr is String) {
                try {
                  final reportDate = DateTime.parse(reportDateStr);
                  if (reportDate.isBefore(fromDateTime!) ||
                      reportDate.isAfter(toDateTime!)) {
                    continue; // skip out of date range
                  }
                } catch (e) {
                  print('Error parsing reportDate: $reportDateStr — $e');
                }
              }
            }
            totalPurchaseQty +=
                int.tryParse(purchaseDoc['qtyWithoutFree'].toString()) ?? 0;
          }

          final productName = productData['productName'] ?? '';

          final returnQty = await sumReturnQty(
            collectionName: 'StockReturn',
            targetProductName: productName,
            fromDateTime: fromDateTime,
            toDateTime: toDateTime,
            applyDateFilter: applyDateFilter,
          );

          final damageQty = await sumReturnQty(
            collectionName: 'DamageReturn',
            targetProductName: productName,
            fromDateTime: fromDateTime,
            toDateTime: toDateTime,
            applyDateFilter: applyDateFilter,
          );

          final expiryQty = await sumReturnQty(
            collectionName: 'ExpiryReturn',
            targetProductName: productName,
            fromDateTime: fromDateTime,
            toDateTime: toDateTime,
            applyDateFilter: applyDateFilter,
          );

          final salesQty = await sumSalesQty(
            targetProductName: productName,
            fromDateTime: fromDateTime,
            toDateTime: toDateTime,
            applyDateFilter: applyDateFilter,
          );

          final latestRate = await getLatestPurchaseRate(productId);

          final closingQty = (openingStockQty + totalPurchaseQty) -
              (returnQty + damageQty + expiryQty + salesQty);

          final salesValue = latestRate * salesQty;
          final closingValue = latestRate * closingQty;

          fetchedData.add({
            'Sl No': i++,
            'Product Name': productName,
            'Opening Stock': openingStockQty,
            'Purchase': totalPurchaseQty,
            'Return': returnQty,
            'Damage Return': damageQty,
            'Expiry Return': expiryQty,
            'Sales': salesQty,
            'Closing': closingQty,
            'Sales value': salesValue,
            'Closing value': closingValue,
          });
        }

        // Update lastProductDoc to last fetched doc for next iteration
        lastProductDoc = addedProductsSnapshot.docs.last;

        setState(() {
          tableData = List.from(fetchedData);
          _totalSalesValue();
          _totalClosingValue();
        });
        await Future.delayed(const Duration(milliseconds: 100));

        // Stop if fetched less than pageSize documents (last page)
        if (addedProductsSnapshot.docs.length < pageSize) {
          moreDataAvailable = false;
        }
      }

      print('Fetched all paginated Data: $fetchedData');
      return fetchedData;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<int> sumReturnQty({
    required String collectionName,
    required String targetProductName,
    DateTime? fromDateTime,
    DateTime? toDateTime,
    required bool applyDateFilter,
    int pageSize = 20, // batch size per page
  }) async {
    int total = 0;

    try {
      Query query = FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection(collectionName)
          .orderBy(
              'returnDate'); // or 'billDate', if always present and sortable

      // If you want to filter by date in query (optional optimization)
      if (applyDateFilter && fromDateTime != null && toDateTime != null) {
        // Firestore requires the same field for range queries.
        // If you always have returnDate or billDate, adjust accordingly.
        query = query
            .where('returnDate',
                isGreaterThanOrEqualTo: fromDateTime.toIso8601String())
            .where('returnDate',
                isLessThanOrEqualTo: toDateTime.toIso8601String());
      }

      QueryDocumentSnapshot? lastDoc;
      bool moreData = true;

      while (moreData) {
        Query currentQuery = query.limit(pageSize);
        if (lastDoc != null) {
          currentQuery = currentQuery.startAfterDocument(lastDoc);
        }

        final snapshot = await currentQuery.get();

        if (snapshot.docs.isEmpty) {
          moreData = false;
          break;
        }

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Date filtering (double check if not filtered by Firestore query)
          final dateStr = data['returnDate'] ?? data['billDate'];
          if (applyDateFilter && dateStr != null && dateStr is String) {
            try {
              final billDate = DateTime.parse(dateStr);
              if (billDate.isBefore(fromDateTime!) ||
                  billDate.isAfter(toDateTime!)) {
                continue; // skip outside date range
              }
            } catch (e) {
              print('Error parsing date in $collectionName: $e');
            }
          }

          final entryProducts =
              List<Map<String, dynamic>>.from(data['entryProducts'] ?? []);
          for (var entry in entryProducts) {
            if (entry['Product Name'] == targetProductName) {
              total += int.tryParse(entry['Quantity'].toString()) ?? 0;
            }
          }
        }

        lastDoc = snapshot.docs.last;

        // If fetched docs less than pageSize, then no more pages
        if (snapshot.docs.length < pageSize) {
          moreData = false;
        }

        // Small delay before next page to reduce Firestore load (optional)
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error fetching $collectionName: $e');
    }

    return total;
  }

  Future<double> getLatestPurchaseRate(String productId) async {
    try {
      final purchaseSnapshot = await FirebaseFirestore.instance
          .collection('stock')
          .doc('Products')
          .collection('AddedProducts')
          .doc(productId)
          .collection('purchaseEntry')
          .orderBy('reportDate', descending: true)
          .limit(1)
          .get();

      if (purchaseSnapshot.docs.isNotEmpty) {
        final latestPurchase = purchaseSnapshot.docs.first.data();
        return double.tryParse(latestPurchase['rate'].toString()) ?? 0.0;
      }
    } catch (e) {
      print('Error fetching latest purchase rate for product $productId: $e');
    }
    return 0.0;
  }

  Future<int> sumSalesQty({
    required String targetProductName,
    DateTime? fromDateTime,
    DateTime? toDateTime,
    required bool applyDateFilter,
    int batchSize = 20, // adjustable batch size
  }) async {
    int total = 0;

    try {
      final billingSubcollections = ['countersales', 'opbilling', 'ipbilling'];

      for (final subcollection in billingSubcollections) {
        DocumentSnapshot? lastDoc;
        bool hasMore = true;

        while (hasMore) {
          Query query = FirebaseFirestore.instance
              .collection('pharmacy')
              .doc('billings')
              .collection(subcollection)
              .orderBy('billDate');

          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          }

          query = query.limit(batchSize);

          final snapshot = await query.get();

          if (snapshot.docs.isEmpty) {
            hasMore = false;
            break;
          }

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final billDateStr = data['billDate'];

            if (applyDateFilter &&
                billDateStr != null &&
                billDateStr is String) {
              try {
                final billDate = DateTime.parse(billDateStr);
                if (billDate.isBefore(fromDateTime!) ||
                    billDate.isAfter(toDateTime!)) {
                  continue; // skip outside date range
                }
              } catch (e) {
                print('Error parsing billdate in $subcollection: $e');
              }
            }

            final entryProducts =
                List<Map<String, dynamic>>.from(data['entryProducts'] ?? []);

            for (var entry in entryProducts) {
              if (entry['Product Name'] == targetProductName) {
                total += int.tryParse(entry['Quantity'].toString()) ?? 0;
              }
            }
          }

          lastDoc = snapshot.docs.last;

          // Delay a bit between batches (e.g., 100ms)
          await Future.delayed(const Duration(milliseconds: 100));

          if (snapshot.docs.length < batchSize) {
            hasMore = false; // no more documents to fetch
          }
        }
      }
    } catch (e) {
      print('Error fetching Sales quantity: $e');
    }

    return total;
  }

  int _totalSalesValue() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Sales value'];
        if (value == null) return sum;

        if (value is String) {
          return sum + (double.tryParse(value)?.toInt() ?? 0);
        } else if (value is num) {
          return sum + value.toInt();
        }

        return sum;
      },
    );
  }

  int _totalClosingValue() {
    return tableData.fold<int>(
      0,
      (sum, entry) {
        var value = entry['Closing value'];
        if (value == null) return sum;

        if (value is String) {
          return sum + (double.tryParse(value)?.toInt() ?? 0);
        } else if (value is num) {
          return sum + value.toInt();
        }

        return sum;
      },
    );
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
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            bottom: screenWidth * 0.05,
          ),
          child: Column(
            children: [
              TimeDateWidget(text: 'Sales Wise Statement'),
              Row(
                children: [
                  PharmacyTextField(
                    controller: _fromDate,
                    hintText: 'From Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, _fromDate),
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  PharmacyTextField(
                    controller: _toDate,
                    hintText: 'To Date',
                    width: screenWidth * 0.15,
                    icon: Icon(Icons.date_range),
                    onTap: () => _selectDate(context, _toDate),
                  ),
                  SizedBox(width: screenHeight * 0.05),
                  fromToDateSearching
                      ? SizedBox(
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.045,
                          child: Center(
                            child: Lottie.asset(
                              'assets/button_loading.json',
                            ),
                          ),
                        )
                      : PharmacyButton(
                          label: 'Select',
                          onPressed: () async {
                            final today = DateTime.now();
                            final enteredFromDate = _fromDate.text;

                            final enteredToDate = _toDate.text;

                            // Parse the enteredFromDate safely
                            if (enteredFromDate.isNotEmpty) {
                              try {
                                final parsedDate =
                                    DateTime.parse(enteredFromDate);
                                if (parsedDate.year == today.year &&
                                    parsedDate.month == today.month &&
                                    parsedDate.day == today.day) {
                                  CustomSnackBar(context,
                                      message: "Today's Date Is Not Allowed",
                                      backgroundColor: Colors.red);
                                  return; // Stop execution
                                }
                              } catch (e) {
                                CustomSnackBar(context,
                                    message: "Invalid Date Format",
                                    backgroundColor: Colors.red);
                                return;
                              }
                            }
                            if (enteredFromDate.isNotEmpty &&
                                enteredToDate.isNotEmpty) {
                              try {
                                if (enteredFromDate == enteredToDate) {
                                  CustomSnackBar(context,
                                      message:
                                          "From & To Date Should Not Be Equal",
                                      backgroundColor: Colors.red);
                                  return; // Stop execution
                                }
                              } catch (e) {
                                CustomSnackBar(context,
                                    message: "Invalid Date Format",
                                    backgroundColor: Colors.red);
                                return;
                              }
                            }

                            setState(() => fromToDateSearching = true);
                            await fetchProductsByDateRange(
                                from: _fromDate.text, to: _toDate.text);
                            setState(() => fromToDateSearching = false);
                          },
                          width: screenWidth * 0.08,
                          height: screenHeight * 0.045,
                        ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomText(
                    text: 'Available Sales wise Statement List',
                    size: screenWidth * 0.015,
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomDataTable(
                tableData: tableData,
                headers: headers,
              ),
              Container(
                padding: EdgeInsets.only(left: screenWidth * 0.5),
                width: screenWidth,
                height: screenHeight * 0.030,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    CustomText(
                      text: 'Total : ',
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    CustomText(
                      text: '${_totalSalesValue().toString()}',
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    CustomText(
                      text: '${_totalClosingValue().toString()}',
                    )
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
