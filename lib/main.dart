import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'database/local_database.dart';
import 'screens/customers_screen.dart';
import 'screens/repair_jobs_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/quotation_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';

const String supabaseUrl = 'https://mfhpnjueeulvoiqwkdoy.supabase.co';
const String supabaseAnonKey = 'sb_publishable_LrhzcJeTaP8NrD7hellJyQ_bNv_aLKd';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );
  runApp(const PhoneRepairApp());
}

class PhoneRepairApp extends StatelessWidget {
  const PhoneRepairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fixora',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
      ),
      home: Supabase.instance.client.auth.currentSession != null
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful! Welcome back, ${response.user?.email ?? "User"}'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Invalid credentials.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'An error occurred during authentication.';
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password recovery will be added later.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.build_rounded,
                          size: 34,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'FIXORA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Repair Shop Management',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 36),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _signIn(),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Offline-ready system',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await LocalDatabase.getDashboardData();

      if (!mounted) return;

      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load dashboard: $e')));
    }
  }

  int _getInt(String key) {
    final value = _dashboardData[key];

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  double _getDouble(String key) {
    final value = _dashboardData[key];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  Future<void> _openScreen(Widget screen) async {
    Navigator.pop(context);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (!mounted) return;

    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final recentRepairs =
        _dashboardData['recent_repairs'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.build_rounded,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'FIXORA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              const Text(
                'Repair Shop Management',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 30),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('Dashboard'),
                selected: true,
                selectedColor: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.pop(context);
                  _loadDashboard();
                },
              ),

              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Customers'),
                onTap: () {
                  _openScreen(const CustomersScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.phone_android_outlined),
                title: const Text('Repair Jobs'),
                onTap: () {
                  _openScreen(const RepairJobsScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Inventory'),
                onTap: () {
                  _openScreen(const InventoryScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Quotations'),
                onTap: () {
                  _openScreen(const QuotationScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Payments'),
                onTap: () {
                  _openScreen(const PaymentScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.bar_chart_outlined),
                title: const Text('Reports'),
                onTap: () {
                  _openScreen(const ReportsScreen());
                },
              ),

              const Spacer(),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  _openScreen(const SettingsScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () async {
                  try {
                    await Supabase.instance.client.auth.signOut();
                  } catch (_) {}
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),

          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 6),
                Text(
                  'Offline',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF15803D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good day, Owner',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Here is what is happening in your repair shop today.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                    ),

                    const SizedBox(height: 28),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;

                        int columns = 1;

                        if (width >= 1100) {
                          columns = 4;
                        } else if (width >= 700) {
                          columns = 2;
                        }

                        final cardWidth =
                            (width - ((columns - 1) * 16)) / columns;

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            DashboardStatCard(
                              width: cardWidth,
                              title: 'Repairs Today',
                              value: '${_getInt('repairs_today')}',
                              icon: Icons.phone_android,
                              iconBackground: const Color(0xFFEFF6FF),
                              iconColor: const Color(0xFF2563EB),
                            ),

                            DashboardStatCard(
                              width: cardWidth,
                              title: 'Diagnosing',
                              value: '${_getInt('awaiting_diagnosis')}',
                              icon: Icons.search,
                              iconBackground: const Color(0xFFFFF7ED),
                              iconColor: const Color(0xFFEA580C),
                            ),

                            DashboardStatCard(
                              width: cardWidth,
                              title: 'In Repair',
                              value: '${_getInt('in_repair')}',
                              icon: Icons.build_outlined,
                              iconBackground: const Color(0xFFF5F3FF),
                              iconColor: const Color(0xFF7C3AED),
                            ),

                            DashboardStatCard(
                              width: cardWidth,
                              title: 'Ready for Release',
                              value: '${_getInt('ready_for_pickup')}',
                              icon: Icons.check_circle_outline,
                              iconBackground: const Color(0xFFF0FDF4),
                              iconColor: const Color(0xFF16A34A),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 800) {
                          return Column(
                            children: [
                              RevenueCard(revenue: _getDouble('today_revenue')),

                              const SizedBox(height: 20),

                              RecentRepairsCard(repairs: recentRepairs),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RevenueCard(
                                revenue: _getDouble('today_revenue'),
                              ),
                            ),

                            const SizedBox(width: 20),

                            Expanded(
                              child: RecentRepairsCard(repairs: recentRepairs),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ============================================================
// DASHBOARD STAT CARD
// ============================================================

class DashboardStatCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const DashboardStatCard({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
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
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REVENUE CARD
// ============================================================

class RevenueCard extends StatelessWidget {
  final double revenue;

  const RevenueCard({super.key, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Revenue',
              style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 8),

            Text(
              '₱${revenue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(
                  Icons.storage_outlined,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),

                SizedBox(width: 6),

                Text(
                  'Live database data',
                  style: TextStyle(
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Payments recorded today',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RECENT REPAIRS
// ============================================================

class RecentRepairsCard extends StatelessWidget {
  final List<dynamic> repairs;

  const RecentRepairsCard({super.key, required this.repairs});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'ready':
      case 'ready for pickup':
        return const Color(0xFF16A34A);

      case 'repairing':
      case 'in repair':
      case 'in_progress':
      case 'in progress':
        return const Color(0xFF7C3AED);

      case 'diagnosis':
      case 'awaiting diagnosis':
        return const Color(0xFFEA580C);

      case 'cancelled':
      case 'canceled':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Repairs',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 18),

            if (repairs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No repair jobs yet.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              )
            else
              ...List.generate(repairs.length, (index) {
                final repair = repairs[index];

                final id = repair['id'];
                final brand = repair['device_brand'] ?? '';
                final model = repair['device_model'] ?? '';
                final status = repair['status'] ?? 'Unknown';

                final device = '$brand $model'.trim();

                return Column(
                  children: [
                    RepairRow(
                      repairNumber: 'REP-${id.toString().padLeft(5, '0')}',
                      device: device.isEmpty ? 'Unknown device' : device,
                      status: status.toString(),
                      statusColor: _statusColor(status.toString()),
                    ),

                    if (index < repairs.length - 1) const Divider(height: 24),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REPAIR ROW
// ============================================================

class RepairRow extends StatelessWidget {
  final String repairNumber;
  final String device;
  final String status;
  final Color statusColor;

  const RepairRow({
    super.key,
    required this.repairNumber,
    required this.device,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.phone_android_outlined,
            color: Color(0xFF475569),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                repairNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                device,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
