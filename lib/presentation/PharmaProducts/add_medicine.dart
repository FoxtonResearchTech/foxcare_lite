import 'package:custom_check_box/custom_check_box.dart';
import 'package:flutter/material.dart';

import '../../utilities/colors.dart';
import '../../utilities/widgets/textField/primary_textField.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Medicine",
          style: TextStyle(color: Colors.white, fontFamily: 'SanFrancisco'),
        ),
        backgroundColor: AppColors.secondaryColor,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(screenWidth * 0.010),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "BrandName:",
                    width: null,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(hintText: "Short Name:", width: null),
                ),
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "HSN  Code:",
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Drug Release:",
                    icon: Icon(Icons.arrow_drop_down_circle),
                    width: null,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Strength:",
                    width: null,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "10M:",
                    icon: Icon(Icons.arrow_drop_down_circle),
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Manufacturer:",
                    width: null,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: CustomTextField(
                    hintText: "Drug Type:",
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Drug Medicine Type:",
                    icon: Icon(Icons.arrow_drop_down_circle),
                    width: null,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: CustomTextField(
                    hintText: "Drug Location:",
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Refundable:",
                    icon: Icon(Icons.arrow_drop_down_circle),
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Item Discount:",
                    width: null,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: CustomTextField(
                    hintText: "On MRP:",
                    icon: Icon(Icons.arrow_drop_down_circle),
                    width: null,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Text(
                  "Applicable",
                  style: TextStyle(
                      fontFamily: 'SanFrancisco', fontSize: screenWidth * 0.01),
                ),
                CustomCheckBox(
                  value: true, // Initial state
                  onChanged: (bool isChecked) {},
                  borderColor: Colors.grey,
                  checkedFillColor: Colors.grey, // Checked state fill color
                  uncheckedFillColor: Colors.grey, // Unchecked state fill color
                  borderRadius: 4, // Rectangular shape
                  borderWidth: 2,
                  checkBoxSize: 24,
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.4,
                  child: CustomTextField(hintText: "Drug Location:",width: null,),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Mast Package Qty:",
                    width: null,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: CustomTextField(
                    hintText: "Package Type:",
                    icon: Icon(Icons.arrow_drop_down_circle),
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Trans Pack Qty:",
                    width: null,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: CustomTextField(
                    hintText: "Package Type:",
                    icon: Icon(Icons.arrow_drop_down_circle),
                    width: null,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.3,
                  child: CustomTextField(
                    hintText: "Schedule Type:",
                    width: null,
                  ),
                ),
                Text(
                  "OTC",
                  style: TextStyle(
                      fontFamily: 'SanFrancisco', fontSize: screenWidth * 0.01),
                ),
                CustomCheckBox(
                  value: true, // Initial state
                  onChanged: (bool isChecked) {},
                  borderColor: Colors.grey,
                  checkedFillColor: Colors.grey, // Checked state fill color
                  uncheckedFillColor: Colors.grey, // Unchecked state fill color
                  borderRadius: 4, // Rectangular shape
                  borderWidth: 2,
                  checkBoxSize: 24,
                ),
                Text(
                  "Forrmulary",
                  style: TextStyle(
                      fontFamily: 'SanFrancisco', fontSize: screenWidth * 0.01),
                ),
                CustomCheckBox(
                  value: true, // Initial state
                  onChanged: (bool isChecked) {},
                  borderColor: Colors.grey,
                  checkedFillColor: Colors.grey, // Checked state fill color
                  uncheckedFillColor: Colors.grey, // Unchecked state fill color
                  borderRadius: 4, // Rectangular shape
                  borderWidth: 2,
                  checkBoxSize: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
