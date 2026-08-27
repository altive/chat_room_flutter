import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

/// 入力長を数える単位。
enum ChatDraftLengthUnit {
  /// Unicodeの拡張書記素クラスタ単位。
  characters,

  /// バックエンド契約で利用されるUTF-16 code unit単位。
  utf16,
}

/// チャット入力の正規化、文字数計測、上限制御をまとめる方針。
@immutable
class ChatDraftPolicy {
  /// 入力方針を作成する。
  const ChatDraftPolicy({
    int? maximumLength,
    int? warningThreshold,
    this.lengthUnit = ChatDraftLengthUnit.characters,
  }) : maximumLength = maximumLength == null
           ? null
           : maximumLength < 0
           ? 0
           : maximumLength,
       warningThreshold = warningThreshold == null
           ? null
           : warningThreshold < 0
           ? 0
           : maximumLength == null
           ? warningThreshold
           : warningThreshold > (maximumLength < 0 ? 0 : maximumLength)
           ? (maximumLength < 0 ? 0 : maximumLength)
           : warningThreshold;

  /// 上限も文字数表示も持たない方針。
  const ChatDraftPolicy.unrestricted()
    : maximumLength = null,
      warningThreshold = null,
      lengthUnit = ChatDraftLengthUnit.characters;

  /// 入力可能な最大長。`null`は無制限。
  final int? maximumLength;

  /// 文字数表示を開始する長さ。`null`は文字数を表示しない。
  final int? warningThreshold;

  /// 入力長を数える単位。
  final ChatDraftLengthUnit lengthUnit;

  /// 入力値の長さを方針に沿って返す。
  int length(String value) {
    return switch (lengthUnit) {
      ChatDraftLengthUnit.characters => value.characters.length,
      ChatDraftLengthUnit.utf16 => value.codeUnits.length,
    };
  }

  /// 入力値を上限以内の完全なCharacter列へ丸める。
  String limited(String value) {
    final maximumLength = this.maximumLength;
    if (maximumLength == null || length(value) <= maximumLength) {
      return value;
    }

    final characters = value.characters;
    switch (lengthUnit) {
      case ChatDraftLengthUnit.characters:
        return characters.take(maximumLength).toString();
      case ChatDraftLengthUnit.utf16:
        var currentLength = 0;
        final result = StringBuffer();
        for (final character in characters) {
          final characterLength = character.codeUnits.length;
          if (currentLength + characterLength > maximumLength) {
            break;
          }
          result.write(character);
          currentLength += characterLength;
        }
        return result.toString();
    }
  }

  /// 前後の空白と改行を除き、送信可能な本文を返す。
  String? normalizedText(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    if (maximumLength case final maximumLength?) {
      if (length(normalized) > maximumLength) {
        return null;
      }
    }
    return normalized;
  }

  /// 現在の長さを表示すべきか返す。
  bool shouldShowLength(String value) {
    final warningThreshold = this.warningThreshold;
    return warningThreshold != null && length(value) >= warningThreshold;
  }
}
