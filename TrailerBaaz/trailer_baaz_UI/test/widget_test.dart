import 'package:flutter_test/flutter_test.dart';
import 'package:trailer_baaz_ui/app/trailer_baaz_app.dart';

void main() {
  testWidgets('TrailerBaaz renders the home experience', (tester) async {
    await tester.pumpWidget(const TrailerBaazApp());
    await tester.pump();

    expect(find.text('TrailerBaaz'), findsOneWidget);
    expect(find.text('Watch Trailer'), findsWidgets);
  });
}
