import Foundation

/// 入力中テキストを送信可能な形式へ整える処理。
enum ChatComposer {
  /// 前後の空白と改行を除き、空文字の場合は `nil` を返す。
  static func normalizedText(from draft: String) -> String? {
    let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    return value.isEmpty ? nil : value
  }
}
