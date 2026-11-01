import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/reset_password.dart';

void main() {
  testWidgets('Reset password UI test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));

    expect(find.text('Reset Your Password'), findsOneWidget);

    expect(
      find.widgetWithText(ElevatedButton, 'Reset Password'),
      findsOneWidget,
    );
  });

  testWidgets('Empty old password validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));

    await tester.pump();

    expect(find.text('Enter old password'), findsOneWidget);
  });

  testWidgets('Weak password validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'OldPassword123!');

    await tester.enterText(find.byType(TextFormField).at(1), '123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));

    await tester.pump();

    expect(find.text('Weak password'), findsOneWidget);
  });

  testWidgets('New password must be different from old password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ResetPasswordPage()));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'SamePassword123!',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'SamePassword123!',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));

    await tester.pump();

    expect(find.text('New password must be different'), findsOneWidget);
  });
}
