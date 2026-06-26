import 'package:fe_nutritionai/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NutriChef app starts on splash screen', (tester) async {
    await tester.pumpWidget(const NutriChefApp());

    expect(find.text('NutriChef AI'), findsOneWidget);
    expect(find.text('Bắt đầu ngay'), findsOneWidget);
  });
}
