import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

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

  /// 相手が送信したメッセージの境界線色。
  public var incomingBubbleBorder: Color

  /// システムメッセージの背景色。
  public var systemBubble: Color

  /// システムメッセージの境界線色。
  public var systemBubbleBorder: Color

  /// 入力欄の背景色。
  public var composerField: Color

  /// 入力欄の境界線色。
  public var composerFieldBorder: Color

  /// 送信ボタンの背景色。
  public var sendButtonBackground: Color

  /// 送信ボタンの前景色。
  public var sendButtonForeground: Color

  /// リアクション件数チップの背景色。
  public var reactionChipBackground: Color

  /// リアクション件数チップの境界線色。
  public var reactionChipBorder: Color

  /// リアクション選択肢の背景色。
  public var reactionPickerItemBackground: Color

  /// アバターの代替表示背景色。
  public var avatarFallbackBackground: Color

  /// アバターの代替表示前景色。
  public var avatarFallbackForeground: Color

  /// 送信失敗を示す色。
  public var deliveryFailure: Color

  /// タイムライン境界の前景色。
  public var timelineBoundaryForeground: Color

  /// celebrationカードのgradient開始色。
  public var celebrationCardBackgroundStart: Color

  /// celebrationカードのgradient終了色。
  public var celebrationCardBackgroundEnd: Color

  /// celebrationカードの境界線色。
  public var celebrationCardBorder: Color

  /// celebrationカードの前景色。
  public var celebrationCardForeground: Color

  /// celebrationカードの装飾色。
  public var celebrationCardAccent: Color

  /// チャット画面の配色を作成する。
  public init(
    background: Color = .clear,
    outgoingBubble: Color = .accentColor,
    outgoingText: Color = .white,
    incomingBubble: Color = .secondary.opacity(0.14),
    incomingText: Color = .primary,
    incomingBubbleBorder: Color = .clear,
    systemBubble: Color = .secondary.opacity(0.14),
    systemBubbleBorder: Color = .clear,
    composerField: Color = .secondary.opacity(0.12),
    composerFieldBorder: Color = .secondary.opacity(0.16),
    sendButtonBackground: Color = .accentColor,
    sendButtonForeground: Color = .white,
    reactionChipBackground: Color = .secondary.opacity(0.14),
    reactionChipBorder: Color = .secondary.opacity(0.2),
    reactionPickerItemBackground: Color = .primary.opacity(0.06),
    avatarFallbackBackground: Color = .secondary.opacity(0.14),
    avatarFallbackForeground: Color = .secondary,
    deliveryFailure: Color = .red,
    timelineBoundaryForeground: Color = .secondary,
    celebrationCardBackgroundStart: Color = .orange.opacity(0.16),
    celebrationCardBackgroundEnd: Color = .pink.opacity(0.12),
    celebrationCardBorder: Color = .orange.opacity(0.38),
    celebrationCardForeground: Color = .primary,
    celebrationCardAccent: Color = .orange
  ) {
    self.background = background
    self.outgoingBubble = outgoingBubble
    self.outgoingText = outgoingText
    self.incomingBubble = incomingBubble
    self.incomingText = incomingText
    self.incomingBubbleBorder = incomingBubbleBorder
    self.systemBubble = systemBubble
    self.systemBubbleBorder = systemBubbleBorder
    self.composerField = composerField
    self.composerFieldBorder = composerFieldBorder
    self.sendButtonBackground = sendButtonBackground
    self.sendButtonForeground = sendButtonForeground
    self.reactionChipBackground = reactionChipBackground
    self.reactionChipBorder = reactionChipBorder
    self.reactionPickerItemBackground = reactionPickerItemBackground
    self.avatarFallbackBackground = avatarFallbackBackground
    self.avatarFallbackForeground = avatarFallbackForeground
    self.deliveryFailure = deliveryFailure
    self.timelineBoundaryForeground = timelineBoundaryForeground
    self.celebrationCardBackgroundStart = celebrationCardBackgroundStart
    self.celebrationCardBackgroundEnd = celebrationCardBackgroundEnd
    self.celebrationCardBorder = celebrationCardBorder
    self.celebrationCardForeground = celebrationCardForeground
    self.celebrationCardAccent = celebrationCardAccent
  }

  /// ファネリーの Family Room を正本とする標準テーマ。
  public static var fanely: Self {
    .init(
      incomingBubble: platformSecondaryGroupedBackground,
      incomingBubbleBorder: platformSeparator.opacity(0.35),
      systemBubble: platformSecondaryGroupedBackground,
      systemBubbleBorder: platformSeparator.opacity(0.35),
      composerField: platformSecondaryBackground,
      composerFieldBorder: platformSeparator.opacity(0.28),
      reactionChipBackground: platformTertiaryFill,
      reactionChipBorder: platformSeparator.opacity(0.35),
      reactionPickerItemBackground: Color.primary.opacity(0.06)
    )
  }

  /// システム配色へ馴染む標準テーマ。
  public static var standard: Self {
    .fanely
  }

  private static var platformSecondaryGroupedBackground: Color {
    #if canImport(UIKit)
      Color(uiColor: .secondarySystemGroupedBackground)
    #elseif canImport(AppKit)
      Color(nsColor: .controlBackgroundColor)
    #else
      Color.secondary.opacity(0.14)
    #endif
  }

  private static var platformSecondaryBackground: Color {
    #if canImport(UIKit)
      Color(uiColor: .secondarySystemBackground)
    #elseif canImport(AppKit)
      Color(nsColor: .textBackgroundColor)
    #else
      Color.secondary.opacity(0.12)
    #endif
  }

  private static var platformSeparator: Color {
    #if canImport(UIKit)
      Color(uiColor: .separator)
    #elseif canImport(AppKit)
      Color(nsColor: .separatorColor)
    #else
      Color.secondary
    #endif
  }

  private static var platformTertiaryFill: Color {
    #if canImport(UIKit)
      Color(uiColor: .tertiarySystemFill)
    #elseif canImport(AppKit)
      Color(nsColor: .quaternaryLabelColor).opacity(0.16)
    #else
      Color.secondary.opacity(0.14)
    #endif
  }
}
