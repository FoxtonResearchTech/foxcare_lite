import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChartScreen extends StatelessWidget {
  const SalesChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sales Data Line Chart'),
      ),
      body:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SalesLineChart(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  GradientBox(
                    gradientColors: [Colors.blue, Colors.lightBlueAccent, Colors.cyan],
                    text: 'Hello!',
                  ),
                  SizedBox(height: 20),
                  GradientBox(
                    gradientColors: [Colors.red, Colors.orange, Colors.yellow],
                    text: 'Amazing!',
                  ),
                ],
              ),
            ),
          ),
        ],
      )

    );
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
      1500, 2000, 1800, 2200, 3000, 3500, 3200, 2900, 3300, 4000, 4500, 5000
    ];

    final List<double> sales2025 = [
      1600, 2100, 1900, 2400, 3100, 3600, 3300, 3000, 3400, 4100, 4600, 5100
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
              color: Colors.green,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.3),
              ),
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: sales2025
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key + 1.0, e.value))
                  .toList(),
              isCurved: true,
              color: Colors.red,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.1),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}


class GradientBox extends StatelessWidget {
  final List<Color> gradientColors;
  final String text;

  const GradientBox({
    Key? key,
    required this.gradientColors,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
