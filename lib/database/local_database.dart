import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  static Future<void> _ensureLatestRepairJobsSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS repair_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        quotation_id INTEGER,
        payment_id INTEGER,
        device_brand TEXT NOT NULL,
        device_model TEXT NOT NULL,
        imei TEXT,
        problem_description TEXT NOT NULL,
        diagnosis TEXT,
        status TEXT NOT NULL,
        estimated_cost REAL DEFAULT 0,
        final_cost REAL DEFAULT 0,
        labor_cost REAL DEFAULT 0,
        quotation_total REAL DEFAULT 0,
        payment_amount REAL DEFAULT 0,
        outstanding_balance REAL DEFAULT 0,
        technician TEXT,
        received_at TEXT NOT NULL,
        repair_started_at TEXT,
        repair_completed_at TEXT,
        released_at TEXT,
        expected_completion TEXT,
        completed_at TEXT,
        notes TEXT,
        FOREIGN KEY (customer_id)
          REFERENCES customers(id)
          ON DELETE CASCADE
      )
    ''');

    final tableInfo = await db.rawQuery('PRAGMA table_info(repair_jobs)');
    final existingColumns = tableInfo
        .map((column) => column['name']?.toString() ?? '')
        .toSet();

    final requiredColumns = {
      'quotation_id': 'INTEGER',
      'payment_id': 'INTEGER',
      'estimated_cost': 'REAL DEFAULT 0',
      'final_cost': 'REAL DEFAULT 0',
      'labor_cost': 'REAL DEFAULT 0',
      'quotation_total': 'REAL DEFAULT 0',
      'payment_amount': 'REAL DEFAULT 0',
      'outstanding_balance': 'REAL DEFAULT 0',
      'repair_started_at': 'TEXT',
      'repair_completed_at': 'TEXT',
      'released_at': 'TEXT',
      'expected_completion': 'TEXT',
      'completed_at': 'TEXT',
    };

    for (final entry in requiredColumns.entries) {
      if (!existingColumns.contains(entry.key)) {
        await db.execute(
          'ALTER TABLE repair_jobs ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
  }

  static Future<Database> _initializeDatabase() async {
    sqfliteFfiInit();

    final databaseFactory = databaseFactoryFfi;
    final databasePath = await databaseFactory.getDatabasesPath();
    final path = '$databasePath/phonefix.db';

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 6,

        // ======================================================
        // NEW DATABASE
        // ======================================================
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE customers (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              phone TEXT NOT NULL,
              email TEXT,
              address TEXT,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE repair_jobs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customer_id INTEGER NOT NULL,
              quotation_id INTEGER,
              payment_id INTEGER,
              device_brand TEXT NOT NULL,
              device_model TEXT NOT NULL,
              imei TEXT,
              problem_description TEXT NOT NULL,
              diagnosis TEXT,
              status TEXT NOT NULL,
              estimated_cost REAL DEFAULT 0,
              final_cost REAL DEFAULT 0,
              labor_cost REAL DEFAULT 0,
              quotation_total REAL DEFAULT 0,
              payment_amount REAL DEFAULT 0,
              outstanding_balance REAL DEFAULT 0,
              technician TEXT,
              received_at TEXT NOT NULL,
              repair_started_at TEXT,
              repair_completed_at TEXT,
              released_at TEXT,
              expected_completion TEXT,
              completed_at TEXT,
              notes TEXT,
              FOREIGN KEY (customer_id)
                REFERENCES customers(id)
                ON DELETE CASCADE
            )
          ''');

          await db.execute('''
            CREATE TABLE inventory (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              part_name TEXT NOT NULL,
              category TEXT,
              compatible_device TEXT,
              quantity INTEGER NOT NULL DEFAULT 0,
              reorder_level INTEGER NOT NULL DEFAULT 1,
              cost_price REAL NOT NULL DEFAULT 0,
              selling_price REAL NOT NULL DEFAULT 0,
              supplier TEXT,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE quotations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customer_name TEXT NOT NULL,
              device TEXT NOT NULL,
              problem TEXT,
              parts_cost REAL NOT NULL,
              labor_cost REAL NOT NULL,
              total REAL NOT NULL,
              status TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE payments (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              quotation_id INTEGER,
              customer_name TEXT NOT NULL,
              amount REAL NOT NULL,
              payment_method TEXT NOT NULL,
              status TEXT NOT NULL,
              reference_number TEXT,
              created_at TEXT NOT NULL
            )
          ''');
        },

        // ======================================================
        // DATABASE MIGRATIONS
        // ======================================================
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS repair_jobs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER NOT NULL,
                device_brand TEXT NOT NULL,
                device_model TEXT NOT NULL,
                imei TEXT,
                problem_description TEXT NOT NULL,
                diagnosis TEXT,
                status TEXT NOT NULL,
                estimated_cost REAL DEFAULT 0,
                final_cost REAL DEFAULT 0,
                technician TEXT,
                received_at TEXT NOT NULL,
                expected_completion TEXT,
                completed_at TEXT,
                notes TEXT,
                FOREIGN KEY (customer_id)
                  REFERENCES customers(id)
                  ON DELETE CASCADE
              )
            ''');
          }

          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS inventory (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                part_name TEXT NOT NULL,
                category TEXT,
                compatible_device TEXT,
                quantity INTEGER NOT NULL DEFAULT 0,
                reorder_level INTEGER NOT NULL DEFAULT 1,
                cost_price REAL NOT NULL DEFAULT 0,
                selling_price REAL NOT NULL DEFAULT 0,
                supplier TEXT,
                created_at TEXT NOT NULL
              )
            ''');
          }

          if (oldVersion < 4) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS quotations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_name TEXT NOT NULL,
                device TEXT NOT NULL,
                problem TEXT,
                parts_cost REAL NOT NULL,
                labor_cost REAL NOT NULL,
                total REAL NOT NULL,
                status TEXT NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');

            await db.execute('''
              CREATE TABLE IF NOT EXISTS payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                quotation_id INTEGER,
                customer_name TEXT NOT NULL,
                amount REAL NOT NULL,
                payment_method TEXT NOT NULL,
                status TEXT NOT NULL,
                reference_number TEXT,
                created_at TEXT NOT NULL
              )
            ''');
          }

          if (oldVersion < 6) {
            await _ensureLatestRepairJobsSchema(db);
          }
        },
      ),
    );
  }

  // ==========================================================
  // CUSTOMER OPERATIONS
  // ==========================================================

  static Future<int> addCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    final db = await database;

    return await db.insert('customers', {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;

    return await db.query('customers', orderBy: 'created_at DESC');
  }

  static Future<Map<String, dynamic>?> getCustomer(int id) async {
    final db = await database;

    final results = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  static Future<int> updateCustomer({
    required int id,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    final db = await database;

    return await db.update(
      'customers',
      {'name': name, 'phone': phone, 'email': email, 'address': address},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCustomer(int id) async {
    final db = await database;

    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================
  // QUOTATION OPERATIONS
  // ==========================================================

  static Future<void> _ensureQuotationsTable() async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS quotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        device TEXT NOT NULL,
        problem TEXT,
        parts_cost REAL NOT NULL,
        labor_cost REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<int> addQuotation({
    required String customerName,
    required String device,
    String? problem,
    required double partsCost,
    required double laborCost,
    required double total,
    required String status,
  }) async {
    await _ensureQuotationsTable();

    final db = await database;

    return await db.insert('quotations', {
      'customer_name': customerName,
      'device': device,
      'problem': problem,
      'parts_cost': partsCost,
      'labor_cost': laborCost,
      'total': total,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getQuotations() async {
    await _ensureQuotationsTable();

    final db = await database;

    return await db.query('quotations', orderBy: 'created_at DESC');
  }

  static Future<int> updateQuotationStatus({
    required int id,
    required String status,
  }) async {
    await _ensureQuotationsTable();

    final db = await database;

    return await db.update(
      'quotations',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteQuotation(int id) async {
    await _ensureQuotationsTable();

    final db = await database;

    return await db.delete('quotations', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================
  // REPAIR JOB OPERATIONS
  // ==========================================================

  static Future<int> addRepairJob({
    required int customerId,
    int? quotationId,
    int? paymentId,
    required String deviceBrand,
    required String deviceModel,
    String? imei,
    required String problemDescription,
    String? diagnosis,
    String status = 'Received',
    double estimatedCost = 0,
    double finalCost = 0,
    double laborCost = 0,
    double quotationTotal = 0,
    double paymentAmount = 0,
    double outstandingBalance = 0,
    String? technician,
    String? repairStartedAt,
    String? repairCompletedAt,
    String? releasedAt,
    String? expectedCompletion,
    String? notes,
  }) async {
    final db = await database;

    return await db.insert('repair_jobs', {
      'customer_id': customerId,
      'quotation_id': quotationId,
      'payment_id': paymentId,
      'device_brand': deviceBrand,
      'device_model': deviceModel,
      'imei': imei,
      'problem_description': problemDescription,
      'diagnosis': diagnosis,
      'status': status,
      'estimated_cost': estimatedCost,
      'final_cost': finalCost,
      'labor_cost': laborCost,
      'quotation_total': quotationTotal,
      'payment_amount': paymentAmount,
      'outstanding_balance': outstandingBalance,
      'technician': technician,
      'received_at': DateTime.now().toIso8601String(),
      'repair_started_at': repairStartedAt,
      'repair_completed_at': repairCompletedAt,
      'released_at': releasedAt,
      'expected_completion': expectedCompletion,
      'notes': notes,
    });
  }

  static Future<List<Map<String, dynamic>>> getRepairJobs() async {
    final db = await database;

    return await db.query('repair_jobs', orderBy: 'received_at DESC');
  }

  static Future<Map<String, dynamic>?> getRepairJob(int id) async {
    final db = await database;

    final results = await db.query(
      'repair_jobs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  static Future<List<Map<String, dynamic>>> getRepairJobsForCustomer(
    int customerId,
  ) async {
    final db = await database;

    return await db.query(
      'repair_jobs',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'received_at DESC',
    );
  }

  static Future<int> updateRepairJob({
    required int id,
    required String deviceBrand,
    required String deviceModel,
    String? imei,
    required String problemDescription,
    String? diagnosis,
    required String status,
    double estimatedCost = 0,
    double finalCost = 0,
    double laborCost = 0,
    double quotationTotal = 0,
    double paymentAmount = 0,
    double outstandingBalance = 0,
    String? technician,
    String? repairStartedAt,
    String? repairCompletedAt,
    String? releasedAt,
    String? expectedCompletion,
    String? completedAt,
    String? notes,
  }) async {
    final db = await database;

    return await db.update(
      'repair_jobs',
      {
        'device_brand': deviceBrand,
        'device_model': deviceModel,
        'imei': imei,
        'problem_description': problemDescription,
        'diagnosis': diagnosis,
        'status': status,
        'estimated_cost': estimatedCost,
        'final_cost': finalCost,
        'labor_cost': laborCost,
        'quotation_total': quotationTotal,
        'payment_amount': paymentAmount,
        'outstanding_balance': outstandingBalance,
        'technician': technician,
        'repair_started_at': repairStartedAt,
        'repair_completed_at': repairCompletedAt,
        'released_at': releasedAt,
        'expected_completion': expectedCompletion,
        'completed_at': completedAt,
        'notes': notes,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateRepairStatus({
    required int id,
    required String status,
  }) async {
    final db = await database;

    return await db.update(
      'repair_jobs',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteRepairJob(int id) async {
    final db = await database;

    return await db.delete('repair_jobs', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================
  // PAYMENT OPERATIONS
  // ==========================================================

  static Future<void> _ensurePaymentsTable() async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotation_id INTEGER,
        customer_name TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        reference_number TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  static Future<int> addPayment({
    int? quotationId,
    required String customerName,
    required double amount,
    required String paymentMethod,
    required String status,
    String? referenceNumber,
  }) async {
    await _ensurePaymentsTable();

    final db = await database;

    return await db.insert('payments', {
      'quotation_id': quotationId,
      'customer_name': customerName,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'reference_number': referenceNumber,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getPayments() async {
    await _ensurePaymentsTable();

    final db = await database;

    return await db.query('payments', orderBy: 'created_at DESC');
  }

  static Future<Map<String, dynamic>?> getPayment(int id) async {
    await _ensurePaymentsTable();

    final db = await database;

    final results = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  static Future<int> updatePayment({
    required int id,
    required double amount,
    required String paymentMethod,
    required String status,
    String? referenceNumber,
  }) async {
    await _ensurePaymentsTable();

    final db = await database;

    return await db.update(
      'payments',
      {
        'amount': amount,
        'payment_method': paymentMethod,
        'status': status,
        'reference_number': referenceNumber,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deletePayment(int id) async {
    await _ensurePaymentsTable();

    final db = await database;

    return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================================
  // INVENTORY OPERATIONS
  // ==========================================================

  static Future<int> addInventoryItem({
    required String partName,
    String? category,
    String? compatibleDevice,
    int quantity = 0,
    int reorderLevel = 1,
    double costPrice = 0,
    double sellingPrice = 0,
    String? supplier,
  }) async {
    final db = await database;

    return await db.insert('inventory', {
      'part_name': partName,
      'category': category,
      'compatible_device': compatibleDevice,
      'quantity': quantity,
      'reorder_level': reorderLevel,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'supplier': supplier,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getInventory() async {
    final db = await database;

    return await db.query('inventory', orderBy: 'part_name ASC');
  }

  static Future<Map<String, dynamic>?> getInventoryItem(int id) async {
    final db = await database;

    final results = await db.query(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  static Future<int> updateInventoryItem({
    required int id,
    required String partName,
    String? category,
    String? compatibleDevice,
    required int quantity,
    required int reorderLevel,
    required double costPrice,
    required double sellingPrice,
    String? supplier,
  }) async {
    final db = await database;

    return await db.update(
      'inventory',
      {
        'part_name': partName,
        'category': category,
        'compatible_device': compatibleDevice,
        'quantity': quantity,
        'reorder_level': reorderLevel,
        'cost_price': costPrice,
        'selling_price': sellingPrice,
        'supplier': supplier,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteInventoryItem(int id) async {
    final db = await database;

    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateInventoryQuantity({
    required int id,
    required int quantity,
  }) async {
    final db = await database;

    return await db.update(
      'inventory',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================================
  // SETTINGS
  // ==========================================================

  static Future<void> _ensureSettingsTable() async {
    final db = await database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');
  }

  static Future<String?> getSetting(String key) async {
    await _ensureSettingsTable();

    final db = await database;

    final results = await db.query(
      'settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first['setting_value'] as String;
  }

  static Future<void> saveSetting(String key, String value) async {
    await _ensureSettingsTable();

    final db = await database;

    await db.insert('settings', {
      'setting_key': key,
      'setting_value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, String>> getAllSettings() async {
    await _ensureSettingsTable();

    final db = await database;

    final results = await db.query('settings');

    return {
      for (final row in results)
        row['setting_key'].toString(): row['setting_value'].toString(),
    };
  }
  // ==========================================================
  // REPORT / ANALYTICS OPERATIONS
  // ==========================================================

  static Future<Map<String, dynamic>> getReportSummary() async {
    final db = await database;

    final repairCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM repair_jobs'),
        ) ??
        0;

    final completedCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
            SELECT COUNT(*)
            FROM repair_jobs
            WHERE status IN ('Completed', 'Released')
            '''),
        ) ??
        0;

    final pendingCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
            SELECT COUNT(*)
            FROM repair_jobs
            WHERE status IN ('Received', 'Pending', 'In Progress')
            '''),
        ) ??
        0;

    final cancelledCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
            SELECT COUNT(*)
            FROM repair_jobs
            WHERE status = 'Cancelled'
            '''),
        ) ??
        0;

    final revenueResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM payments
      WHERE status = 'Paid'
      ''');

    final revenue = (revenueResult.first['total'] as num?)?.toDouble() ?? 0;

    final outstandingResult = await db.rawQuery('''
      SELECT COALESCE(SUM(outstanding_balance), 0) AS total
      FROM repair_jobs
      ''');

    final outstanding =
        (outstandingResult.first['total'] as num?)?.toDouble() ?? 0;

    final quotationCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM quotations'),
        ) ??
        0;

    final approvedQuotationCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
            SELECT COUNT(*)
            FROM quotations
            WHERE status = 'Approved'
            '''),
        ) ??
        0;

    final inventoryCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM inventory'),
        ) ??
        0;

    final lowStockCount =
        Sqflite.firstIntValue(
          await db.rawQuery('''
            SELECT COUNT(*)
            FROM inventory
            WHERE quantity <= reorder_level
            '''),
        ) ??
        0;

    final inventoryValueResult = await db.rawQuery('''
      SELECT COALESCE(
        SUM(quantity * cost_price),
        0
      ) AS total
      FROM inventory
      ''');

    final inventoryValue =
        (inventoryValueResult.first['total'] as num?)?.toDouble() ?? 0;

    return {
      'repair_count': repairCount,
      'completed_count': completedCount,
      'pending_count': pendingCount,
      'cancelled_count': cancelledCount,
      'revenue': revenue,
      'outstanding': outstanding,
      'quotation_count': quotationCount,
      'approved_quotation_count': approvedQuotationCount,
      'inventory_count': inventoryCount,
      'low_stock_count': lowStockCount,
      'inventory_value': inventoryValue,
    };
  }
  // ==========================================================
  // DASHBOARD OPERATIONS
  // ==========================================================

  static Future<Map<String, dynamic>> getDashboardData() async {
    final db = await database;

    // ----------------------------------------------------------
    // REPAIRS RECEIVED TODAY
    // ----------------------------------------------------------

    final repairsTodayResult = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM repair_jobs
      WHERE DATE(received_at) = DATE('now', 'localtime')
      ''');

    final repairsToday =
        (repairsTodayResult.first['total'] as num?)?.toInt() ?? 0;

    // ----------------------------------------------------------
    // AWAITING DIAGNOSIS
    // ----------------------------------------------------------

    final awaitingDiagnosisResult = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM repair_jobs
      WHERE LOWER(status) IN (
        'received',
        'pending',
        'diagnosis',
        'awaiting diagnosis',
        'diagnosing'
      )
      ''');

    final awaitingDiagnosis =
        (awaitingDiagnosisResult.first['total'] as num?)?.toInt() ?? 0;

    // ----------------------------------------------------------
    // IN REPAIR
    // ----------------------------------------------------------

    final inRepairResult = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM repair_jobs
      WHERE LOWER(status) IN (
        'repairing',
        'in repair',
        'in_progress',
        'in progress'
      )
      ''');

    final inRepair = (inRepairResult.first['total'] as num?)?.toInt() ?? 0;

    // ----------------------------------------------------------
    // READY FOR PICKUP
    // ----------------------------------------------------------

    final readyForPickupResult = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM repair_jobs
      WHERE LOWER(status) IN (
        'ready',
        'ready for pickup',
        'ready for release',
        'completed'
      )
      ''');

    final readyForPickup =
        (readyForPickupResult.first['total'] as num?)?.toInt() ?? 0;

    // ----------------------------------------------------------
    // TODAY'S REVENUE
    // ----------------------------------------------------------

    final revenueResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM payments
      WHERE LOWER(status) = 'paid'
      AND DATE(created_at) = DATE('now', 'localtime')
      ''');

    final todayRevenue =
        (revenueResult.first['total'] as num?)?.toDouble() ?? 0;

    // ----------------------------------------------------------
    // RECENT REPAIRS
    // ----------------------------------------------------------

    final recentRepairs = await db.rawQuery('''
      SELECT
        repair_jobs.id,
        repair_jobs.device_brand,
        repair_jobs.device_model,
        repair_jobs.status,
        repair_jobs.received_at,
        customers.name AS customer_name
      FROM repair_jobs
      LEFT JOIN customers
        ON customers.id = repair_jobs.customer_id
      ORDER BY repair_jobs.received_at DESC
      LIMIT 5
      ''');

    return {
      'repairs_today': repairsToday,
      'awaiting_diagnosis': awaitingDiagnosis,
      'in_repair': inRepair,
      'ready_for_pickup': readyForPickup,
      'today_revenue': todayRevenue,
      'recent_repairs': recentRepairs,
    };
  }
}
