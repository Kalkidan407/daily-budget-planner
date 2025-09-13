
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controlles/trancaction_controller.dart';
import '../views/add_transaction_screen.dart';
import '../widgets/transaction_tile.dart';
import '../Widgets/simpleChart.dart';
import 'states_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   // final ctrl = context.watch()<TransactionController>(context);
   // final ctrl = context.watch<TransactionController>();
    final ctrl = context.watch<TransactionController>();



    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Telebirr (placeholder)',
            onPressed: () {
              // Placeholder: you'll call controller.syncTelebirrTransactions after you implement API.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Telebirr sync not implemented yet')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text('Balance: ${NumberFormat.simpleCurrency().format(ctrl.balance)}', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [const Text('Income'), Text(NumberFormat.simpleCurrency().format(ctrl.totalIncome))]),
                          Column(children: [const Text('Expense'), Text(NumberFormat.simpleCurrency().format(ctrl.totalExpense))]),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 200, child: SimpleChart(data: ctrl.recentDailyTotals())),
                const Divider(),
                Expanded(
                  child: ctrl.transactions.isEmpty
                      ? const Center(child: Text('No transactions yet'))
                      : ListView.builder(
                          itemCount: ctrl.transactions.length,
                          itemBuilder: (ctx, i) {
                            final t = ctrl.transactions[i];
                            return TransactionTile(
                              t: t,
                              onDelete: () => ctrl.deleteTransaction(t.id!),
                              onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(edit: t))),
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }
}