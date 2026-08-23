import 'package:flutter/material.dart';
import '../database/local_database.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic> _report = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await LocalDatabase.getReportSummary();

      if (!mounted) return;

      setState(() {
        _report = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load reports: $e')));
    }
  }

  double _number(String key) {
    final value = _report[key];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  int _integer(String key) {
    final value = _report[key];

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  String _money(String key) {
    return '₱${_number(key).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Reports',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh reports',
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Analytics',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Overview of your repair shop performance.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),

                        const SizedBox(height: 24),

                        _buildSummaryCards(),

                        const SizedBox(height: 24),

                        _buildRepairStatus(),

                        const SizedBox(height: 24),

                        _buildFinancialOverview(),

                        const SizedBox(height: 24),

                        _buildInventoryOverview(),

                        const SizedBox(height: 24),

                        _buildQuotationOverview(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width >= 1000) {
          columns = 4;
        } else if (width >= 650) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = (width - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Revenue',
                value: _money('revenue'),
                icon: Icons.payments_outlined,
                description: 'Paid transactions',
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Total Repairs',
                value: '${_integer('repair_count')}',
                icon: Icons.build_outlined,
                description: 'All repair jobs',
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Completed',
                value: '${_integer('completed_count')}',
                icon: Icons.check_circle_outline,
                description: 'Completed or released',
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Outstanding',
                value: _money('outstanding'),
                icon: Icons.account_balance_wallet_outlined,
                description: 'Unpaid repair balances',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required String description,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB)),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
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

  Widget _buildRepairStatus() {
    final total = _integer('repair_count');

    return _sectionCard(
      title: 'Repair Status',
      icon: Icons.build_circle_outlined,
      child: Column(
        children: [
          _statusRow(
            label: 'Pending / In Progress',
            value: _integer('pending_count'),
            total: total,
            icon: Icons.pending_actions_outlined,
          ),

          const SizedBox(height: 14),

          _statusRow(
            label: 'Completed / Released',
            value: _integer('completed_count'),
            total: total,
            icon: Icons.check_circle_outline,
          ),

          const SizedBox(height: 14),

          _statusRow(
            label: 'Cancelled',
            value: _integer('cancelled_count'),
            total: total,
            icon: Icons.cancel_outlined,
          ),
        ],
      ),
    );
  }

  Widget _statusRow({
    required String label,
    required int value,
    required int total,
    required IconData icon,
  }) {
    final percentage = total > 0 ? value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF64748B)),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ),

            Text(
              '$value',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialOverview() {
    return _sectionCard(
      title: 'Financial Overview',
      icon: Icons.analytics_outlined,
      child: Column(
        children: [
          _infoRow('Total Revenue', _money('revenue'), Icons.payments_outlined),

          const Divider(height: 24),

          _infoRow(
            'Outstanding Balance',
            _money('outstanding'),
            Icons.account_balance_wallet_outlined,
          ),

          const Divider(height: 24),

          _infoRow(
            'Recorded Payments',
            '${_integer('repair_count')} repair records',
            Icons.receipt_long_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryOverview() {
    return _sectionCard(
      title: 'Inventory Overview',
      icon: Icons.inventory_2_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width < 600) {
            return Column(
              children: [
                _inventoryBox(
                  'Inventory Items',
                  '${_integer('inventory_count')}',
                  Icons.inventory_2_outlined,
                ),

                const SizedBox(height: 12),

                _inventoryBox(
                  'Low Stock',
                  '${_integer('low_stock_count')}',
                  Icons.warning_amber_outlined,
                ),

                const SizedBox(height: 12),

                _inventoryBox(
                  'Inventory Value',
                  _money('inventory_value'),
                  Icons.price_check_outlined,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _inventoryBox(
                  'Inventory Items',
                  '${_integer('inventory_count')}',
                  Icons.inventory_2_outlined,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _inventoryBox(
                  'Low Stock',
                  '${_integer('low_stock_count')}',
                  Icons.warning_amber_outlined,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _inventoryBox(
                  'Inventory Value',
                  _money('inventory_value'),
                  Icons.price_check_outlined,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _inventoryBox(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationOverview() {
    final quotations = _integer('quotation_count');

    final approved = _integer('approved_quotation_count');

    final approvalRate = quotations > 0 ? (approved / quotations) * 100 : 0;

    return _sectionCard(
      title: 'Quotation Overview',
      icon: Icons.request_quote_outlined,
      child: Column(
        children: [
          _infoRow(
            'Total Quotations',
            '$quotations',
            Icons.description_outlined,
          ),

          const Divider(height: 24),

          _infoRow(
            'Approved Quotations',
            '$approved',
            Icons.check_circle_outline,
          ),

          const Divider(height: 24),

          _infoRow(
            'Approval Rate',
            '${approvalRate.toStringAsFixed(1)}%',
            Icons.trending_up_outlined,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 21, color: const Color(0xFF64748B)),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2563EB)),

                const SizedBox(width: 10),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            child,
          ],
        ),
      ),
    );
  }
}
