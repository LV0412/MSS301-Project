import 'package:fe_nutritionai/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget subject({
    required List<Map<String, dynamic>> dietPreferences,
    required List<Map<String, dynamic>> allergies,
    required List<Map<String, dynamic>> allergenOptions,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DietPreferenceSection(
            dietPreferences: dietPreferences,
            allergies: allergies,
            allergenOptions: allergenOptions,
          ),
        ),
      ),
    );
  }

  testWidgets('shows detailed diet preferences and allergy severities', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        dietPreferences: const [
          {'dietType': 'VEGAN'},
          {'dietType': 'MEDITERRANEAN'},
        ],
        allergies: const [
          {'allergenId': 1, 'severity': 'HIGH'},
          {'allergenId': 2, 'severity': 'LOW'},
        ],
        allergenOptions: const [
          {'allergenId': 1, 'name': 'Sữa'},
          {'allergenId': 2, 'name': 'Đậu phộng'},
        ],
      ),
    );

    expect(find.text('Thuần chay'), findsOneWidget);
    expect(find.text('Địa Trung Hải'), findsOneWidget);
    expect(find.text('Sữa'), findsOneWidget);
    expect(find.text('Nặng'), findsOneWidget);
    expect(find.text('Đậu phộng'), findsOneWidget);
    expect(find.text('Nhẹ'), findsOneWidget);
    expect(find.textContaining('dị ứng đã ghi nhận'), findsNothing);
  });

  testWidgets('shows explicit empty states', (tester) async {
    await tester.pumpWidget(
      subject(
        dietPreferences: const [],
        allergies: const [],
        allergenOptions: const [],
      ),
    );

    expect(find.text('Chưa cập nhật chế độ ăn'), findsOneWidget);
    expect(find.text('Chưa ghi nhận dị ứng'), findsOneWidget);
  });
}
