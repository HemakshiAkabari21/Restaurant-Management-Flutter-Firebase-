import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_management_fierbase/model/daily_sale_model.dart';

class RevenueLineChart extends StatelessWidget {
  final List<DaySales> data;

  const RevenueLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE
        const Text(
          "Daily Sales (₹)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),

              // Y AXIS (Money)
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text("₹${value.toInt()}");
                    },
                  ),
                ),

                // X AXIS (Dates)
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= data.length) return const SizedBox();
                      final d = data[index].date;
                      return Text("${d.day} ${_monthName(d.month)}");
                    },
                  ),
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    data.length,
                        (i) => FlSpot(i.toDouble(), data[i].amount),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // SUMMARY
        Text(
          "Highest Sale : ₹${_maxSale()}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          "Lowest Sale  : ₹${_minSale()}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }

  double _maxSale() =>
      data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

  double _minSale() =>
      data.map((e) => e.amount).reduce((a, b) => a < b ? a : b);
}

class BusinessLineChart extends StatelessWidget {
  final List<DaySales> revenue;
  final List<DaySales> expense;
  final bool isWeekly;

  const BusinessLineChart({
    super.key,
    required this.revenue,
    required this.expense,
    required this.isWeekly,
  });

  @override
  Widget build(BuildContext context) {
    final avg = revenue.map((e) => e.amount).reduce((a, b) => a + b) / revenue.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOGGLE
        Row(
          children: [
            _toggleButton("Weekly", isWeekly),
            _toggleButton("Monthly", !isWeekly),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),

              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) => Text("₹${v.toInt()}"),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      int i = v.toInt();
                      if (i >= revenue.length) return const SizedBox();
                      final d = revenue[i].date;
                      return Text("${d.day}/${d.month}");
                    },
                  ),
                ),
              ),

              lineBarsData: [
                // REVENUE LINE
                LineChartBarData(
                  spots: List.generate(
                    revenue.length,
                        (i) => FlSpot(i.toDouble(), revenue[i].amount),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      final isGood = spot.y >= avg;
                      return FlDotCirclePainter(
                        radius: 5,
                        color: isGood ? Colors.green : Colors.red,
                      );
                    },
                  ),
                ),

                // EXPENSE LINE
                LineChartBarData(
                  spots: List.generate(
                    expense.length,
                        (i) => FlSpot(i.toDouble(), expense[i].amount),
                  ),
                  isCurved: true,
                  barWidth: 2,
                  color: Colors.red,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // PROFIT SUMMARY
        Text(
          "Profit Today: ₹${_todayProfit()}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _todayProfit() >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _toggleButton(String text, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: active ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  double _todayProfit() {
    return revenue.last.amount - expense.last.amount;
  }
}


