import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:foxcare_lite/presentation/billings/counter_sales.dart';
import 'package:foxcare_lite/presentation/billings/ip_billing.dart';
import 'package:foxcare_lite/presentation/billings/medicine_return.dart';
import 'package:foxcare_lite/presentation/reports/non_moving_stock.dart';
import 'package:foxcare_lite/presentation/tools/manage_pharmacy_info.dart';
import 'package:foxcare_lite/utilities/colors.dart';
import 'package:foxcare_lite/utilities/widgets/appBar/app_bar.dart';

import '../../utilities/widgets/appBar/foxcare_lite_app_bar.dart';
import '../../utilities/widgets/decoration/gradient_box.dart';

class SalesChartScreen extends StatelessWidget {
  const SalesChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const FoxCareLiteAppBar(),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SalesLineChart(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    const GradientBox(
                      subText: "25",
                      gradientColors: [
                        Colors.blue,
                        Colors.lightBlueAccent,
                        Colors.cyan
                      ],
                      text: 'No of Bill Generated',
                    ),
                    const SizedBox(height: 20),
                    const GradientBox(
                      subText: '15',
                      gradientColors: [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow
                      ],
                      text: 'Total Qty Sales',
                    ),
                    const SizedBox(height: 20),
                    const GradientBox(
                      subText: '₹150000',
                      gradientColors: [
                        Color(0xFF004D40), // Dark Green
                        Color(0xFF00C853), // Emerald Green
                        Color(0xFFB9F6CA), // Light Mint Green
                      ],
                      text: 'Total Amount Collected',
                    ),
                    const SizedBox(height: 20),
                    const GradientBox(
                      subText: '158',
                      gradientColors: [
                        Color(0xFF6A1B9A), // Deep Purple
                        Color(0xFFAB47BC), // Medium Purple
                        Color(0xFFE1BEE7), // Light Lavender
                      ],
                      text: 'Total Medicine Entry Qty',
                    ),
                    const SizedBox(height: 20),
                    const GradientBox(
                      subText: '₹452125',
                      gradientColors: [
                        Color(0xFFF06292), // Light Pink
                        Color(0xFFE91E63), // Pink
                        Color(0xFFD50000), // Deep Red
                      ],
                      text: 'Total Medicine \n Retrive Value',
                    ),
                    const SizedBox(height: 20),
                    const GradientBox(
                      subText: '₹845665',
                      gradientColors: [
                        Color(0xFF4DD0E1), // Light Cyan
                        Color(0xFF00ACC1), // Medium Cyan
                        Color(0xFF006064), // Deep Cyan
                      ],
                      text: 'Total Total Collection',
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          elevation: MaterialStateProperty.all(0),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          )),
                          shadowColor: MaterialStateProperty.all(
                              Colors.black.withOpacity(0.3)),
                        ),
                        onPressed: () {
                          // Add your action here when the button is pressed
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
                              // Gradient color
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NonMovingStock()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 30),
                              alignment: Alignment.center,
                              child: const Text(
                                'Non Moving Products',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily:
                                      'Roboto', // Use any custom font if you like
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class SalesLineChart extends StatelessWidget {
  const SalesLineChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final List<double> sales2024 = [
      1500,
      2000,
      1800,
      2200,
      3000,
      3500,
      3200,
      2900,
      3300,
      4000,
      4500,
      5000
    ];

    final List<double> sales2025 = [
      1600,
      2100,
      1900,
      2400,
      3100,
      3600,
      3300,
      3000,
      3400,
      4100,
      4600,
      5100
    ];

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.white,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 1000,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 0.5,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 1 || value.toInt() > months.length) {
                    return const SizedBox.shrink();
                  }

                  final int index = value.toInt() - 1;
                  final double sales = sales2024[index] + sales2025[index];

                  return Column(
                    children: [
                      Text(
                        months[index],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${sales.toInt()}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: 6000,
          lineBarsData: [
            LineChartBarData(
              spots: sales2024
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key + 1.0, e.value))
                  .toList(),
              isCurved: true,
              color: Colors.teal,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.3),
              ),
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: sales2025
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key + 1.0, e.value))
                  .toList(),
              isCurved: true,
              color: Colors.pink,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.1),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
