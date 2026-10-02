import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense.dart';
import '../models/bill.dart';

import '../services/expense_service.dart';
import '../services/budget_service.dart';
import '../services/bill_service.dart';

import 'add_expense_screen.dart';
import 'expenses_screen.dart';
import 'bills_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final BudgetService _budgetService = BudgetService();
  final BillService _billService = BillService();

  double _monthlyBudget = 0;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  // ============================================================
  // 3D STYLE HELPERS (UI ONLY)
  // ============================================================

  // Raised card: soft light from top-left, depth shadow bottom-right
  BoxDecoration _raised(bool isDark, {double radius = 20}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF1F2A3D), Color(0xFF172033)]
            : const [Colors.white, Color(0xFFF1F4FA)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white,
        width: 1.2,
      ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(6, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(-4, -4),
              ),
            ]
          : [
              BoxShadow(
                color: const Color(0xFF8E9AC0)
                    .withValues(alpha: 0.35),
                blurRadius: 22,
                offset: const Offset(8, 10),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 16,
                offset: Offset(-6, -6),
              ),
            ],
    );
  }

  // Sunken (inset-looking) surface
  BoxDecoration _sunken(bool isDark, {double radius = 12}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF0F1727), Color(0xFF16203A)]
            : const [Color(0xFFE6EAF4), Color(0xFFF6F8FD)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
      ),
    );
  }

  // Glossy indigo gradient with deep colored shadow
  BoxDecoration _glossy(
    List<Color> colors, {
    double radius = 22,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.22),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.45),
          blurRadius: 26,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _bubble(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOAD BUDGET
  // ============================================================

  Future<void> _loadBudget() async {
    try {
      final budget = await _budgetService.getBudget();

      if (!mounted) return;

      setState(() {
        _monthlyBudget = budget ?? 0;
      });
    } catch (e) {
      debugPrint('Failed to load budget: $e');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
        ),
      );
    }
  }

  // ============================================================
  // OPEN BILLS
  // ============================================================

  void _openBills() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BillsScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1626)
          : const Color(0xFFEEF1F8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F1626)
            : const Color(0xFFEEF1F8),
        elevation: 0,
        scrolledUnderElevation: 0,

        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),

        actions: [
          // Bills
          IconButton(
            tooltip: 'Bills & Payments',
            onPressed: _openBills,
            icon: const Icon(
              Icons.receipt_long_outlined,
            ),
          ),

          // Dark mode
          IconButton(
            tooltip: isDark
                ? 'Light mode'
                : 'Dark mode',
            onPressed: () {
              widget.onThemeChanged(!isDark);
            },
            icon: Icon(
              isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),

          // Logout
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // EXPENSE STREAM
      // ========================================================

      body: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(),

        builder: (context, expenseSnapshot) {
          if (expenseSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (expenseSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading expenses:\n'
                  '${expenseSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final allExpenses =
              expenseSnapshot.data ?? [];

          // ====================================================
          // BILLS STREAM
          // ====================================================

          return StreamBuilder<List<Bill>>(
            stream: _billService.getBills(),

            builder: (context, billSnapshot) {
              if (billSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (billSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error loading bills:\n'
                      '${billSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final allBills =
                  billSnapshot.data ?? [];

              // =================================================
              // CURRENT MONTH
              // =================================================

              final now = DateTime.now();

              final monthlyExpenses =
                  allExpenses.where((expense) {
                return expense.date.year == now.year &&
                    expense.date.month == now.month;
              }).toList();

              // =================================================
              // TOTAL EXPENSES
              // =================================================

              double expenseTotal = 0;

              for (final expense
                  in monthlyExpenses) {
                expenseTotal += expense.amount;
              }

              // =================================================
              // PAID BILLS THIS MONTH
              //
              // IMPORTANT:
              // We use paidDate, NOT dueDate.
              //
              // This means a bill only affects the budget
              // after it has actually been marked as paid.
              // =================================================

              final paidBillsThisMonth =
                  allBills.where((bill) {
                if (!bill.isPaid) {
                  return false;
                }

                final paidDate = bill.paidDate;

                if (paidDate == null) {
                  return false;
                }

                return paidDate.year == now.year &&
                    paidDate.month == now.month;
              }).toList();

              // =================================================
              // TOTAL PAID BILLS
              // =================================================

              double paidBillsTotal = 0;

              for (final bill
                  in paidBillsThisMonth) {
                paidBillsTotal += bill.amount;
              }

              // =================================================
              // COMBINED SPENDING
              //
              // EXPENSES + PAID BILLS
              // =================================================

              final totalSpent =
                  expenseTotal + paidBillsTotal;

              // =================================================
              // CATEGORY TOTALS
              //
              // Keep normal expenses in the category chart.
              // Bills are displayed separately in the budget
              // calculation.
              // =================================================

              final Map<String, double>
                  categoryTotals = {};

              for (final expense
                  in monthlyExpenses) {
                categoryTotals[expense.category] =
                    (categoryTotals[
                            expense.category] ??
                        0) +
                    expense.amount;
              }

              // =================================================
              // RECENT EXPENSES
              // =================================================

              final recentExpenses =
                  List<Expense>.from(
                allExpenses,
              );

              recentExpenses.sort(
                (a, b) =>
                    b.date.compareTo(a.date),
              );

              final displayedExpenses =
                  recentExpenses.take(5).toList();

              // =================================================
              // PAGE
              // =================================================

              return RefreshIndicator(
                onRefresh: () async {
                  await _loadBudget();

                  if (mounted) {
                    setState(() {});
                  }
                },

                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    100,
                  ),

                  children: [
                    // =================================================
                    // GREETING
                    // =================================================

                    Text(
                      _greeting(),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Manage your spending',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =================================================
                    // SUMMARY
                    // =================================================

                    _buildSummaryCard(
                      expenseTotal,
                      paidBillsTotal,
                      totalSpent,
                      monthlyExpenses.length,
                      paidBillsThisMonth.length,
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // MONTHLY BUDGET
                    // =================================================

                    _buildBudgetCard(
                      totalSpent,
                      expenseTotal,
                      paidBillsTotal,
                      isDark,
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // BILLS CARD
                    // =================================================

                    _buildBillsCard(
                      paidBillsThisMonth.length,
                      paidBillsTotal,
                      isDark,
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // CATEGORY
                    // =================================================

                    const Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (categoryTotals.isEmpty)
                      _buildNoCategoryData(isDark)
                    else
                      _buildCategoryChart(
                        categoryTotals,
                        isDark,
                      ),

                    const SizedBox(height: 30),

                    // =================================================
                    // RECENT EXPENSES
                    // =================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ExpensesScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View all',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (displayedExpenses.isEmpty)
                      _buildNoExpenses(isDark)
                    else
                      ...displayedExpenses.map(
                        (expense) =>
                            _buildExpenseCard(
                          expense,
                          isDark,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ==========================================================
      // ADD EXPENSE
      // ==========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 10,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const AddExpenseScreen(),
            ),
          );

          if (mounted) {
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    double expenseTotal,
    double paidBillsTotal,
    double totalSpent,
    int expenseCount,
    int billCount,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: _glossy(
        const [
          Color(0xFF4338CA),
          Color(0xFF6366F1),
        ],
        radius: 26,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -40,
            child: _bubble(180, 0.22),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _bubble(150, 0.12),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _monthName(DateTime.now().month),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Total Spent',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Rs. ${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black
                            .withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Expense breakdown
                Row(
                  children: [
                    Expanded(
                      child: _summaryMiniItem(
                        'Expenses',
                        expenseTotal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryMiniItem(
                        'Paid Bills',
                        paidBillsTotal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.18,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '$expenseCount expenses • '
                    '$billCount paid bills',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMiniItem(
    String label,
    double amount,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUDGET CARD
  // ============================================================

  Widget _buildBudgetCard(
    double totalSpent,
    double expenseTotal,
    double paidBillsTotal,
    bool isDark,
  ) {
    final remaining =
        _monthlyBudget - totalSpent;

    final progress = _monthlyBudget <= 0
        ? 0.0
        : (totalSpent / _monthlyBudget)
            .clamp(0.0, 1.0);

    final barColors = remaining >= 0
        ? const [
            Color(0xFF818CF8),
            Color(0xFF4F46E5),
          ]
        : const [
            Color(0xFFF87171),
            Color(0xFFDC2626),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _raised(isDark),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                onPressed: _showBudgetDialog,
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Rs. ${_monthlyBudget.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 3D progress bar: sunken track + raised fill
          Container(
            height: 14,
            padding: const EdgeInsets.all(2),
            decoration: _sunken(isDark, radius: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: barColors,
                    ),
                    borderRadius:
                        BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: barColors.last
                            .withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Expense breakdown
          Row(
            children: [
              Expanded(
                child: _budgetDetail(
                  'Expenses',
                  expenseTotal,
                  isDark,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _budgetDetail(
                  'Paid Bills',
                  paidBillsTotal,
                  isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Total used: Rs. '
                  '${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white60
                        : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  remaining >= 0
                      ? 'Remaining: Rs. '
                          '${remaining.toStringAsFixed(2)}'
                      : 'Over budget: Rs. '
                          '${remaining.abs().toStringAsFixed(2)}',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: remaining >= 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetDetail(
    String label,
    double amount,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _sunken(isDark),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? Colors.white60
                  : Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BILLS CARD
  // ============================================================

  Widget _buildBillsCard(
    int paidBillCount,
    double paidBillsTotal,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: _glossy(
        const [
          Color(0xFF5B21B6),
          Color(0xFF7C3AED),
        ],
        radius: 22,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -20,
            child: _bubble(130, 0.2),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white
                            .withValues(alpha: 0.32),
                        Colors.white
                            .withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bills & Payments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        paidBillCount == 0
                            ? 'No bills paid this month'
                            : '$paidBillCount paid • '
                                'Rs. ${paidBillsTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white
                              .withValues(alpha: 0.82),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: _openBills,
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Open Bills',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY CHART
  // ============================================================

  Widget _buildCategoryChart(
    Map<String, double> categoryTotals,
    bool isDark,
  ) {
    final total =
        categoryTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    final entries =
        categoryTotals.entries.toList()
          ..sort(
            (a, b) =>
                b.value.compareTo(a.value),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _raised(isDark),
      child: Column(
        children: [
          SizedBox(
            height: 230,
            width: 230,
            child: CustomPaint(
              painter: _PieChartPainter(
                categoryTotals:
                    categoryTotals,
                isDark: isDark,
              ),
              child: Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      'Expenses',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Column(
            children:
                entries.map((entry) {
              final percentage =
                  total == 0
                      ? 0
                      : (entry.value /
                              total) *
                          100;

              final color =
                  _categoryColor(
                entry.key,
                entries,
              );

              return Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 7,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration:
                          BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(
                            -0.4,
                            -0.4,
                          ),
                          colors: [
                            Color.lerp(
                              color,
                              Colors.white,
                              0.45,
                            )!,
                            color,
                          ],
                        ),
                        shape:
                            BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color
                                .withValues(
                                    alpha: 0.5),
                            blurRadius: 5,
                            offset:
                                const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        entry.key,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),

                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      'Rs. ${entry.value.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO CATEGORY DATA
  // ============================================================

  Widget _buildNoCategoryData(
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: _raised(isDark),
      child: Column(
        children: [
          const Icon(
            Icons.pie_chart_outline,
            size: 55,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          const Text(
            'No category data yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Add expenses to see your spending breakdown.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white60
                  : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPENSE CARD
  // ============================================================

  Widget _buildExpenseCard(
    Expense expense,
    bool isDark,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      decoration: _raised(isDark, radius: 16),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),

        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F3FF),
                Color(0xFFDDD6FE),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5)
                    .withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getCategoryIcon(
              expense.category,
            ),
            color:
                const Color(0xFF4F46E5),
          ),
        ),

        title: Text(
          expense.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '${expense.category} • '
          '${expense.date.day}/'
          '${expense.date.month}/'
          '${expense.date.year}',
          style: TextStyle(
            color: isDark
                ? Colors.white60
                : Colors.grey,
            fontSize: 12,
          ),
        ),

        trailing: Text(
          'Rs. ${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NO EXPENSES
  // ============================================================

  Widget _buildNoExpenses(
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: _raised(isDark, radius: 18),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 50,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          const Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Add an expense to see it here.',
            style: TextStyle(
              color: isDark
                  ? Colors.white60
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUDGET DIALOG
  // ============================================================

  Future<void> _showBudgetDialog() async {
    final newBudget =
        await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return _BudgetDialog(
          currentBudget: _monthlyBudget,
        );
      },
    );

    if (newBudget == null) return;

    try {
      await _budgetService.saveBudget(
        newBudget,
      );

      if (!mounted) return;

      setState(() {
        _monthlyBudget = newBudget;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Monthly budget updated',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save budget: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;

      case 'transport':
        return Icons.directions_car;

      case 'shopping':
        return Icons.shopping_bag;

      case 'bills':
        return Icons.receipt_long;

      case 'entertainment':
        return Icons.movie;

      case 'health':
        return Icons.health_and_safety;

      case 'education':
        return Icons.school;

      case 'travel':
        return Icons.flight;

      case 'salary':
        return Icons.account_balance_wallet;

      default:
        return Icons.category_outlined;
    }
  }

  // ============================================================
  // CATEGORY COLOR
  // ============================================================

  Color _categoryColor(
    String category,
    List<MapEntry<String, double>> entries,
  ) {
    final index = entries.indexWhere(
      (entry) => entry.key == category,
    );

    const colors = [
      Color(0xFF4F46E5),
      Color(0xFFEC4899),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
      Color(0xFF84CC16),
      Color(0xFFF97316),
      Color(0xFF14B8A6),
    ];

    return colors[
        index < 0 ? 0 : index % colors.length];
  }

  // ============================================================
  // GREETING
  // ============================================================

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning ☀️';
    }

    if (hour < 17) {
      return 'Good afternoon 👋';
    }

    return 'Good evening 🌙';
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return '${months[month - 1]} '
        '${DateTime.now().year}';
  }
}

// =================================================================
// PIE CHART (3D DONUT)
// =================================================================

class _PieChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final bool isDark;

  _PieChartPainter({
    required this.categoryTotals,
    required this.isDark,
  });

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness(
          (hsl.lightness - amount).clamp(0.0, 1.0),
        )
        .toColor();
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final total =
        categoryTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    if (total <= 0) return;

    final radius =
        math.min(size.width, size.height) / 2 - 12;

    final center = Offset(
      size.width / 2,
      size.height / 2 - 6,
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    const depth = Offset(0, 8);

    final extrudedRect = rect.shift(depth);

    final entries =
        categoryTotals.entries.toList();

    const colors = [
      Color(0xFF4F46E5),
      Color(0xFFEC4899),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
      Color(0xFF84CC16),
      Color(0xFFF97316),
      Color(0xFF14B8A6),
    ];

    // Ground shadow
    canvas.drawCircle(
      center + const Offset(0, 18),
      radius * 0.92,
      Paint()
        ..color = Colors.black
            .withValues(alpha: isDark ? 0.5 : 0.22)
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Extruded side (darker, shifted down)
    double sideAngle = -math.pi / 2;

    final sidePaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < entries.length; i++) {
      final sweep =
          (entries[i].value / total) * math.pi * 2;

      sidePaint.color =
          _darken(colors[i % colors.length], 0.18);

      canvas.drawArc(
        extrudedRect,
        sideAngle,
        sweep,
        true,
        sidePaint,
      );

      sideAngle += sweep;
    }

    // Fill gap between top and side layers
    for (double d = 1; d < depth.dy; d += 1) {
      double a = -math.pi / 2;

      for (int i = 0; i < entries.length; i++) {
        final sweep =
            (entries[i].value / total) *
                math.pi *
                2;

        sidePaint.color = _darken(
          colors[i % colors.length],
          0.18,
        );

        canvas.drawArc(
          rect.shift(Offset(0, d)),
          a,
          sweep,
          true,
          sidePaint,
        );

        a += sweep;
      }
    }

    // Top face
    double startAngle = -math.pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0;
        i < entries.length;
        i++) {
      final value = entries[i].value;

      final sweepAngle =
          (value / total) * math.pi * 2;

      paint.color =
          colors[i % colors.length];

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Slice separators
    double sepAngle = -math.pi / 2;

    final sepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.55);

    for (int i = 0; i < entries.length; i++) {
      final sweep =
          (entries[i].value / total) * math.pi * 2;

      canvas.drawArc(
        rect,
        sepAngle,
        sweep,
        true,
        sepPaint,
      );

      sepAngle += sweep;
    }

    // Light shading over the top face
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.55),
          radius: 1.1,
          colors: [
            Colors.white.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.20),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // Center of donut
    final holeRadius = radius * 0.55;

    canvas.drawCircle(
      center + const Offset(0, 2),
      holeRadius + 2,
      Paint()
        ..color = Colors.black
            .withValues(alpha: 0.28)
        ..maskFilter =
            const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final holeRect = Rect.fromCircle(
      center: center,
      radius: holeRadius,
    );

    final centerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [
                Color(0xFF1F2A3D),
                Color(0xFF172033),
              ]
            : const [
                Colors.white,
                Color(0xFFF1F4FA),
              ],
      ).createShader(holeRect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      holeRadius,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PieChartPainter oldDelegate,
  ) {
    return oldDelegate.categoryTotals !=
            categoryTotals ||
        oldDelegate.isDark != isDark;
  }
}

// =================================================================
// BUDGET DIALOG
// =================================================================

class _BudgetDialog extends StatefulWidget {
  final double currentBudget;

  const _BudgetDialog({
    required this.currentBudget,
  });

  @override
  State<_BudgetDialog> createState() =>
      _BudgetDialogState();
}

class _BudgetDialogState
    extends State<_BudgetDialog> {
  late final TextEditingController
      _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.currentBudget == 0
          ? ''
          : widget.currentBudget
              .toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: const Text(
        'Set Monthly Budget',
      ),

      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: 'Budget amount',
          prefixText: 'Rs. ',
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
          ),
        ),

        ElevatedButton(
          onPressed: () {
            final amount =
                double.tryParse(
              _controller.text.trim(),
            );

            if (amount == null ||
                amount <= 0) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter a valid budget amount',
                  ),
                ),
              );

              return;
            }

            Navigator.pop(
              context,
              amount,
            );
          },
          child: const Text(
            'Save',
          ),
        ),
      ],
    );
  }
}