import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';
import 'package:foxcare_lite/utilities/widgets/buttons/primary_button.dart';
import 'package:foxcare_lite/utilities/widgets/table/data_table.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import 'package:foxcare_lite/utilities/widgets/textField/primary_textField.dart';

import '../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../tools/manage_pharmacy_info.dart';

class PurchaseOrder extends StatefulWidget {
  const PurchaseOrder({super.key});

  @override
  State<PurchaseOrder> createState() => _PurchaseOrder();
}

class _PurchaseOrder extends State<PurchaseOrder> {
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
                  CustomTextField(
                    hintText: 'PO Number',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'PO Date',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'Supplier',
                    width: screenWidth * 0.25,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Supplier Contact',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'Supplier Address',
                    width: screenWidth * 0.25,
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'PO Status',
                    width: screenWidth * 0.25,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  CustomTextField(
                    hintText: 'Payment Term',
                    width: screenWidth * 0.25,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                  ),
                  SizedBox(width: screenHeight * 0.045),
                  CustomTextField(
                    hintText: 'Shipment Address',
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              const Row(
                children: [CustomText(text: 'Add Product List')],
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                padding: EdgeInsets.only(
                    top: screenWidth * 0.02,
                    bottom: screenWidth * 0.02,
                    left: screenWidth * 0.08,
                    right: screenWidth * 0.08),
                width: screenWidth,
                height: screenHeight * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.containerColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.005),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: screenWidth * 0.04),
                        const CustomText(
                          text: 'Product Name',
                        ),
                        SizedBox(width: screenWidth * 0.125),
                        const CustomText(
                          text: 'Quantity',
                        ),
                        SizedBox(width: screenWidth * 0.125),
                        const CustomText(
                          text: 'Unit Price',
                        ),
                        SizedBox(width: screenWidth * 0.125),
                        const CustomText(
                          text: 'Total Price',
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.045),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.045),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                        CustomTextField(
                          hintText: '',
                          width: screenWidth * 0.15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.06),
              Column(
                children: [
                  Row(
                    children: [
                      CustomText(text: 'Order Summary'),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: screenWidth * 0.02,
                        bottom: screenWidth * 0.02,
                        left: screenWidth * 0.08,
                        right: screenWidth * 0.08),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextField(
                                hintText: 'Sub Total',
                                width: screenWidth * 0.2),
                            CustomTextField(
                                hintText: 'Total Discount',
                                width: screenWidth * 0.2),
                            CustomTextField(
                                hintText: 'Shipping', width: screenWidth * 0.2),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.045),
                        Row(
                          children: [
                            CustomTextField(
                                hintText: 'Tax Applied',
                                width: screenWidth * 0.2),
                            SizedBox(width: screenWidth * 0.04),
                            CustomTextField(
                                hintText: 'Total PG Value',
                                width: screenWidth * 0.2),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.045),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                                label: 'Save',
                                onPressed: () {},
                                width: screenHeight * 0.2),
                            CustomButton(
                                label: 'Update',
                                onPressed: () {},
                                width: screenHeight * 0.2),
                            CustomButton(
                                label: 'Submit',
                                onPressed: () {},
                                width: screenHeight * 0.2),
                            CustomButton(
                                label: 'Print',
                                onPressed: () {},
                                width: screenHeight * 0.2),
                            CustomButton(
                                label: 'Email',
                                onPressed: () {},
                                width: screenHeight * 0.2),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.06),
              Column(
                children: [
                  Row(
                    children: [
                      CustomText(text: 'Comments'),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: screenWidth * 0.02,
                        bottom: screenWidth * 0.02,
                        left: screenWidth * 0.08,
                        right: screenWidth * 0.08),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextField(
                              hintText: 'Internal Notes',
                              width: screenWidth * 0.3,
                              verticalSize: screenHeight * 0.04,
                            ),
                            CustomTextField(
                              hintText: 'Supplier Notes',
                              width: screenWidth * 0.3,
                              verticalSize: screenHeight * 0.04,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
