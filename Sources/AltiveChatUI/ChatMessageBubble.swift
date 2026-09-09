import SwiftUI

/// 共通UI契約に従うユーザーメッセージの吹き出し。
@MainActor
public struct ChatMessageBubble<Content: View>: View {
  private let isOwnMessage: Bool
  private let theme: ChatRoomTheme
  private let content: Content

  /// ユーザーメッセージの吹き出しを作成する。
  public init(
    isOwnMessage: Bool,
    theme: ChatRoomTheme = .fanely,
    @ViewBuilder content: () -> Content
  ) {
    self.isOwnMessage = isOwnMessage
    self.theme = theme
    self.content = content()
  }

  public var body: some View {
    let bubbleShape = ChatMessageBubbleShape(isOwnMessage: isOwnMessage)
    content
      .foregroundStyle(isOwnMessage ? theme.outgoingText : theme.incomingText)
      .padding(.leading, isOwnMessage ? 16 : 24)
      .padding(.trailing, isOwnMessage ? 24 : 16)
      .padding(.vertical, 14)
      .background(
        isOwnMessage ? theme.outgoingBubble : theme.incomingBubble,
        in: bubbleShape
      )
      .overlay {
        bubbleShape.stroke(
          isOwnMessage ? Color.clear : theme.incomingBubbleBorder,
          lineWidth: 1
        )
      }
  }
}

/// 投稿者のアバター側へ尻尾を伸ばすメッセージ形状。
public struct ChatMessageBubbleShape: Shape {
  /// 自分が送信したメッセージかどうか。
  public let isOwnMessage: Bool

  /// メッセージ形状を作成する。
  public init(isOwnMessage: Bool) {
    self.isOwnMessage = isOwnMessage
  }

  public func path(in rect: CGRect) -> Path {
    let tailWidth: CGFloat = 8
    let radius = min(CGFloat(18), rect.height / 2)
    let bodyMinX = isOwnMessage ? rect.minX : rect.minX + tailWidth
    let bodyMaxX = isOwnMessage ? rect.maxX - tailWidth : rect.maxX
    let tailTipX = isOwnMessage ? rect.maxX : rect.minX
    let tailBaseX = isOwnMessage ? bodyMaxX : bodyMinX
    var path = Path()

    path.move(to: CGPoint(x: bodyMinX + radius, y: rect.minY))
    path.addLine(to: CGPoint(x: bodyMaxX - radius, y: rect.minY))
    path.addQuadCurve(
      to: CGPoint(x: bodyMaxX, y: rect.minY + radius),
      control: CGPoint(x: bodyMaxX, y: rect.minY)
    )

    if isOwnMessage {
      path.addLine(to: CGPoint(x: bodyMaxX, y: rect.maxY - 18))
      path.addCurve(
        to: CGPoint(x: tailTipX, y: rect.maxY),
        control1: CGPoint(x: bodyMaxX, y: rect.maxY - 9),
        control2: CGPoint(x: tailTipX - 4, y: rect.maxY - 4)
      )
      path.addCurve(
        to: CGPoint(x: tailBaseX - 14, y: rect.maxY),
        control1: CGPoint(x: tailTipX - 4, y: rect.maxY),
        control2: CGPoint(x: tailBaseX - 8, y: rect.maxY)
      )
    } else {
      path.addLine(to: CGPoint(x: bodyMaxX, y: rect.maxY - radius))
      path.addQuadCurve(
        to: CGPoint(x: bodyMaxX - radius, y: rect.maxY),
        control: CGPoint(x: bodyMaxX, y: rect.maxY)
      )
      path.addLine(to: CGPoint(x: tailBaseX + 14, y: rect.maxY))
      path.addCurve(
        to: CGPoint(x: tailTipX, y: rect.maxY),
        control1: CGPoint(x: tailBaseX + 8, y: rect.maxY),
        control2: CGPoint(x: tailTipX + 4, y: rect.maxY)
      )
      path.addCurve(
        to: CGPoint(x: bodyMinX, y: rect.maxY - 18),
        control1: CGPoint(x: tailTipX + 4, y: rect.maxY - 4),
        control2: CGPoint(x: bodyMinX, y: rect.maxY - 9)
      )
    }

    if isOwnMessage {
      path.addLine(to: CGPoint(x: bodyMinX + radius, y: rect.maxY))
      path.addQuadCurve(
        to: CGPoint(x: bodyMinX, y: rect.maxY - radius),
        control: CGPoint(x: bodyMinX, y: rect.maxY)
      )
    }
    path.addLine(to: CGPoint(x: bodyMinX, y: rect.minY + radius))
    path.addQuadCurve(
      to: CGPoint(x: bodyMinX + radius, y: rect.minY),
      control: CGPoint(x: bodyMinX, y: rect.minY)
    )
    path.closeSubpath()
    return path
  }
}
