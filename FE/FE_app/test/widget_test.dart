import 'package:fe_nutritionai/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NutriChef app starts on auth splash screen', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const NutriChefApp());
    await tester.pumpAndSettle();

    expect(find.text('NutriChef AI'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
