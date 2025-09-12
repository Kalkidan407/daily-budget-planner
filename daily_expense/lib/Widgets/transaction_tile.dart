import 'package:flutter/material.dart';
import '../Model/trancactionModel.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel t;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  const TransactionTile({Key? key, required this.t, required this.onDelete, this.onEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(t.type == TransactionType.income ? '+' : '-')),
      title: Text(t.title ?? "Unknown" ),
      subtitle: Text('${t.category} • ${DateFormat.yMMMd().format(t.date ?? DateTime.now())} • ${t.source?.name ?? 'unknown'}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(NumberFormat.simpleCurrency().format(t.amount)),
        IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      ]),
    );
  }
}