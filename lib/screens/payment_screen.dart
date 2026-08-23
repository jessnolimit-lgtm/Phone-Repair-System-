import 'package:flutter/material.dart';
import '../database/local_database.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final payments = await LocalDatabase.getPayments();

      if (!mounted) return;

      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load payments: $e')));
    }
  }

  Future<void> _showAddPaymentDialog() async {
    final customerController = TextEditingController();
    final amountController = TextEditingController();
    final referenceController = TextEditingController();

    String paymentMethod = 'Cash';
    String status = 'Paid';

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Record Payment'),

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
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount *',
                            prefixText: '₱ ',
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');

                            if (amount == null || amount <= 0) {
                              return 'Enter a valid amount';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: paymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'GCash',
                              child: Text('GCash'),
                            ),
                            DropdownMenuItem(
                              value: 'Bank Transfer',
                              child: Text('Bank Transfer'),
                            ),
                            DropdownMenuItem(
                              value: 'Card',
                              child: Text('Card'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                paymentMethod = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                            labelText: 'Payment Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Paid',
                              child: Text('Paid'),
                            ),
                            DropdownMenuItem(
                              value: 'Partially Paid',
                              child: Text('Partially Paid'),
                            ),
                            DropdownMenuItem(
                              value: 'Unpaid',
                              child: Text('Unpaid'),
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

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: referenceController,
                          decoration: const InputDecoration(
                            labelText: 'Reference Number',
                            hintText: 'Optional',
                          ),
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

                    final amount = double.parse(amountController.text);

                    final reference = referenceController.text.trim().isEmpty
                        ? null
                        : referenceController.text.trim();

                    try {
                      await LocalDatabase.addPayment(
                        customerName: customerController.text.trim(),
                        amount: amount,
                        paymentMethod: paymentMethod,
                        status: status,
                        referenceNumber: reference,
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      await _loadPayments();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment recorded successfully.'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save payment: $e')),
                      );
                    }
                  },
                  child: const Text('Save Payment'),
                ),
              ],
            );
          },
        );
      },
    );

    customerController.dispose();
    amountController.dispose();
    referenceController.dispose();
  }

  Future<void> _deletePayment(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Payment?'),

          content: const Text(
            'This payment record will be permanently deleted.',
          ),

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

    try {
      await LocalDatabase.deletePayment(id);

      if (!mounted) return;

      await _loadPayments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete payment: $e')));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;

      case 'Partially Paid':
        return Colors.orange;

      case 'Unpaid':
        return Colors.red;

      default:
        return Colors.grey;
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
          'Payments',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadPayments,
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
                        'Payments',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'Record and manage customer payments.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                FilledButton.icon(
                  onPressed: _showAddPaymentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Record Payment'),
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

                child: _buildPaymentList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.payments_outlined,
              size: 60,
              color: Color(0xFF64748B),
            ),

            const SizedBox(height: 16),

            const Text(
              'No payments yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            const Text(
              'Record the first customer payment.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _showAddPaymentDialog,
              icon: const Icon(Icons.add),
              label: const Text('Record Payment'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),

      itemCount: _payments.length,

      separatorBuilder: (_, __) {
        return const Divider(height: 1);
      },

      itemBuilder: (context, index) {
        final payment = _payments[index];

        final id = payment['id'] as int;

        final customer = payment['customer_name']?.toString() ?? '';

        final amount = (payment['amount'] as num?)?.toDouble() ?? 0;

        final method = payment['payment_method']?.toString() ?? '';

        final status = payment['status']?.toString() ?? 'Unpaid';

        final reference = payment['reference_number']?.toString() ?? '';

        final statusColor = _statusColor(status);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),

          leading: Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF2563EB),
            ),
          ),

          title: Text(
            customer,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),

            child: Text(
              reference.isEmpty ? method : '$method • Ref: $reference',

              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          trailing: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    '₱${amount.toStringAsFixed(2)}',

                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),

                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),

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
                ],
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deletePayment(id);
                  }
                },

                itemBuilder: (context) => const [
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
              ),
            ],
          ),
        );
      },
    );
  }
}
