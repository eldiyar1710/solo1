// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo1/main.dart';
import 'package:solo1/core/routes/app_routes.dart';

void main() {
  testWidgets('Pre-home screen renders', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Начните зарабатывать сегодня'), findsOneWidget);
    expect(find.text('Готовы начать?'), findsOneWidget);
  }, skip: true);

  testWidgets('Navigate to PreLearning from PreHome bottom nav', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Обучение'), findsWidgets);
    expect(find.text('Калькулятор'), findsWidgets);
  }, skip: true);

  testWidgets('Navigate to Demo from PreHome bottom nav', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.play_circle_outline));
    await tester.pumpAndSettle();

    expect(find.text('Демо-режим'), findsOneWidget);
  }, skip: true);

  testWidgets('Demo banner button navigates to Learning', (tester) async {
    await tester.pumpWidget(createAppForTest(initialLocation: AppRoutes.preHome));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.play_circle_outline));
    await tester.pumpAndSettle();

    expect(find.text('Демо-режим'), findsOneWidget);
    await tester.tap(find.text('Перейти к обучению'));
    await tester.pumpAndSettle();

    expect(find.text('Обучающая программа'), findsWidgets);
  }, skip: true);

  testWidgets('Demo banner button navigates to Register', (tester) async {
    await tester.pumpWidget(createAppForTest(initialLocation: AppRoutes.preHome));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.play_circle_outline));
    await tester.pumpAndSettle();

    expect(find.text('Демо-режим'), findsOneWidget);
    await tester.tap(find.text('Перейти к регистрации'));
    await tester.pumpAndSettle();

    expect(find.text('Регистрация'), findsWidgets);
  }, skip: true);
}
