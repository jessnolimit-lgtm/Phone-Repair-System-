import 'package:flutter/material.dart';
import '../database/local_database.dart';

class RepairJobsScreen extends StatefulWidget {
  const RepairJobsScreen({super.key});

  @override
  State<RepairJobsScreen> createState() => _RepairJobsScreenState();
}

class _RepairJobsScreenState extends State<RepairJobsScreen> {
  List<Map<String, dynamic>> _repairJobs = [];
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRepairJobs();
  }

  Future<void> _loadRepairJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jobs = await LocalDatabase.getRepairJobs();
      final customers = await LocalDatabase.getCustomers();

      if (!mounted) return;

      setState(() {
        _repairJobs = jobs;
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load repair jobs: $e')));
    }
  }

  Future<void> _showAddRepairJobDialog() async {
    int? selectedCustomerId;
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final imeiController = TextEditingController();
    final problemController = TextEditingController();
    final diagnosisController = TextEditingController();
    final technicianController = TextEditingController();
    final expectedCompletionController = TextEditingController();
    final notesController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    String status = 'Received';

    final customerOptions = _customers;

    if (customerOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a customer before creating a repair job.'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Repair Job'),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: selectedCustomerId,
                          hint: const Text('Select customer'),
                          decoration: const InputDecoration(
                            labelText: 'Customer *',
                          ),
                          items: customerOptions.map((customer) {
                            final id = customer['id'] as int;
                            final name =
                                customer['name']?.toString() ?? 'Customer';
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedCustomerId = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: brandController,
                          decoration: const InputDecoration(
                            labelText: 'Device Brand *',
                            hintText: 'Apple',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Device brand is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: modelController,
                          decoration: const InputDecoration(
                            labelText: 'Device Model *',
                            hintText: 'iPhone 11',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Device model is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: imeiController,
                          decoration: const InputDecoration(
                            labelText: 'IMEI',
                            hintText: 'Optional',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: problemController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Problem Description *',
                            hintText: 'Broken display / battery issue',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Problem description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: diagnosisController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Diagnosis',
                            hintText: 'Initial diagnosis',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Received',
                              child: Text('Received'),
                            ),
                            DropdownMenuItem(
                              value: 'Diagnosing',
                              child: Text('Diagnosing'),
                            ),
                            DropdownMenuItem(
                              value: 'Waiting for Approval',
                              child: Text('Waiting for Approval'),
                            ),
                            DropdownMenuItem(
                              value: 'Waiting for Parts',
                              child: Text('Waiting for Parts'),
                            ),
                            DropdownMenuItem(
                              value: 'Approved',
                              child: Text('Approved'),
                            ),
                            DropdownMenuItem(
                              value: 'In Repair',
                              child: Text('In Repair'),
                            ),
                            DropdownMenuItem(
                              value: 'Ready for Release',
                              child: Text('Ready for Release'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
                            ),
                            DropdownMenuItem(
                              value: 'Released',
                              child: Text('Released'),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelled',
                              child: Text('Cancelled'),
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
                          controller: technicianController,
                          decoration: const InputDecoration(
                            labelText: 'Technician',
                            hintText: 'Optional',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: expectedCompletionController,
                          decoration: const InputDecoration(
                            labelText: 'Expected Completion',
                            hintText: '2026-08-20',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            hintText: 'Customer notes / billing remarks',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final customerId = selectedCustomerId;
                      if (customerId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a customer.'),
                          ),
                        );
                        return;
                      }

                      await LocalDatabase.addRepairJob(
                        customerId: customerId,
                        deviceBrand: brandController.text.trim(),
                        deviceModel: modelController.text.trim(),
                        imei: imeiController.text.trim().isEmpty
                            ? null
                            : imeiController.text.trim(),
                        problemDescription: problemController.text.trim(),
                        diagnosis: diagnosisController.text.trim().isEmpty
                            ? null
                            : diagnosisController.text.trim(),
                        status: status,
                        technician: technicianController.text.trim().isEmpty
                            ? null
                            : technicianController.text.trim(),
                        expectedCompletion:
                            expectedCompletionController.text.trim().isEmpty
                            ? null
                            : expectedCompletionController.text.trim(),
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);
                      await _loadRepairJobs();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Repair job created successfully.'),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save repair job: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Repair Job'),
                ),
              ],
            );
          },
        );
      },
    );

    brandController.dispose();
    modelController.dispose();
    imeiController.dispose();
    problemController.dispose();
    diagnosisController.dispose();
    technicianController.dispose();
    expectedCompletionController.dispose();
    notesController.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Received':
        return const Color(0xFF2563EB);

      case 'Diagnosing':
        return const Color(0xFFEA580C);

      case 'Waiting for Approval':
        return const Color(0xFFD97706);

      case 'Waiting for Parts':
        return const Color(0xFF7C3AED);

      case 'Approved':
        return const Color(0xFF0891B2);

      case 'In Repair':
        return const Color(0xFF7C3AED);

      case 'Ready for Release':
        return const Color(0xFF16A34A);

      case 'Completed':
        return const Color(0xFF15803D);

      case 'Released':
        return const Color(0xFF0F766E);

      case 'Cancelled':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFF64748B);
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
          'Repair Jobs',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadRepairJobs,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
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
                        'Repair Jobs',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Track and manage customer repair jobs.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                FilledButton.icon(
                  onPressed: _showAddRepairJobDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Repair Job'),
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
                child: _buildRepairJobsContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepairJobsContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_repairJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.phone_android_outlined,
                size: 36,
                color: Color(0xFF2563EB),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No repair jobs yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Create a repair job when a customer brings in a device.',
              style: TextStyle(color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _showAddRepairJobDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Repair Job'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _repairJobs.length,
      separatorBuilder: (_, __) {
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        final job = _repairJobs[index];

        final id = job['id'];
        final brand = job['device_brand'] ?? '';
        final model = job['device_model'] ?? '';
        final problem = job['problem_description'] ?? '';
        final status = job['status'] ?? 'UNKNOWN';

        final cost = job['estimated_cost'] ?? 0;

        final statusColor = _statusColor(status);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.phone_android_outlined,
              color: Color(0xFF2563EB),
            ),
          ),

          title: Text(
            'REP-${id.toString().padLeft(5, '0')}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '$brand $model • $problem',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                '₱${cost.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
