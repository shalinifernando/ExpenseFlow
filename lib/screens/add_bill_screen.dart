import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../services/bill_service.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();

  final BillService _billService = BillService();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _noteController =
      TextEditingController();

  DateTime _dueDate = DateTime.now();

  String _selectedCategory = 'Utilities';

  String _selectedRecurrence = 'One-time';

  bool _isPaid = false;

  bool _isSaving = false;

  final List<String> _categories = [
    'Utilities',
    'Rent',
    'Internet',
    'Phone',
    'Insurance',
    'Subscription',
    'Loan',
    'Education',
    'Healthcare',
    'Other',
  ];

  final List<String> _recurrences = [
    'One-time',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      _dueDate = selectedDate;
    });
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // SAVE BILL
  // ============================================================

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final bill = Bill(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        name: _nameController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        dueDate: _dueDate,
        recurrence: _selectedRecurrence,
        isPaid: _isPaid,
        paidDate: _isPaid ? DateTime.now() : null,
        note: _noteController.text.trim(),
      );

      await _billService.addBill(bill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill added successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add bill: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Bill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // BILL NAME
            // ==================================================

            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Bill Name',
                hintText: 'e.g. Electricity Bill',
                prefixIcon: const Icon(
                  Icons.receipt_long_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter the bill name';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // ==================================================
            // AMOUNT
            // ==================================================

            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                prefixText: 'Rs. ',
                prefixIcon: const Icon(
                  Icons.payments_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter the amount';
                }

                final amount = double.tryParse(
                  value.trim(),
                );

                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // ==================================================
            // CATEGORY
            // ==================================================

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(
                  Icons.category_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 18),

            // ==================================================
            // DUE DATE
            // ==================================================

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  prefixIcon: const Icon(
                    Icons.calendar_month_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _formatDate(_dueDate),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // RECURRENCE
            // ==================================================

            DropdownButtonFormField<String>(
              initialValue: _selectedRecurrence,
              decoration: InputDecoration(
                labelText: 'Recurrence',
                prefixIcon: const Icon(
                  Icons.repeat,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: _recurrences.map((recurrence) {
                return DropdownMenuItem<String>(
                  value: recurrence,
                  child: Text(recurrence),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedRecurrence = value;
                });
              },
            ),

            const SizedBox(height: 18),

            // ==================================================
            // PAID STATUS
            // ==================================================

            Card(
              child: SwitchListTile(
                title: const Text(
                  'Already Paid',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _isPaid
                      ? 'This bill has been paid'
                      : 'This bill is unpaid',
                ),
                secondary: Icon(
                  _isPaid
                      ? Icons.check_circle_outline
                      : Icons.pending_outlined,
                ),
                value: _isPaid,
                onChanged: (value) {
                  setState(() {
                    _isPaid = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // NOTE
            // ==================================================

            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                hintText:
                    'Add additional information...',
                alignLabelWithHint: true,
                prefixIcon: const Icon(
                  Icons.notes_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // SAVE BUTTON
            // ==================================================

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _isSaving ? null : _saveBill,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save_outlined,
                      ),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : 'Save Bill',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}