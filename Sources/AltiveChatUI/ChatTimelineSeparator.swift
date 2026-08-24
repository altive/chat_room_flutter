import Foundation
import SwiftUI

/// 日付や未読位置をタイムライン内で区切る共通表示。
@MainActor
public struct ChatTimelineSeparator: View {
  private let text: String
  private let accessibilityIdentifier: String?

  /// タイムライン区切りを作成する。
  public init(text: String, accessibilityIdentifier: String? = nil) {
    self.text = text
    self.accessibilityIdentifier = accessibilityIdentifier
  }

  public var body: some View {
    HStack(spacing: 12) {
      Divider()
      Text(verbatim: text)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .fixedSize()
      Divider()
    }
    .accessibilityElement(children: .combine)
    .applyAccessibilityIdentifier(accessibilityIdentifier)
  }
}

/// タイムライン区切りの挿入判定。
public enum ChatTimelineSectioning {
  /// 現在項目の前へ日付区切りを挿入するか返す。
  public static func startsNewDay(
    currentDate: Date,
    previousDate: Date?,
    calendar: Calendar = .current
  ) -> Bool {
    previousDate.map { !calendar.isDate($0, inSameDayAs: currentDate) } ?? true
  }

  /// 現在項目の前へ未読区切りを挿入するか返す。
  public static func startsUnreadSection(
    isUnread: Bool,
    wasPreviousUnread: Bool
  ) -> Bool {
    isUnread && !wasPreviousUnread
  }
}
