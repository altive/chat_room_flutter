import SwiftUI
import Testing

@testable import AltiveChatUI

@Suite("削除確認の操作")
struct ChatDeletionConfirmationTests {
  @Test("削除ではキャンセルを通知しない")
  @MainActor
  func deletionDoesNotNotifyCancellation() {
    var selectedItem: String? = "message-a"
    var deletedItems: [String] = []
    var cancellationCount = 0
    let item = Binding(
      get: { selectedItem },
      set: { selectedItem = $0 }
    )

    ChatDeletionConfirmationAction.delete(
      "message-a",
      item: item,
      onDelete: { deletedItems.append($0) }
    )
    ChatDeletionConfirmationAction.dismiss(
      item: item,
      onCancel: { cancellationCount += 1 }
    )

    #expect(selectedItem == nil)
    #expect(deletedItems == ["message-a"])
    #expect(cancellationCount == 0)
  }

  @Test("キャンセルは一度だけ通知する")
  @MainActor
  func cancellationIsNotifiedOnce() {
    var selectedItem: String? = "message-a"
    var cancellationCount = 0
    let item = Binding(
      get: { selectedItem },
      set: { selectedItem = $0 }
    )

    ChatDeletionConfirmationAction.cancel(
      item: item,
      onCancel: { cancellationCount += 1 }
    )
    ChatDeletionConfirmationAction.dismiss(
      item: item,
      onCancel: { cancellationCount += 1 }
    )

    #expect(selectedItem == nil)
    #expect(cancellationCount == 1)
  }
}
