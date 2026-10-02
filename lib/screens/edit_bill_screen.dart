import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../services/bill_service.dart';

class EditBillScreen extends StatefulWidget {
  final Bill bill;

  const EditBillScreen({
    super.key,
    required this.bill,
  });

  @override
  State<EditBillScreen> createState() =>
      _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final _formKey = GlobalKey<FormState>();

  final BillService _billService = BillService();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late DateTime _dueDate;
  late String _selectedCategory;
  late String _selectedRecurrence;
  late bool _isPaid;

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
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.bill.name);

    _amountController = TextEditingController(
      text: widget.bill.amount.toStringAsFixed(2),
    );

    _noteController =
        TextEditingController(text: widget.bill.note);

    _dueDate = widget.bill.dueDate;

    _selectedCategory =
        _categories.contains(widget.bill.category)
            ? widget.bill.category
            : 'Other';

    _selectedRecurrence =
        _recurrences.contains(widget.bill.recurrence)
            ? widget.bill.recurrence
            : 'One-time';

    _isPaid = widget.bill.isPaid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE PICKER
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
  // SAVE CHANGES
  // ============================================================

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedBill = Bill(
        id: widget.bill.id,
        name: _nameController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        dueDate: _dueDate,
        recurrence: _selectedRecurrence,
        isPaid: _isPaid,
        paidDate: _isPaid
            ? (widget.bill.paidDate ?? DateTime.now())
            : null,
        note: _noteController.text.trim(),
      );

      await _billService.updateBill(updatedBill);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bill updated successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update bill: $e',
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
          'Edit Bill',
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

                final amount =
                    double.tryParse(value.trim());

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
                  'Paid',
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
                    _isSaving ? null : _saveChanges,
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
                      : 'Save Changes',
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