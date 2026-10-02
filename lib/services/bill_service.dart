import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bill.dart';

class BillService {
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
  // USER BILLS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _billsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('bills');
  }

  // ============================================================
  // ADD BILL
  // ============================================================

  Future<void> addBill(Bill bill) async {
    await _billsCollection
        .doc(bill.id)
        .set(bill.toMap());
  }

  // ============================================================
  // UPDATE BILL
  // ============================================================

  Future<void> updateBill(Bill bill) async {
    await _billsCollection
        .doc(bill.id)
        .update(bill.toMap());
  }

  // ============================================================
  // DELETE BILL
  // ============================================================

  Future<void> deleteBill(String id) async {
    await _billsCollection
        .doc(id)
        .delete();
  }

  // ============================================================
  // MARK AS PAID
  // ============================================================

  Future<void> markAsPaid(String id) async {
    await _billsCollection
        .doc(id)
        .update({
      'isPaid': true,
      'paidDate':
          DateTime.now().toIso8601String(),
    });
  }

  // ============================================================
  // MARK AS UNPAID
  // ============================================================

  Future<void> markAsUnpaid(String id) async {
    await _billsCollection
        .doc(id)
        .update({
      'isPaid': false,
      'paidDate': null,
    });
  }

  // ============================================================
  // GET BILLS
  // ============================================================

  Stream<List<Bill>> getBills() {
    return _billsCollection
        .orderBy(
          'dueDate',
          descending: false,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Bill.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}