import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repair_shop_system/main.dart';
import 'package:repair_shop_system/screens/quotation_screen.dart';

void main() {
  testWidgets('PhoneFix app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const PhoneRepairApp());

    expect(find.text('PHONEFIX'), findsOneWidget);
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
