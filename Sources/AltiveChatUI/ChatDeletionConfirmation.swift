import SwiftUI

/// 削除確認で使用する文言。
public struct ChatDeletionConfirmationStrings: Hashable, Sendable {
  /// 確認タイトル。
  public let title: String
  /// 削除ボタン。
  public let deleteButton: String
  /// キャンセルボタン。
  public let cancelButton: String
  /// 確認本文。
  public let message: String?

  /// 削除確認文言を作成する。
  public init(
    title: String,
    deleteButton: String,
    cancelButton: String,
    message: String? = nil
  ) {
    self.title = title
    self.deleteButton = deleteButton
    self.cancelButton = cancelButton
    self.message = message
  }
}

extension View {
  /// 選択中の項目に共通の削除確認を表示する。
  @MainActor
  public func chatDeletionConfirmation<Item>(
    item: Binding<Item?>,
    strings: ChatDeletionConfirmationStrings,
    onDelete: @escaping (Item) -> Void,
    onCancel: @escaping () -> Void = {}
  ) -> some View {
    confirmationDialog(
      strings.title,
      isPresented: Binding(
        get: { item.wrappedValue != nil },
        set: { isPresented in
          if !isPresented {
            item.wrappedValue = nil
            onCancel()
          }
        }
      ),
      titleVisibility: .visible,
      presenting: item.wrappedValue
    ) { selectedItem in
      Button(strings.deleteButton, role: .destructive) {
        onDelete(selectedItem)
      }
      Button(strings.cancelButton, role: .cancel) {
        item.wrappedValue = nil
        onCancel()
      }
    } message: { _ in
      if let message = strings.message {
        Text(message)
      }
    }
  }
}
