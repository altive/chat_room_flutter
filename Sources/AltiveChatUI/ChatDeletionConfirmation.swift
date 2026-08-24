import SwiftUI

/// 削除確認の表示形式。
public enum ChatDeletionConfirmationStyle: Hashable, Sendable {
  /// 画面下部などへ選択肢を表示する。
  case confirmationDialog
  /// 警告として画面中央へ表示する。
  case alert
}

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
  @ViewBuilder
  public func chatDeletionConfirmation<Item>(
    item: Binding<Item?>,
    strings: ChatDeletionConfirmationStrings,
    style: ChatDeletionConfirmationStyle = .confirmationDialog,
    onDelete: @escaping (Item) -> Void,
    onCancel: @escaping () -> Void = {}
  ) -> some View {
    let isPresented = Binding(
      get: { item.wrappedValue != nil },
      set: { isPresented in
        guard !isPresented else { return }
        ChatDeletionConfirmationAction.dismiss(item: item, onCancel: onCancel)
      }
    )
    switch style {
    case .confirmationDialog:
      confirmationDialog(
        strings.title,
        isPresented: isPresented,
        titleVisibility: .visible,
        presenting: item.wrappedValue
      ) { selectedItem in
        deletionConfirmationActions(
          selectedItem: selectedItem,
          item: item,
          strings: strings,
          onDelete: onDelete,
          onCancel: onCancel
        )
      } message: { _ in
        deletionConfirmationMessage(strings.message)
      }
    case .alert:
      alert(
        strings.title,
        isPresented: isPresented,
        presenting: item.wrappedValue
      ) { selectedItem in
        deletionConfirmationActions(
          selectedItem: selectedItem,
          item: item,
          strings: strings,
          onDelete: onDelete,
          onCancel: onCancel
        )
      } message: { _ in
        deletionConfirmationMessage(strings.message)
      }
    }
  }

  @ViewBuilder
  private func deletionConfirmationActions<Item>(
    selectedItem: Item,
    item: Binding<Item?>,
    strings: ChatDeletionConfirmationStrings,
    onDelete: @escaping (Item) -> Void,
    onCancel: @escaping () -> Void
  ) -> some View {
    Button(strings.deleteButton, role: .destructive) {
      ChatDeletionConfirmationAction.delete(
        selectedItem,
        item: item,
        onDelete: onDelete
      )
    }
    Button(strings.cancelButton, role: .cancel) {
      ChatDeletionConfirmationAction.cancel(item: item, onCancel: onCancel)
    }
  }

  @ViewBuilder
  private func deletionConfirmationMessage(_ message: String?) -> some View {
    if let message {
      Text(message)
    }
  }
}

enum ChatDeletionConfirmationAction {
  static func delete<Item>(
    _ selectedItem: Item,
    item: Binding<Item?>,
    onDelete: (Item) -> Void
  ) {
    item.wrappedValue = nil
    onDelete(selectedItem)
  }

  static func cancel<Item>(item: Binding<Item?>, onCancel: () -> Void) {
    guard item.wrappedValue != nil else { return }
    item.wrappedValue = nil
    onCancel()
  }

  static func dismiss<Item>(item: Binding<Item?>, onCancel: () -> Void) {
    cancel(item: item, onCancel: onCancel)
  }
}
