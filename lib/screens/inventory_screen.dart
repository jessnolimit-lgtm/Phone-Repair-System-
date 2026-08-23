import 'package:flutter/material.dart';
import '../database/local_database.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await LocalDatabase.getInventory();

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load inventory: $e')));
    }
  }

  bool _isLowStock(Map<String, dynamic> item) {
    final quantity = item['quantity'] as int? ?? 0;
    final reorderLevel = item['reorder_level'] as int? ?? 0;

    return quantity <= reorderLevel;
  }

  Future<void> _showAddItemDialog() async {
    final partNameController = TextEditingController();
    final categoryController = TextEditingController();
    final deviceController = TextEditingController();
    final quantityController = TextEditingController(text: '0');
    final reorderController = TextEditingController(text: '1');
    final costController = TextEditingController(text: '0');
    final sellingController = TextEditingController(text: '0');
    final supplierController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Inventory Part'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: partNameController,
                      decoration: const InputDecoration(
                        labelText: 'Part Name *',
                        hintText: 'Example: iPhone 11 Screen',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Part name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        hintText: 'Example: Screen',
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: deviceController,
                      decoration: const InputDecoration(
                        labelText: 'Compatible Device',
                        hintText: 'Example: iPhone 11',
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: (value) {
                        if (int.tryParse(value ?? '') == null) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: reorderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reorder Level',
                      ),
                      validator: (value) {
                        if (int.tryParse(value ?? '') == null) {
                          return 'Enter a valid reorder level';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Cost Price',
                        prefixText: '₱ ',
                      ),
                      validator: (value) {
                        if (double.tryParse(value ?? '') == null) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: sellingController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Selling Price',
                        prefixText: '₱ ',
                      ),
                      validator: (value) {
                        if (double.tryParse(value ?? '') == null) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: supplierController,
                      decoration: const InputDecoration(labelText: 'Supplier'),
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

                await LocalDatabase.addInventoryItem(
                  partName: partNameController.text.trim(),
                  category: categoryController.text.trim().isEmpty
                      ? null
                      : categoryController.text.trim(),
                  compatibleDevice: deviceController.text.trim().isEmpty
                      ? null
                      : deviceController.text.trim(),
                  quantity: int.parse(quantityController.text),
                  reorderLevel: int.parse(reorderController.text),
                  costPrice: double.parse(costController.text),
                  sellingPrice: double.parse(sellingController.text),
                  supplier: supplierController.text.trim().isEmpty
                      ? null
                      : supplierController.text.trim(),
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                await _loadInventory();

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inventory part added successfully.'),
                  ),
                );
              },
              child: const Text('Save Part'),
            ),
          ],
        );
      },
    );

    partNameController.dispose();
    categoryController.dispose();
    deviceController.dispose();
    quantityController.dispose();
    reorderController.dispose();
    costController.dispose();
    sellingController.dispose();
    supplierController.dispose();
  }

  Future<void> _deleteItem(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Part?'),
          content: const Text(
            'This will permanently remove this inventory item.',
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

    if (confirmed != true) return;

    await LocalDatabase.deleteInventoryItem(id);

    await _loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadInventory,
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
                        'Inventory',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Manage repair parts and monitor stock levels.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Part'),
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
                child: _buildInventoryContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Color(0xFF64748B),
            ),

            const SizedBox(height: 16),

            const Text(
              'No inventory parts yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            const Text(
              'Add your first repair part to start tracking stock.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Part'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) {
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        final item = _items[index];

        final id = item['id'] as int;
        final partName = item['part_name'] ?? '';
        final category = item['category'] ?? '';
        final device = item['compatible_device'] ?? '';
        final quantity = item['quantity'] ?? 0;
        final sellingPrice = item['selling_price'] ?? 0.0;

        final lowStock = _isLowStock(item);

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
              Icons.inventory_2_outlined,
              color: Color(0xFF2563EB),
            ),
          ),
          title: Text(
            partName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              '$category • $device',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$quantity pcs',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '₱${(sellingPrice as num).toDouble().toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              if (lowStock)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LOW STOCK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'IN STOCK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteItem(id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
