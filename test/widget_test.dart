import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isto_king/main.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(430, 932)]) {
    testWidgets('Isto board screen fits ${size.width}x${size.height}', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const IstoKingApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Rammohan'), findsNWidgets(2));
      expect(find.text('Chandrakishore'), findsOneWidget);
      expect(find.text('Aaradhya'), findsOneWidget);
      expect(find.text('Shaurya'), findsOneWidget);
      expect(find.text('Current Turn:'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);

      final boardRect = tester.getRect(find.byType(GameBoard));
      expect(GameBoardPainter.gridCount, 5);
      expect(GameBoardPainter.playerHomes, hasLength(4));
      for (final home in GameBoardPainter.playerHomes) {
        expect(home.arrowCol, greaterThanOrEqualTo(0));
        expect(home.arrowCol, lessThan(GameBoardPainter.gridCount));
        expect(home.arrowRow, greaterThanOrEqualTo(0));
        expect(home.arrowRow, lessThan(GameBoardPainter.gridCount));
        expect(home.col, inInclusiveRange(0, GameBoardPainter.gridCount - 1));
        expect(home.row, inInclusiveRange(0, GameBoardPainter.gridCount - 1));
        final columnDistance = (home.arrowCol - home.col).abs();
        final rowDistance = (home.arrowRow - home.row).abs();
        expect(columnDistance + rowDistance, 1);
      }
      expect(boardRect.width, closeTo(boardRect.height, 0.01));
      expect(boardRect.center.dx, closeTo(size.width / 2, 1));

      final root = Rect.fromLTWH(0, 0, size.width, size.height);
      for (final widget in find.byType(PlayerCard).evaluate()) {
        final rect = tester.getRect(find.byWidget(widget.widget));
        expect(root.contains(rect.topLeft), isTrue);
        expect(root.contains(rect.bottomRight), isTrue);
      }
    });
  }
}
