import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/foxcare_lite_app_bar.dart';

import '../../../utilities/colors.dart';

class PatientViewScreen extends StatelessWidget {
  const PatientViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FoxCareLiteAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine the number of columns based on screen width
            int crossAxisCount = constraints.maxWidth > 1200
                ? 4
                : constraints.maxWidth > 800
                ? 3
                : 2;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
                childAspectRatio: 3 / 1.5, // Aspect ratio of each item (width/height)
              ),
              itemCount: 8, // Number of items
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 120,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(12), // Match the borderRadius
                    color: Colors.transparent, // Set background color to transparent
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 40, // Adjusted for a better fit
                                  backgroundColor: AppColors.appBar,
                                  child: Center(
                                    child: Text(
                                      "M G",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "OP Number: 15446489489484",
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Name: Nishanth",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black45,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              "Sex: Male",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black45,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              "Age: 21",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black45,
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              "Blood Group: B+",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black45,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
