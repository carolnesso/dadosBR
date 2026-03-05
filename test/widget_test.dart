import 'package:flutter_test/flutter_test.dart';

import 'package:dadosbr/app.dart';

void main() {
  testWidgets('App navigates from splash to home', (WidgetTester tester) async {
    await tester.pumpWidget(const DadosBrApp());

    expect(find.byType(DadosBrApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('O que deseja procurar hoje?'), findsOneWidget);
  });
}
