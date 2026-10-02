import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    return user.uid;
  }

  // ============================================================
  // USER EXPENSES COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _expensesCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses');
  }

  // ============================================================
  // ADD EXPENSE
  // ============================================================

  Future<void> addExpense(Expense expense) async {
    await _expensesCollection
        .doc(expense.id)
        .set(expense.toMap());
  }

  // ============================================================
  // UPDATE EXPENSE
  // ============================================================

  Future<void> updateExpense(Expense expense) async {
    await _expensesCollection
        .doc(expense.id)
        .update(expense.toMap());
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<void> deleteExpense(String id) async {
    await _expensesCollection
        .doc(id)
        .delete();
  }

  // ============================================================
  // GET EXPENSES
  // ============================================================

  Stream<List<Expense>> getExpenses() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Expense.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}