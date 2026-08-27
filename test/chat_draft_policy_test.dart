import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatDraftPolicy', () {
    test('Character単位では結合絵文字を1文字として数える', () {
      const policy = ChatDraftPolicy(maximumLength: 1);
      const family = '👨‍👩‍👧‍👦';

      expect(policy.length(family), 1);
      expect(policy.limited('${family}A'), family);
    });

    test('UTF-16単位ではサロゲートペアを分割せず上限へ丸める', () {
      const policy = ChatDraftPolicy(
        maximumLength: 3,
        lengthUnit: ChatDraftLengthUnit.utf16,
      );

      expect(policy.length('A😀B'), 4);
      expect(policy.limited('A😀B'), 'A😀');
    });

    test('前後の空白を除去し、空文字と上限超過を送信対象にしない', () {
      const policy = ChatDraftPolicy(maximumLength: 3);

      expect(policy.normalizedText('  abc\n'), 'abc');
      expect(policy.normalizedText(' \n '), isNull);
      expect(policy.normalizedText('abcd'), isNull);
    });

    test('負の上限と警告開始値を0へ正規化する', () {
      const policy = ChatDraftPolicy(
        maximumLength: -1,
        warningThreshold: -1,
      );

      expect(policy.maximumLength, 0);
      expect(policy.warningThreshold, 0);
    });
  });
}
