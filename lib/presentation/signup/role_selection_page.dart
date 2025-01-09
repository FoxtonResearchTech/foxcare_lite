import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/dashboard/pharmecy_dashboard.dart';
import 'package:foxcare_lite/presentation/signup/employee_registration.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/images.dart';
import 'package:foxcare_lite/utilities/widgets/image/custom_image.dart';

import '../../utilities/widgets/text/primary_text.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: CustomText(
          text: 'Select Your Role',
          size: screenWidth * 0.015,
          color: Colors.white,
        )),
        backgroundColor: AppColors.secondaryColor,
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: screenHeight * 0.05,
          left: screenWidth * 0.15,
          right: screenWidth * 0.2,
          bottom: screenWidth * 0.05,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: screenHeight * 0.5,
              width: screenWidth * 0.2,
              decoration: BoxDecoration(),
              child: CustomImage(path: AppImages.logo),
            ),
            SizedBox(width: screenWidth * 0.02),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoleContainer(
                  role: 'Role 1',
                  icon: Icons.admin_panel_settings,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const EmployeeRegistration()));
                  },
                ),
                RoleContainer(
                  role: 'Role 2',
                  icon: Icons.group,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SalesChartScreen()));
                  },
                ),
                RoleContainer(
                  role: 'Role 3',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SalesChartScreen()));
                  },
                ),
                RoleContainer(
                  role: 'Role 4',
                  icon: Icons.business_center,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SalesChartScreen()));
                  },
                ),
                RoleContainer(
                  role: 'Role 5',
                  icon: Icons.support,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SalesChartScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RoleContainer extends StatelessWidget {
  final String role;
  final IconData icon;
  final VoidCallback onTap;

  const RoleContainer({
    Key? key,
    required this.role,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.009),
        width: screenWidth * 0.25,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            SizedBox(width: screenWidth * 0.02),
            CustomText(
              text: role,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
