import SwiftUI

/// メッセージ種別に応じて1件分を表示する行。
@MainActor
public struct ChatMessageRow: View {
  private let message: ChatMessage
  private let currentUserID: String
  private let theme: ChatRoomTheme
  private let strings: ChatRoomStrings
  private let showsSenderName: Bool
  private let onRetry: (() -> Void)?

  /// 1件分のメッセージ行を作成する。
  public init(
    message: ChatMessage,
    currentUserID: String,
    theme: ChatRoomTheme = .fanely,
    strings: ChatRoomStrings = .localized,
    showsSenderName: Bool = false,
    onRetry: (() -> Void)? = nil
  ) {
    self.message = message
    self.currentUserID = currentUserID
    self.theme = theme
    self.strings = strings
    self.showsSenderName = showsSenderName
    self.onRetry = onRetry
  }

  public var body: some View {
    switch message.content {
    case .text(let text):
      userMessage(text)
    case .system(let text):
      systemMessage(text)
    }
  }

  private func userMessage(_ text: String) -> some View {
    let isOwnMessage = message.isSent(by: currentUserID)

    return HStack(alignment: .bottom, spacing: 8) {
      if isOwnMessage {
        Spacer(minLength: 44)
      }

      VStack(alignment: isOwnMessage ? .trailing : .leading, spacing: 4) {
        if showsSenderName, !isOwnMessage {
          Text(message.sender?.displayName ?? strings.unknownSender)
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        ChatMessageBubble(isOwnMessage: isOwnMessage, theme: theme) {
          Text(text)
            .textSelection(.enabled)
        }

        HStack(spacing: 5) {
          Text(message.createdAt.formatted(date: .omitted, time: .shortened))

          ChatDeliveryIndicator(
            state: message.deliveryState,
            sendingLabel: strings.sendingLabel,
            retryLabel: strings.failedLabel,
            controlSize: .mini,
            theme: theme,
            onRetry: onRetry
          )
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
      }
      .accessibilityElement(children: .combine)

      if !isOwnMessage {
        Spacer(minLength: 44)
      }
    }
    .frame(maxWidth: .infinity)
  }

  private func systemMessage(_ text: String) -> some View {
    ChatSystemEventCard(theme: theme) {
      VStack(spacing: 4) {
        Text(text)
          .font(.footnote)
          .multilineTextAlignment(.center)

        Text(message.createdAt.formatted(date: .omitted, time: .shortened))
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}
