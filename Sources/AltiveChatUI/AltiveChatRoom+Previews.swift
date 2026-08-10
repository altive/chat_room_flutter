#if DEBUG
  import SwiftUI

  @MainActor
  private struct AltiveChatRoomPreview: View {
    @State private var draft = ""

    private let me = ChatUser(id: "me", displayName: "Me")
    private let other = ChatUser(id: "other", displayName: "Altive")

    var body: some View {
      AltiveChatRoom(
        messages: [
          .init(
            id: "system",
            createdAt: .init(timeIntervalSince1970: 1_700_000_000),
            sender: nil,
            content: .system("Conversation started")
          ),
          .init(
            id: "incoming",
            createdAt: .init(timeIntervalSince1970: 1_700_000_060),
            sender: other,
            content: .text("Hello!")
          ),
          .init(
            id: "outgoing",
            createdAt: .init(timeIntervalSince1970: 1_700_000_120),
            sender: me,
            content: .text("Hello, Altive!"),
            deliveryState: .sending
          ),
        ],
        currentUserID: me.id,
        draft: $draft,
        showsSenderName: true,
        onSend: { _ in }
      )
    }
  }

  #Preview("Messages") {
    AltiveChatRoomPreview()
  }

  #Preview("Empty") {
    AltiveChatRoom(
      messages: [],
      currentUserID: "me",
      draft: .constant(""),
      onSend: { _ in }
    )
  }
#endif
