class Bill {
  final String id;
  final String name;
  final double amount;
  final String category;
  final DateTime dueDate;
  final String recurrence;
  final bool isPaid;
  final DateTime? paidDate;
  final String note;

  Bill({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.dueDate,
    required this.recurrence,
    required this.isPaid,
    this.paidDate,
    this.note = '',
  });

  // ============================================================
  // FIRESTORE MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'recurrence': recurrence,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'note': note,
    };
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory Bill.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Bill(
      id: id,
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Other',
      dueDate: DateTime.tryParse(
            map['dueDate'] ?? '',
          ) ??
          DateTime.now(),
      recurrence: map['recurrence'] ?? 'One-time',
      isPaid: map['isPaid'] ?? false,
      paidDate: map['paidDate'] != null
          ? DateTime.tryParse(
              map['paidDate'],
            )
          : null,
      note: map['note'] ?? '',
    );
  }
}