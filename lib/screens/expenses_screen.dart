import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import 'edit_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpenseService _expenseService = ExpenseService();

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedCategory = 'All';
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTER EXPENSES
  // ============================================================

  List<Expense> _filterExpenses(List<Expense> expenses) {
    final searchText =
        _searchController.text.trim().toLowerCase();

    return expenses.where((expense) {
      // Search by title, category, or note
      final matchesSearch =
          searchText.isEmpty ||
          expense.title.toLowerCase().contains(searchText) ||
          expense.category.toLowerCase().contains(searchText) ||
          expense.note.toLowerCase().contains(searchText);

      // Category filter
      final matchesCategory =
          _selectedCategory == 'All' ||
          expense.category == _selectedCategory;

      // Date filter
      final matchesDate =
          _selectedDate == null ||
          (expense.date.year == _selectedDate!.year &&
              expense.date.month == _selectedDate!.month &&
              expense.date.day == _selectedDate!.day);

      return matchesSearch &&
          matchesCategory &&
          matchesDate;
    }).toList();
  }

  // ============================================================
  // GET CATEGORIES
  // ============================================================

  List<String> _getCategories(List<Expense> expenses) {
    final categories = expenses
        .map((expense) => expense.category)
        .where(
          (category) => category.trim().isNotEmpty,
        )
        .toSet()
        .toList();

    categories.sort();

    return ['All', ...categories];
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _selectedDate = null;
    });
  }

  // ============================================================
  // CHECK WHETHER FILTERS ARE ACTIVE
  // ============================================================

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedCategory != 'All' ||
        _selectedDate != null;
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<void> _deleteExpense(Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
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

    if (shouldDelete != true) return;

    try {
      await _expenseService.deleteExpense(expense.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete expense: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EXPENSE CARD
  // ============================================================

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              backgroundColor: const Color(0xFFEDE9FE),
              child: const Icon(
                Icons.receipt_long,
                color: Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(width: 12),

            // Expense information
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expense.category} • '
                    '${expense.date.day}/'
                    '${expense.date.month}/'
                    '${expense.date.year}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  // Show note if available
                  if (expense.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      expense.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Amount
            Flexible(
              child: Text(
                'Rs. ${expense.amount.toStringAsFixed(2)}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            // Edit button
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: Color(0xFF4F46E5),
                size: 24,
              ),
              tooltip: 'Edit',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditExpenseScreen(
                      expense: expense,
                    ),
                  ),
                );
              },
            ),

            // Delete button
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 26,
              ),
              tooltip: 'Delete',
              onPressed: () {
                _deleteExpense(expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FILTER AREA
  // ============================================================

  Widget _buildFilters(
    List<String> categories,
  ) {
    return Column(
      children: [
        // ======================================================
        // SEARCH
        // ======================================================

        TextField(
          controller: _searchController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search title, category or note...',
            prefixIcon: const Icon(
              Icons.search,
            ),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // CATEGORY + DATE
        // ======================================================

        Row(
          children: [
            // Category
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue:
                    categories.contains(
                  _selectedCategory,
                )
                        ? _selectedCategory
                        : 'All',
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: categories.map((category) {
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
            ),

            const SizedBox(width: 10),

            // Date
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                ),
                label: Text(
                  _selectedDate == null
                      ? 'Date'
                      : '${_selectedDate!.day}/'
                          '${_selectedDate!.month}/'
                          '${_selectedDate!.year}',
                  overflow:
                      TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    56,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        // ======================================================
        // CLEAR FILTERS
        // ======================================================

        if (_hasActiveFilters) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(
                Icons.clear_all,
              ),
              label: const Text(
                'Clear filters',
              ),
            ),
          ),
        ],
      ],
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
          'All Expenses',
        ),
      ),

      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),
        builder: (context, snapshot) {
          // ==================================================
          // LOADING
          // ==================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                  'Error loading expenses:\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final expenses =
              snapshot.data ?? [];

          // ==================================================
          // EMPTY
          // ==================================================

          if (expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add an expense to see it here.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // ==================================================
          // APPLY FILTERS
          // ==================================================

          final filteredExpenses =
              _filterExpenses(expenses);

          final categories =
              _getCategories(expenses);

          return Column(
            children: [
              // =================================================
              // SEARCH + FILTERS
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  4,
                ),
                child:
                    _buildFilters(categories),
              ),

              // =================================================
              // RESULT COUNT
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Text(
                      '${filteredExpenses.length} '
                      '${filteredExpenses.length == 1 ? 'expense' : 'expenses'}',
                      style:
                          const TextStyle(
                        color: Colors.grey,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),

                    if (_hasActiveFilters)
                      Text(
                        'Filtered',
                        style: TextStyle(
                          color: Colors
                              .indigo.shade600,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // =================================================
              // FILTERED LIST
              // =================================================

              Expanded(
                child:
                    filteredExpenses.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 55,
                                  color:
                                      Colors.grey,
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  'No matching expenses',
                                  style:
                                      TextStyle(
                                    fontSize:
                                        18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  'Try changing your search or filters.',
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              16,
                              4,
                              16,
                              16,
                            ),
                            itemCount:
                                filteredExpenses
                                    .length,
                            itemBuilder:
                                (context, index) {
                              final expense =
                                  filteredExpenses[
                                      index];

                              return _buildExpenseCard(
                                expense,
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