import SwiftUI

/// ファネリーの Family Room を基準にしたシステムイベントカード。
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
    content
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(theme.systemBubble, in: RoundedRectangle(cornerRadius: 18))
      .overlay {
        RoundedRectangle(cornerRadius: 18)
          .stroke(theme.systemBubbleBorder, lineWidth: 1)
      }
  }
}
