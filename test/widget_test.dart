import 'package:flutter/material.dart';
import 'package:flutter_application_unid2/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Clica NO BOTÃO que contém o ícone de "+"
    await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
