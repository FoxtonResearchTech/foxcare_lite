import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../colors.dart';
import '../text/primary_text.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class CustomDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int index) onItemSelected;
  final List<DrawerMenuItem> menuItems;

  final String name;
  final String degree;
  final String department;

  const CustomDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.menuItems,
    required this.name,
    required this.degree,
    required this.department,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int hoveredIndex = -1;

  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('h:mm a').format(now);
    String formattedDate =
        '${getDayWithSuffix(now.day)} ${DateFormat('MMMM').format(now)}';
    String formattedYear = DateFormat('y').format(now);
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Container(
                height: 225,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.lightBlue, AppColors.blue],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomText(text: 'Hi', size: 25, color: Colors.white),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          CustomText(
                            text: widget.name,
                            size: 30,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      CustomText(
                        text: widget.degree,
                        size: 12,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          Container(
                            width: 200,
                            height: 25,
                            color: Colors.white,
                            child: Center(
                              child: CustomText(
                                text: widget.department,
                                color: const Color(0xFF106ac2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          CustomText(
                              text: '$formattedTime  ',
                              size: 30,
                              color: Colors.white),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                  text: formattedDate,
                                  size: 15,
                                  color: Colors.white),
                              CustomText(
                                  text: formattedYear,
                                  size: 15,
                                  color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ...List.generate(widget.menuItems.length * 2 - 1, (i) {
                if (i.isEven) {
                  final index = i ~/ 2;
                  final item = widget.menuItems[index];
                  return buildDrawerItem(
                      index, item.title, item.icon, item.onTap);
                } else {
                  return const Divider(
                    height: 5,
                    color: Colors.grey,
                  );
                }
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/hospital_logo_demo.png',
                  width: 100, height: 40),
              Container(width: 2.5, height: 50, color: Colors.grey),
              Image.asset('assets/NIH_Logo.png', width: 100, height: 50),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        Container(
          height: 25,
          color: AppColors.blue,
          child: const Center(
            child: CustomText(
              text: 'Main Road, Trivandrum-690001',
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.055),
      ],
    );
  }

  Widget buildDrawerItem(
      int index, String title, IconData icon, VoidCallback onTap) {
    bool isSelected = widget.selectedIndex == index;
    bool isHovered = hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = -1),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected || isHovered
              ? LinearGradient(
                  colors: [AppColors.lightBlue, AppColors.blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
        ),
        child: ListTile(
          selected: isSelected,
          leading: Icon(
            icon,
            color: isSelected || isHovered ? Colors.white : AppColors.blue,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected || isHovered ? Colors.white : AppColors.blue,
              fontWeight: FontWeight.w700,
              fontFamily: 'SanFrancisco',
            ),
          ),
          onTap: () {
            widget.onItemSelected(index);
            onTap();
          },
        ),
      ),
    );
  }
}
