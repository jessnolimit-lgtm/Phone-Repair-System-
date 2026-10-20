import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repair_shop_system/main.dart';
import 'package:repair_shop_system/screens/quotation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  });

  testWidgets('Fixora app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PhoneRepairApp());

    expect(find.text('FIXORA'), findsOneWidget);
    expect(find.text('Repair Shop Management'), findsOneWidget);
  });

  testWidgets('quotation screen shows a data table', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: QuotationScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Quotations'), findsWidgets);
    expect(find.byType(DataTable), findsOneWidget);
  });
}
