
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SimpleChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{date: DateTime, income: double, expense: double}, ...]
  const SimpleChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    final spotsIncome = <FlSpot>[];
    final spotsExpense = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spotsIncome.add(FlSpot(i.toDouble(), (data[i]['income'] as double)));
      spotsExpense.add(FlSpot(i.toDouble(), (data[i]['expense'] as double)));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(LineChartData(
        lineBarsData: [
          LineChartBarData(spots: spotsIncome, isCurved: true, dotData: FlDotData(show: false)),
          LineChartBarData(spots: spotsExpense, isCurved: true, dotData: FlDotData(show: false)),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
            final idx = val.toInt();
            if (idx < 0 || idx >= data.length) return const SizedBox();
            final d = data[idx]['date'] as DateTime;
            return Text(DateFormat.Md().format(d), style: const TextStyle(fontSize: 10));
          })),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      )),
    );
  }
}