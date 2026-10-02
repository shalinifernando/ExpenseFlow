import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
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
  // USER SETTINGS DOCUMENT
  // ============================================================

  DocumentReference<Map<String, dynamic>>
      get _budgetDocument {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('settings')
        .doc('budget');
  }

  // ============================================================
  // GET BUDGET
  // ============================================================

  Future<double?> getBudget() async {
    final doc = await _budgetDocument.get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null || data['amount'] == null) {
      return null;
    }

    return (data['amount'] as num).toDouble();
  }

  // ============================================================
  // SAVE BUDGET
  // ============================================================

  Future<void> saveBudget(
    double amount,
  ) async {
    await _budgetDocument.set({
      'amount': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}