import SwiftUI

/// チャット画面の意味的な配色。
public struct ChatRoomTheme {
  /// 画面背景色。
  public var background: Color

  /// 自分が送信したメッセージの背景色。
  public var outgoingBubble: Color

  /// 自分が送信したメッセージの文字色。
  public var outgoingText: Color

  /// 相手が送信したメッセージの背景色。
  public var incomingBubble: Color

  /// 相手が送信したメッセージの文字色。
  public var incomingText: Color

  /// システムメッセージの背景色。
  public var systemBubble: Color

  /// 入力欄の背景色。
  public var composerField: Color

  /// チャット画面の配色を作成する。
  public init(
    background: Color = .clear,
    outgoingBubble: Color = .accentColor,
    outgoingText: Color = .white,
    incomingBubble: Color = .secondary.opacity(0.14),
    incomingText: Color = .primary,
    systemBubble: Color = .secondary.opacity(0.14),
    composerField: Color = .secondary.opacity(0.12)
  ) {
    self.background = background
    self.outgoingBubble = outgoingBubble
    self.outgoingText = outgoingText
    self.incomingBubble = incomingBubble
    self.incomingText = incomingText
    self.systemBubble = systemBubble
    self.composerField = composerField
  }

  /// システム配色へ馴染む標準テーマ。
  public static var standard: Self {
    .init()
  }
}
