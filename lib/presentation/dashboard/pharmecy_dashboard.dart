import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChartScreen extends StatelessWidget {
  const SalesChartScreen({Key? key}) : super(key: key); // Added 'key' parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Data Line Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SalesLineChart(), // No changes needed here
      ),
    );
  }
}

class SalesLineChart extends StatelessWidget {
  const SalesLineChart({Key? key}) : super(key: key); // Added 'key' parameter

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.white,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white,
              strokeWidth: 0.5,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.shade700,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  List<String> months = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                  ];

                  List<double> sales2024 = [
                    1500, 2000, 1800, 2200, 3000, 3500, 3200, 2900, 3300, 4000, 4500, 5000
                  ];

                  List<double> sales2025 = [
                    1600, 2100, 1900, 2400, 3100, 3600, 3300, 3000, 3400, 4100, 4600, 5100
                  ];

                  int monthIndex = value.toInt() - 1;
                  double sales = sales2024[monthIndex] + sales2025[monthIndex];

                  return Column(
                    children: [
                      Text(
                        months[value.toInt() - 1],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₹${sales.toInt()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
            border: Border.all(color: Colors.white, width: 1),
          ),
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: 6000,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(1, 1500),
                FlSpot(2, 2000),
                FlSpot(3, 1800),
                FlSpot(4, 2200),
                FlSpot(5, 3000),
                FlSpot(6, 3500),
                FlSpot(7, 3200),
                FlSpot(8, 2900),
                FlSpot(9, 3300),
                FlSpot(10, 4000),
                FlSpot(11, 4500),
                FlSpot(12, 5000),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.3),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, lineBarData, index, rodData) {
                  return FlDotCirclePainter(
                    color: Colors.blue,
                    radius: 6,
                  );
                },
              ),
            ),
            LineChartBarData(
              spots: [
                FlSpot(1, 1600),
                FlSpot(2, 2100),
                FlSpot(3, 1900),
                FlSpot(4, 2400),
                FlSpot(5, 3100),
                FlSpot(6, 3600),
                FlSpot(7, 3300),
                FlSpot(8, 3000),
                FlSpot(9, 3400),
                FlSpot(10, 4100),
                FlSpot(11, 4600),
                FlSpot(12, 5100),
              ],
              isCurved: true,
              color: Colors.red,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Color(0xff3B315E).withOpacity(0.10),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, lineBarData, index, rodData) {
                  return FlDotCirclePainter(
                    color: Colors.red,
                    radius: 6,
                  );
                },
              ),
            ),
          ],

        ),
      ),
    );
  }
}
