import 'package:altive_chat_room/src/extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('locale初期化なしで日付を表示できる', () {
    expect(DateTime(2026, 8, 27).dateText, 'Aug 27 (Thu)');
  });
}
