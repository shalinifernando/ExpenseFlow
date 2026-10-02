import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../services/bill_service.dart';
import 'add_bill_screen.dart';
import 'edit_bill_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final BillService _billService = BillService();

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // CHECK OVERDUE
  // ============================================================

  bool _isOverdue(Bill bill) {
    if (bill.isPaid) {
      return false;
    }

    final today = DateTime.now();

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final dueDateOnly = DateTime(
      bill.dueDate.year,
      bill.dueDate.month,
      bill.dueDate.day,
    );

    return dueDateOnly.isBefore(todayOnly);
  }

  // ============================================================
  // CHECK DUE SOON
  // ============================================================

  bool _isDueSoon(Bill bill) {
    if (bill.isPaid || _isOverdue(bill)) {
      return false;
    }

    final today = DateTime.now();

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final dueDateOnly = DateTime(
      bill.dueDate.year,
      bill.dueDate.month,
      bill.dueDate.day,
    );

    final difference =
        dueDateOnly.difference(todayOnly).inDays;

    return difference >= 0 && difference <= 7;
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String _getStatusText(Bill bill) {
    if (bill.isPaid) {
      return 'Paid';
    }

    if (_isOverdue(bill)) {
      return 'Overdue';
    }

    if (_isDueSoon(bill)) {
      return 'Due Soon';
    }

    return 'Upcoming';
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _getStatusColor(Bill bill) {
    if (bill.isPaid) {
      return Colors.green;
    }

    if (_isOverdue(bill)) {
      return Colors.red;
    }

    if (_isDueSoon(bill)) {
      return Colors.orange;
    }

    return Colors.blue;
  }

  // ============================================================
  // DELETE BILL
  // ============================================================

  Future<void> _deleteBill(Bill bill) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Bill?'),
          content: Text(
            'Are you sure you want to delete "${bill.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _billService.deleteBill(bill.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete bill: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // MARK PAID / UNPAID
  // ============================================================

  Future<void> _togglePaid(Bill bill) async {
    try {
      if (bill.isPaid) {
        await _billService.markAsUnpaid(
          bill.id,
        );
      } else {
        await _billService.markAsPaid(
          bill.id,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update bill: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD BILL
  // ============================================================

  Future<void> _addBill() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBillScreen(),
      ),
    );
  }

  // ============================================================
  // EDIT BILL
  // ============================================================

  Future<void> _editBill(Bill bill) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBillScreen(
          bill: bill,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(List<Bill> bills) {
    double unpaidTotal = 0;
    double paidTotal = 0;
    int overdueCount = 0;

    for (final bill in bills) {
      if (bill.isPaid) {
        paidTotal += bill.amount;
      } else {
        unpaidTotal += bill.amount;
      }

      if (_isOverdue(bill)) {
        overdueCount++;
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    title: 'Unpaid',
                    amount: unpaidTotal,
                    icon: Icons.pending_actions,
                    iconColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryItem(
                    title: 'Paid',
                    amount: paidTotal,
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12),
                color: overdueCount > 0
                    ? Colors.red.withValues(
                        alpha: 0.08,
                      )
                    : Colors.green.withValues(
                        alpha: 0.08,
                      ),
              ),
              child: Row(
                children: [
                  Icon(
                    overdueCount > 0
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: overdueCount > 0
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    overdueCount > 0
                        ? '$overdueCount overdue bill${overdueCount == 1 ? '' : 's'}'
                        : 'No overdue bills',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: overdueCount > 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(14),
        color: iconColor.withValues(
          alpha: 0.08,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BILL CARD
  // ============================================================

  Widget _buildBillCard(Bill bill) {
    final statusColor =
        _getStatusColor(bill);

    final statusText =
        _getStatusText(bill);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ==================================================
            // TOP ROW
            // ==================================================

            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      statusColor.withValues(
                    alpha: 0.10,
                  ),
                  child: Icon(
                    bill.isPaid
                        ? Icons.check
                        : Icons.receipt_long_outlined,
                    color: statusColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bill.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  'Rs. ${bill.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // BOTTOM ROW
            // ==================================================

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 17,
                  color: statusColor,
                ),

                const SizedBox(width: 6),

                Text(
                  'Due ${_formatDate(bill.dueDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                // ==================================================
                // OPTIONS
                // ==================================================

                PopupMenuButton<String>(
                  tooltip: 'Bill options',

                  onSelected: (value) {
                    if (value == 'edit') {
                      _editBill(bill);
                    }

                    if (value == 'paid') {
                      _togglePaid(bill);
                    }

                    if (value == 'delete') {
                      _deleteBill(bill);
                    }
                  },

                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                            ),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),

                      PopupMenuItem<String>(
                        value: 'paid',
                        child: Row(
                          children: [
                            Icon(
                              bill.isPaid
                                  ? Icons.undo
                                  : Icons
                                      .check_circle_outline,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              bill.isPaid
                                  ? 'Mark Unpaid'
                                  : 'Mark Paid',
                            ),
                          ],
                        ),
                      ),

                      const PopupMenuDivider(),

                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),

            // ==================================================
            // RECURRENCE
            // ==================================================

            if (bill.recurrence != 'One-time') ...[
              const SizedBox(height: 8),

              Align(
                alignment:
                    Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(
                      Icons.repeat,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bill.recurrence,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ==================================================
            // NOTE
            // ==================================================

            if (bill.note.trim().isNotEmpty) ...[
              const SizedBox(height: 8),

              Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  bill.note,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bills & Payments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // ADD BILL BUTTON
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addBill,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Bill',
        ),
      ),

      // ========================================================
      // FIREBASE BILLS
      // ========================================================

      body: StreamBuilder<List<Bill>>(
        stream: _billService.getBills(),

        builder: (context, snapshot) {
          // ==================================================
          // LOADING
          // ==================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ==================================================
          // ERROR
          // ==================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  'Error loading bills:\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final bills =
              snapshot.data ?? [];

          // ==================================================
          // EMPTY
          // ==================================================

          if (bills.isEmpty) {
            return Column(
              children: [
                _buildSummary(bills),

                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No bills yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: Text(
                            'Add a bill to start tracking your payments.',
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // ==================================================
          // BILL LIST
          // ==================================================

          return Column(
            children: [
              _buildSummary(bills),

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    100,
                  ),
                  itemCount:
                      bills.length,
                  itemBuilder:
                      (context, index) {
                    final bill =
                        bills[index];

                    return _buildBillCard(
                      bill,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}