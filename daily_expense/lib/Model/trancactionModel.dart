enum TransactionSource { manual, telebirr, bank }
enum TransactionType { expense, income }

class TransactionModel {
  int? id;
  String? title;
  double? amount;
  DateTime? date;
  String? category;
  TransactionType? type;
  TransactionSource? source;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
     this.source = TransactionSource.manual,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'amount': amount,
      'date': date?.toIso8601String(),
      'type': type == TransactionType.income ? 1 : 0,
      'category': category,
      'source' : _sourceToInt(source!),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

 factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: map['type'] == 1 ? TransactionType.income : TransactionType.expense,
      category: map['category'],
      source: _intToSource(map['source']),
    );
  }

  static TransactionSource _intToSource(int i) {
    switch (i) {
      case 1:
        return TransactionSource.telebirr;
      case 2:
        return TransactionSource.bank;
      case 0:
      default:
        return TransactionSource.manual;
    }
  }

  
  static int _sourceToInt(TransactionSource source) {
    switch (source) {
      case TransactionSource.telebirr:
        return 1;
      case TransactionSource.bank:
        return 2;
      case TransactionSource.manual:
      default:
        return 0;
    }
}
}

