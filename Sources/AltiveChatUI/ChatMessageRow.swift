import SwiftUI

/// メッセージ種別に応じて1件分を表示する行。
@MainActor
struct ChatMessageRow: View {
  let message: ChatMessage
  let currentUserID: String
  let theme: ChatRoomTheme
  let strings: ChatRoomStrings
  let showsSenderName: Bool

  var body: some View {
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

        Text(text)
          .foregroundStyle(isOwnMessage ? theme.outgoingText : theme.incomingText)
          .textSelection(.enabled)
          .padding(.horizontal, 12)
          .padding(.vertical, 9)
          .background(
            isOwnMessage ? theme.outgoingBubble : theme.incomingBubble,
            in: RoundedRectangle(cornerRadius: 17)
          )

        HStack(spacing: 5) {
          Text(message.createdAt.formatted(date: .omitted, time: .shortened))

          switch message.deliveryState {
          case .sent:
            EmptyView()
          case .sending:
            Text(strings.sendingLabel)
          case .failed:
            Text(strings.failedLabel)
              .foregroundStyle(.red)
          }
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
    VStack(spacing: 4) {
      Text(text)
        .font(.footnote)
        .multilineTextAlignment(.center)

      Text(message.createdAt.formatted(date: .omitted, time: .shortened))
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(theme.systemBubble, in: Capsule())
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}
