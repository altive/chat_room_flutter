import SwiftUI

/// 共通UI契約に従い、内容を水平中央へ配置するシステムイベントカード。
@MainActor
public struct ChatSystemEventCard<Content: View>: View {
  private let theme: ChatRoomTheme
  private let content: Content

  /// システムイベントカードを作成する。
  public init(
    theme: ChatRoomTheme = .fanely,
    @ViewBuilder content: () -> Content
  ) {
    self.theme = theme
    self.content = content()
  }

  public var body: some View {
    HStack(spacing: 0) {
      Spacer(minLength: 0)
      cardSurface(
        content.multilineTextAlignment(.center)
      )
      .fixedSize(horizontal: false, vertical: true)
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity)
  }

  private func cardSurface(_ content: some View) -> some View {
    content
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(theme.systemBubble, in: RoundedRectangle(cornerRadius: 18))
      .overlay {
        RoundedRectangle(cornerRadius: 18)
          .stroke(theme.systemBubbleBorder, lineWidth: 1)
      }
  }
}
