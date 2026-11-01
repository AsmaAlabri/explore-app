import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
 
import 'package:flutter_application_1/login.dart';
 
void main() {
  testWidgets('Login page UI test', (WidgetTester tester) async {
 
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );
 
    expect(find.text('Welcome Back'), findsOneWidget);
 
    expect(find.byType(TextFormField), findsNWidgets(2));
 
    expect(find.text('Login'), findsOneWidget);
 
    expect(find.text('Forgot Password'), findsOneWidget);
  });
 
  testWidgets('Empty email validation test', (
    WidgetTester tester,
  ) async {
 
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );
 
    await tester.tap(find.text('Login'));
 
    await tester.pump();
 
    expect(find.text('Please enter email'), findsOneWidget);
  });
 
  testWidgets('Invalid email test', (
    WidgetTester tester,
  ) async {
 
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );
 
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'wrongemail',
    );
 
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '12345678',
    );
 
    await tester.tap(find.text('Login'));
 
    await tester.pump();
 
    expect(find.text('Invalid email'), findsOneWidget);
  });
}