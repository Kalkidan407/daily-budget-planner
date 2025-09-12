import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/trancactionModel.dart';
import '../Controlles/trancaction_controller.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? edit;
  const AddTransactionScreen({Key? key, this.edit}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  DateTime _date = DateTime.now();
  String _category = 'General';
  TransactionType _type = TransactionType.expense;
  TransactionSource _source = TransactionSource.manual;

  @override
  void initState() {
    super.initState();
    if (widget.edit != null) {
      _title = widget.edit!.title!;
      _amount = widget.edit!.amount!;
      _date = widget.edit!.date!;
      _category = widget.edit!.category!;
      _type = widget.edit!.type!;
      _source = widget.edit!.source!;
    } else {
      _title = '';
      _amount = 0.0;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final controller = Provider.of<TransactionController>(context, listen: false);
    final t = TransactionModel(
      id: widget.edit?.id,
      title: _title,
      amount: _amount,
      date: _date,
      category: _category,
      type: _type,
      source: _source,
    );

    if (widget.edit == null) {
      controller.addTransaction(t);
    } else {
      controller.updateTransaction(t);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.edit == null ? 'Add Transaction' : 'Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              TextFormField(
                initialValue: widget.edit != null ? widget.edit!.amount.toString() : '',
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter a number' : null,
                onSaved: (v) => _amount = double.parse(v!),
              ),
              Row(
                children: [
                  Expanded(child: Text('Date: ${DateFormat.yMd().format(_date)}')),
                  TextButton(
                    child: const Text('Select'),
                    onPressed: () async {
                      final selected = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (selected != null) setState(() => _date = selected);
                    },
                  )
                ],
              ),
              DropdownButtonFormField<TransactionType>(
                value: _type,
                items: TransactionType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _type = v!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<TransactionSource>(
                value: _source,
                items: TransactionSource.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _source = v!),
                decoration: const InputDecoration(labelText: 'Source'),
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (v) => _category = v ?? 'General',
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
