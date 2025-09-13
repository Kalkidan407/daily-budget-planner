import 'package:daily_expense/Widgets/simpleChart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controlles/trancaction_controller.dart';
import '../Widgets/simpleChart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<TransactionController>(context);
    
    final data = ctrl.recentDailyTotals(days: 7);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics (Last 7 days)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Text('Income: ${ctrl.totalIncome.toStringAsFixed(2)}'),
          Text('Expense: ${ctrl.totalExpense.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          SizedBox(height: 250, child: SimpleChart(data: data)),
        ]),
      ),
    );
  }
}