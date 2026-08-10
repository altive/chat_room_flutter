import AltiveChatCore
import SwiftUI

/// メッセージの左右配置。
public enum ChatMessageAlignment: Hashable, Sendable {
  /// 相手側へ配置する。
  case incoming

  /// 自分側へ配置する。
  case outgoing
}

/// 投稿済みリアクションを横スクロール可能なチップで表示する部品。
@MainActor
public struct ChatReactionSummaryBar: View {
  private let counts: [ChatReactionCount]
  private let alignment: ChatMessageAlignment
  private let loadingReactionID: String?
  private let isEnabled: Bool
  private let theme: ChatRoomTheme
  private let onSelect: ((ChatReaction) -> Void)?

  /// リアクション件数表示を作成する。
  public init(
    counts: [ChatReactionCount],
    alignment: ChatMessageAlignment,
    loadingReactionID: String? = nil,
    isEnabled: Bool = true,
    theme: ChatRoomTheme = .fanely,
    onSelect: ((ChatReaction) -> Void)? = nil
  ) {
    self.counts = counts.filter { $0.count > 0 }
    self.alignment = alignment
    self.loadingReactionID = loadingReactionID
    self.isEnabled = isEnabled
    self.theme = theme
    self.onSelect = onSelect
  }

  public var body: some View {
    if !counts.isEmpty {
      ScrollView(.horizontal) {
        HStack(spacing: 4) {
          ForEach(counts) { item in
            if let onSelect {
              Button {
                onSelect(item.reaction)
              } label: {
                chip(item)
              }
              .buttonStyle(.plain)
              .disabled(!isEnabled || loadingReactionID == item.id)
            } else {
              chip(item)
            }
          }
        }
        .frame(
          maxWidth: .infinity,
          alignment: alignment == .outgoing ? .trailing : .leading
        )
      }
      .scrollIndicators(.hidden)
    }
  }

  private func chip(_ item: ChatReactionCount) -> some View {
    HStack(spacing: 3) {
      Text(verbatim: item.reaction.symbol)
        .font(.footnote)
      if loadingReactionID == item.id {
        ProgressView()
          .controlSize(.mini)
      } else {
        Text(verbatim: String(item.count))
          .font(.caption2.bold().monospacedDigit())
          .foregroundStyle(.secondary)
      }
    }
    .padding(.horizontal, 7)
    .padding(.vertical, 3)
    .background(theme.reactionChipBackground, in: Capsule())
    .overlay {
      Capsule()
        .stroke(theme.reactionChipBorder, lineWidth: 0.5)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(item.reaction.accessibilityLabel) \(item.count)")
  }
}

/// 長押し後に表示するリアクション候補とアプリ固有操作の並び。
@MainActor
public struct ChatReactionPicker<TrailingActions: View>: View {
  private let reactions: [ChatReaction]
  private let isEnabled: Bool
  private let showsTrailingActions: Bool
  private let theme: ChatRoomTheme
  private let onSelect: (ChatReaction) -> Void
  private let trailingActions: TrailingActions

  /// リアクション候補と末尾操作を作成する。
  public init(
    reactions: [ChatReaction] = ChatReaction.standard,
    isEnabled: Bool = true,
    showsTrailingActions: Bool = true,
    theme: ChatRoomTheme = .fanely,
    onSelect: @escaping (ChatReaction) -> Void,
    @ViewBuilder trailingActions: () -> TrailingActions
  ) {
    self.reactions = reactions
    self.isEnabled = isEnabled
    self.showsTrailingActions = showsTrailingActions
    self.theme = theme
    self.onSelect = onSelect
    self.trailingActions = trailingActions()
  }

  public var body: some View {
    HStack(spacing: 4) {
      ForEach(reactions) { reaction in
        Button {
          onSelect(reaction)
        } label: {
          Text(verbatim: reaction.symbol)
            .font(.title2)
            .frame(width: 44, height: 44)
            .background(theme.reactionPickerItemBackground, in: Circle())
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(reaction.accessibilityLabel)
      }

      if showsTrailingActions {
        if !reactions.isEmpty {
          Divider()
            .frame(height: 24)
        }
        trailingActions
      }
    }
    .padding(8)
    .fixedSize()
  }
}

extension ChatReactionPicker where TrailingActions == EmptyView {
  /// リアクション候補だけを作成する。
  public init(
    reactions: [ChatReaction] = ChatReaction.standard,
    isEnabled: Bool = true,
    theme: ChatRoomTheme = .fanely,
    onSelect: @escaping (ChatReaction) -> Void
  ) {
    self.init(
      reactions: reactions,
      isEnabled: isEnabled,
      showsTrailingActions: false,
      theme: theme,
      onSelect: onSelect,
      trailingActions: { EmptyView() }
    )
  }
}
