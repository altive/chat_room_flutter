import Foundation
import SwiftUI

/// タイムライン区切りの外観。
public enum ChatTimelineSeparatorStyle: Hashable, Sendable {
  /// 日付などを明確に示す強調表示。
  case emphasized
  /// 未読位置などへ馴染ませる控えめな表示。
  case subtle
}

/// 日付や未読位置をタイムライン内で区切る共通表示。
@MainActor
public struct ChatTimelineSeparator: View {
  private let text: String
  private let accessibilityIdentifier: String?
  private let style: ChatTimelineSeparatorStyle

  /// タイムライン区切りを作成する。
  public init(
    text: String,
    accessibilityIdentifier: String? = nil,
    style: ChatTimelineSeparatorStyle = .emphasized
  ) {
    self.text = text
    self.accessibilityIdentifier = accessibilityIdentifier
    self.style = style
  }

  public var body: some View {
    HStack(spacing: style == .emphasized ? 12 : nil) {
      Divider()
      Text(verbatim: text)
        .font(style == .emphasized ? .caption.weight(.semibold) : .caption)
        .foregroundStyle(.secondary)
        .fixedSize(
          horizontal: style == .emphasized,
          vertical: style == .emphasized
        )
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
