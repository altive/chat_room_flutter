import Foundation

/// 入力長を数える単位。
public enum ChatDraftLengthUnit: Hashable, Sendable {
  /// Swift の `Character` 単位。
  case characters

  /// バックエンド契約で利用される UTF-16 code unit 単位。
  case utf16
}

/// チャット入力の正規化、文字数計測、上限制御をまとめる方針。
public struct ChatDraftPolicy: Hashable, Sendable {
  /// 入力可能な最大長。`nil` は無制限。
  public let maximumLength: Int?

  /// 文字数表示を開始する長さ。`nil` は文字数を表示しない。
  public let warningThreshold: Int?

  /// 入力長を数える単位。
  public let lengthUnit: ChatDraftLengthUnit

  /// 入力方針を作成する。
  public init(
    maximumLength: Int?,
    warningThreshold: Int? = nil,
    lengthUnit: ChatDraftLengthUnit = .characters
  ) {
    let normalizedMaximum = maximumLength.map { max(0, $0) }
    self.maximumLength = normalizedMaximum
    self.warningThreshold = warningThreshold.map { threshold in
      min(max(0, threshold), normalizedMaximum ?? threshold)
    }
    self.lengthUnit = lengthUnit
  }

  /// 上限も文字数表示も持たない方針。
  public static let unrestricted = ChatDraftPolicy(maximumLength: nil)

  /// 入力値の長さを方針に沿って返す。
  public func length(of value: String) -> Int {
    switch lengthUnit {
    case .characters:
      value.count
    case .utf16:
      value.utf16.count
    }
  }

  /// 入力値を上限以内の完全な `Character` 列へ丸める。
  public func limited(_ value: String) -> String {
    guard let maximumLength, length(of: value) > maximumLength else { return value }
    switch lengthUnit {
    case .characters:
      return String(value.prefix(maximumLength))
    case .utf16:
      var currentLength = 0
      return String(
        value.prefix { character in
          let characterLength = String(character).utf16.count
          guard currentLength + characterLength <= maximumLength else { return false }
          currentLength += characterLength
          return true
        }
      )
    }
  }

  /// 前後の空白と改行を除き、空文字の場合は `nil` を返す。
  public func normalizedText(from value: String) -> String? {
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else { return nil }
    guard maximumLength.map({ length(of: normalized) <= $0 }) ?? true else { return nil }
    return normalized
  }

  /// 現在の長さを表示すべきか返す。
  public func shouldShowLength(for value: String) -> Bool {
    guard let warningThreshold else { return false }
    return length(of: value) >= warningThreshold
  }
}
