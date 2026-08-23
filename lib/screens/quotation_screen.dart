import 'package:flutter/material.dart';
import '../database/local_database.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  List<Map<String, dynamic>> _quotations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<void> _loadQuotations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final quotations = await LocalDatabase.getQuotations();

      if (!mounted) return;

      setState(() {
        _quotations = quotations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load quotations: $e')));
    }
  }

  Future<void> _showAddQuotationDialog() async {
    final customerController = TextEditingController();
    final deviceController = TextEditingController();
    final problemController = TextEditingController();
    final partsController = TextEditingController(text: '0');
    final laborController = TextEditingController(text: '0');

    String status = 'Waiting for Approval';

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Quotation'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: customerController,
                          decoration: const InputDecoration(
                            labelText: 'Customer *',
                            hintText: 'Juan Dela Cruz',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Customer is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: deviceController,
                          decoration: const InputDecoration(
                            labelText: 'Device *',
                            hintText: 'iPhone 11',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Device is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: problemController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Problem / Description',
                            hintText: 'Broken screen',
                            alignLabelWithHint: true,
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: partsController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Parts Cost',
                            prefixText: '₱ ',
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');

                            if (amount == null || amount < 0) {
                              return 'Enter a valid amount';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: laborController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Labor Cost',
                            prefixText: '₱ ',
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');

                            if (amount == null || amount < 0) {
                              return 'Enter a valid amount';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Draft',
                              child: Text('Draft'),
                            ),
                            DropdownMenuItem(
                              value: 'Waiting for Approval',
                              child: Text('Waiting for Approval'),
                            ),
                            DropdownMenuItem(
                              value: 'Approved',
                              child: Text('Approved'),
                            ),
                            DropdownMenuItem(
                              value: 'Rejected',
                              child: Text('Rejected'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                status = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final partsCost = double.parse(partsController.text);

                    final laborCost = double.parse(laborController.text);

                    final total = partsCost + laborCost;

                    await LocalDatabase.addQuotation(
                      customerName: customerController.text.trim(),
                      device: deviceController.text.trim(),
                      problem: problemController.text.trim(),
                      partsCost: partsCost,
                      laborCost: laborCost,
                      total: total,
                      status: status,
                    );

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    await _loadQuotations();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quotation saved successfully.'),
                      ),
                    );
                  },
                  child: const Text('Save Quotation'),
                ),
              ],
            );
          },
        );
      },
    );

    customerController.dispose();
    deviceController.dispose();
    problemController.dispose();
    partsController.dispose();
    laborController.dispose();
  }

  Future<void> _updateStatus(int id, String status) async {
    await LocalDatabase.updateQuotationStatus(id: id, status: status);

    if (!mounted) return;

    await _loadQuotations();
  }

  Future<void> _deleteQuotation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Quotation?'),
          content: const Text('This quotation will be permanently deleted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await LocalDatabase.deleteQuotation(id);

    if (!mounted) return;

    await _loadQuotations();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;

      case 'Rejected':
        return Colors.red;

      case 'Draft':
        return Colors.grey;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Quotations',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadQuotations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quotations',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'Create and manage repair quotations.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                FilledButton.icon(
                  onPressed: _showAddQuotationDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Quotation'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),

                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),

                child: _buildQuotationList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotationList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_quotations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Color(0xFF64748B),
            ),

            const SizedBox(height: 16),

            const Text(
              'No quotations yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            const Text(
              'Create a quotation for a customer repair.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _showAddQuotationDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Quotation'),
            ),
          ],
        ),
      );
    }

    final rows = _quotations.isEmpty
        ? [
            const DataRow(
              cells: [
                DataCell(Text('No quotations yet')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
                DataCell(Text('-')),
              ],
            ),
          ]
        : _quotations.map((quotation) {
            final id = quotation['id'] as int;
            final customer = quotation['customer_name']?.toString() ?? '';
            final device = quotation['device']?.toString() ?? '';
            final problem = quotation['problem']?.toString() ?? 'N/A';
            final total = (quotation['total'] as num?)?.toDouble() ?? 0;
            final status =
                quotation['status']?.toString() ?? 'Waiting for Approval';
            final statusColor = _statusColor(status);

            return DataRow(
              cells: [
                DataCell(Text(customer)),
                DataCell(Text(device)),
                DataCell(Text(problem)),
                DataCell(Text('₱${total.toStringAsFixed(2)}')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'approve') {
                        _updateStatus(id, 'Approved');
                      }
                      if (value == 'reject') {
                        _updateStatus(id, 'Rejected');
                      }
                      if (value == 'waiting') {
                        _updateStatus(id, 'Waiting for Approval');
                      }
                      if (value == 'delete') {
                        _deleteQuotation(id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'approve',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 10),
                            Text('Approve'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reject',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_outlined),
                            SizedBox(width: 10),
                            Text('Reject'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'waiting',
                        child: Row(
                          children: [
                            Icon(Icons.pending_outlined),
                            SizedBox(width: 10),
                            Text('Waiting Approval'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            );
          }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Device')),
            DataColumn(label: Text('Problem')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: rows,
        ),
      ),
    );
  }
}
