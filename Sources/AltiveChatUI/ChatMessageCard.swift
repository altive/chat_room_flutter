import SwiftUI

/// メッセージカードの意味的な外観。
public enum ChatMessageCardStyle: Sendable {
  /// 誕生日や記念日などのお祝いに使う外観。
  case celebration
}

/// アプリが構築した内容を表示する汎用メッセージカード。
@MainActor
public struct ChatMessageCard<Header: View, Content: View, Footer: View>: View {
  private let style: ChatMessageCardStyle
  private let isOwnMessage: Bool
  private let theme: ChatRoomTheme
  private let accessibilityLabel: String
  private let header: Header
  private let content: Content
  private let footer: Footer

  /// header、content、footerを持つメッセージカードを作成する。
  public init(
    style: ChatMessageCardStyle,
    isOwnMessage: Bool,
    theme: ChatRoomTheme = .fanely,
    accessibilityLabel: String,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer
  ) {
    self.style = style
    self.isOwnMessage = isOwnMessage
    self.theme = theme
    self.accessibilityLabel = accessibilityLabel
    self.header = header()
    self.content = content()
    self.footer = footer()
  }

  public var body: some View {
    let shape = UnevenRoundedRectangle(
      topLeadingRadius: 20,
      bottomLeadingRadius: isOwnMessage ? 20 : 8,
      bottomTrailingRadius: isOwnMessage ? 8 : 20,
      topTrailingRadius: 20
    )

    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 8) {
        header
        content
      }
      footer
    }
    .foregroundStyle(theme.celebrationCardForeground)
    .padding(16)
    .background {
      switch style {
      case .celebration:
        ZStack {
          LinearGradient(
            colors: [
              theme.celebrationCardBackgroundStart,
              theme.celebrationCardBackgroundEnd,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          ChatCelebrationDecoration(accent: theme.celebrationCardAccent)
        }
        .clipShape(shape)
      }
    }
    .overlay {
      shape.stroke(theme.celebrationCardBorder, lineWidth: 1)
    }
    .contentShape(shape)
    .accessibilityElement(children: .contain)
    .accessibilityLabel(accessibilityLabel)
  }
}

extension ChatMessageCard where Footer == EmptyView {
  /// headerとcontentを持つメッセージカードを作成する。
  public init(
    style: ChatMessageCardStyle,
    isOwnMessage: Bool,
    theme: ChatRoomTheme = .fanely,
    accessibilityLabel: String,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content
  ) {
    self.init(
      style: style,
      isOwnMessage: isOwnMessage,
      theme: theme,
      accessibilityLabel: accessibilityLabel,
      header: header,
      content: content,
      footer: EmptyView.init
    )
  }
}

@MainActor
private struct ChatCelebrationDecoration: View {
  let accent: Color

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Circle()
          .fill(accent.opacity(0.2))
          .frame(width: 10, height: 10)
          .position(x: proxy.size.width * 0.12, y: proxy.size.height * 0.18)
        Circle()
          .fill(accent.opacity(0.16))
          .frame(width: 7, height: 7)
          .position(x: proxy.size.width * 0.88, y: proxy.size.height * 0.3)
        Capsule()
          .fill(accent.opacity(0.18))
          .frame(width: 14, height: 4)
          .rotationEffect(.degrees(38))
          .position(x: proxy.size.width * 0.78, y: proxy.size.height * 0.82)
      }
    }
    .accessibilityHidden(true)
    .allowsHitTesting(false)
  }
}
