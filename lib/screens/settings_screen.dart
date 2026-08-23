import 'package:flutter/material.dart';
import '../database/local_database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _laborController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _completionController = TextEditingController();

  final _quotationValidityController = TextEditingController();
  final _lowStockController = TextEditingController();

  String _currency = 'PHP';
  String _theme = 'System';
  bool _lowStockWarning = true;
  bool _includeCancelled = false;
  bool _notifications = true;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await LocalDatabase.getAllSettings();

    if (!mounted) return;

    _shopNameController.text = settings['shop_name'] ?? 'PhoneFix';

    _addressController.text = settings['shop_address'] ?? '';

    _phoneController.text = settings['shop_phone'] ?? '';

    _emailController.text = settings['shop_email'] ?? '';

    _laborController.text = settings['default_labor'] ?? '0';

    _warrantyController.text = settings['warranty_days'] ?? '30';

    _completionController.text = settings['default_completion_days'] ?? '3';

    _quotationValidityController.text =
        settings['quotation_validity_days'] ?? '7';

    _lowStockController.text = settings['low_stock_threshold'] ?? '5';

    setState(() {
      _currency = settings['currency'] ?? 'PHP';
      _theme = settings['theme'] ?? 'System';

      _lowStockWarning = settings['low_stock_warning'] != 'false';

      _includeCancelled = settings['include_cancelled'] == 'true';

      _notifications = settings['notifications'] != 'false';

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    await LocalDatabase.saveSetting(
      'shop_name',
      _shopNameController.text.trim(),
    );

    await LocalDatabase.saveSetting(
      'shop_address',
      _addressController.text.trim(),
    );

    await LocalDatabase.saveSetting('shop_phone', _phoneController.text.trim());

    await LocalDatabase.saveSetting('shop_email', _emailController.text.trim());

    await LocalDatabase.saveSetting(
      'default_labor',
      _laborController.text.trim(),
    );

    await LocalDatabase.saveSetting(
      'warranty_days',
      _warrantyController.text.trim(),
    );

    await LocalDatabase.saveSetting(
      'default_completion_days',
      _completionController.text.trim(),
    );

    await LocalDatabase.saveSetting(
      'quotation_validity_days',
      _quotationValidityController.text.trim(),
    );

    await LocalDatabase.saveSetting(
      'low_stock_threshold',
      _lowStockController.text.trim(),
    );

    await LocalDatabase.saveSetting('currency', _currency);

    await LocalDatabase.saveSetting('theme', _theme);

    await LocalDatabase.saveSetting(
      'low_stock_warning',
      _lowStockWarning.toString(),
    );

    await LocalDatabase.saveSetting(
      'include_cancelled',
      _includeCancelled.toString(),
    );

    await LocalDatabase.saveSetting('notifications', _notifications.toString());

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully.')),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About PhoneFix'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PhoneFix',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Phone Repair Shop Management System'),
              SizedBox(height: 16),
              Text(
                'Offline-first business management software '
                'for managing customers, repair jobs, '
                'quotations, inventory, payments, and reports.',
              ),
              SizedBox(height: 16),
              Text('Version 1.0', style: TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    _laborController.dispose();
    _warrantyController.dispose();
    _completionController.dispose();

    _quotationValidityController.dispose();
    _lowStockController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Configure your PhoneFix business system.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),

                // =================================================
                // BUSINESS PROFILE
                // =================================================
                _sectionTitle(
                  'Business Profile',
                  'Information displayed on quotations and business records.',
                ),

                _card(
                  child: Column(
                    children: [
                      _textField(
                        controller: _shopNameController,
                        label: 'Shop Name',
                        hint: 'PhoneFix',
                      ),

                      const SizedBox(height: 16),

                      _textField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'Shop address',
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              controller: _phoneController,
                              label: 'Phone',
                              keyboardType: TextInputType.phone,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: _textField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // =================================================
                // REPAIR SETTINGS
                // =================================================
                _sectionTitle(
                  'Repair Settings',
                  'Default values used when creating repair jobs.',
                ),

                _card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              controller: _laborController,
                              label: 'Default Labor Charge',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: _textField(
                              controller: _warrantyController,
                              label: 'Warranty Period (days)',
                              keyboardType: TextInputType.number,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: _textField(
                              controller: _completionController,
                              label: 'Expected Completion (days)',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // =================================================
                // QUOTATION & PAYMENT
                // =================================================
                _sectionTitle(
                  'Quotation & Payment',
                  'Default settings for quotations and financial records.',
                ),

                _card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              controller: _quotationValidityController,
                              label: 'Quotation Validity (days)',
                              keyboardType: TextInputType.number,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _currency,
                              decoration: const InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'PHP',
                                  child: Text('PHP - Philippine Peso'),
                                ),
                                DropdownMenuItem(
                                  value: 'USD',
                                  child: Text('USD - US Dollar'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  _currency = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // =================================================
                // INVENTORY
                // =================================================
                _sectionTitle(
                  'Inventory',
                  'Control stock monitoring behavior.',
                ),

                _card(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,

                    title: const Text(
                      'Low Stock Warnings',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    subtitle: const Text(
                      'Show warnings when inventory reaches the threshold.',
                    ),

                    value: _lowStockWarning,

                    onChanged: (value) {
                      setState(() {
                        _lowStockWarning = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                _card(
                  child: _textField(
                    controller: _lowStockController,
                    label: 'Low Stock Threshold',
                    hint: '5',
                    keyboardType: TextInputType.number,
                  ),
                ),

                // =================================================
                // REPORTS
                // =================================================
                _sectionTitle(
                  'Reports',
                  'Control how business analytics are calculated.',
                ),

                _card(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,

                    title: const Text(
                      'Include Cancelled Repairs',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    subtitle: const Text(
                      'Include cancelled repair jobs in report calculations.',
                    ),

                    value: _includeCancelled,

                    onChanged: (value) {
                      setState(() {
                        _includeCancelled = value;
                      });
                    },
                  ),
                ),

                // =================================================
                // APPLICATION
                // =================================================
                _sectionTitle(
                  'Application',
                  'General PhoneFix application preferences.',
                ),

                _card(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _theme,

                        decoration: const InputDecoration(
                          labelText: 'Theme',
                          border: OutlineInputBorder(),
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: 'System',
                            child: Text('System Default'),
                          ),
                          DropdownMenuItem(
                            value: 'Light',
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                        ],

                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _theme = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,

                        title: const Text(
                          'Notifications',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: const Text(
                          'Enable application notifications and alerts.',
                        ),

                        value: _notifications,

                        onChanged: (value) {
                          setState(() {
                            _notifications = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // =================================================
                // DATABASE & BACKUP
                // =================================================
                _sectionTitle(
                  'Database & Backup',
                  'Your PhoneFix data is stored locally on this computer.',
                ),

                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.storage_outlined,
                            color: Color(0xFF2563EB),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Local Database',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  'phonefix.db',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'PhoneFix uses a local SQLite database so the system can continue operating without an internet connection.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),

                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Database backup/export will be available in the next backup module.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.backup_outlined),
                        label: const Text('Backup Database'),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // ABOUT
                // =================================================
                _sectionTitle('About', 'Information about this application.'),

                _card(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.phone_android,
                        color: Color(0xFF2563EB),
                      ),
                    ),

                    title: const Text(
                      'PhoneFix',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),

                    subtitle: const Text(
                      'Phone Repair Shop Management System • Version 1.0',
                    ),

                    trailing: const Icon(Icons.chevron_right),

                    onTap: _showAboutDialog,
                  ),
                ),

                const SizedBox(height: 32),

                // =================================================
                // SAVE BUTTON
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveSettings,

                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),

                    label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
