import SwiftUI

/// 履歴の終端など、アプリ固有導線を置くための汎用タイムライン境界。
@MainActor
public struct ChatTimelineBoundary: View {
  private let title: String
  private let systemImage: String
  private let accessibilityIdentifier: String?
  private let theme: ChatRoomTheme
  private let onAction: () -> Void

  /// タイムライン境界を作成する。
  public init(
    title: String,
    systemImage: String,
    accessibilityIdentifier: String? = nil,
    theme: ChatRoomTheme = .fanely,
    onAction: @escaping () -> Void
  ) {
    self.title = title
    self.systemImage = systemImage
    self.accessibilityIdentifier = accessibilityIdentifier
    self.theme = theme
    self.onAction = onAction
  }

  public var body: some View {
    Button(action: onAction) {
      HStack(spacing: 6) {
        Label(title, systemImage: systemImage)
        Image(systemName: "chevron.right")
          .font(.caption2.weight(.semibold))
      }
      .font(.footnote)
      .foregroundStyle(theme.timelineBoundaryForeground)
      .frame(minHeight: 44)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .applyAccessibilityIdentifier(accessibilityIdentifier)
  }
}
