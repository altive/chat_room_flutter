import SwiftUI

/// システムイベント展開ボタンの文言。
public struct ChatSystemEventGroupStrings: Hashable, Sendable {
  /// 展開操作のVoiceOver名。
  public let expandLabel: String

  /// 折りたたみ操作のVoiceOver名。
  public let collapseLabel: String

  /// 展開ボタンの文言を作成する。
  public init(expandLabel: String, collapseLabel: String) {
    self.expandLabel = expandLabel
    self.collapseLabel = collapseLabel
  }

  /// Package内のローカライズ済み文言。
  public static var localized: Self {
    .init(
      expandLabel: String(localized: "chat.system.expand", bundle: .module),
      collapseLabel: String(localized: "chat.system.collapse", bundle: .module)
    )
  }
}

/// システムイベントの要約、展開一覧、アプリ固有操作を合成するカード。
@MainActor
public struct ChatSystemEventGroup<Summary: View, Actions: View>: View {
  private let items: [ChatSystemEventItem]
  private let strings: ChatSystemEventGroupStrings
  private let theme: ChatRoomTheme
  private let summary: Summary
  private let actions: Actions

  @State private var isExpanded = false

  /// システムイベントグループを作成する。
  public init(
    items: [ChatSystemEventItem],
    strings: ChatSystemEventGroupStrings = .localized,
    theme: ChatRoomTheme = .fanely,
    @ViewBuilder summary: () -> Summary,
    @ViewBuilder actions: () -> Actions
  ) {
    self.items = items
    self.strings = strings
    self.theme = theme
    self.summary = summary()
    self.actions = actions()
  }

  public var body: some View {
    ChatSystemEventCard(theme: theme) {
      VStack(alignment: .leading, spacing: 12) {
        HStack(alignment: .center, spacing: 10) {
          summary
          if items.count > 1 {
            Button {
              withAnimation(.snappy(duration: 0.18)) {
                isExpanded.toggle()
              }
            } label: {
              HStack(spacing: 3) {
                Text(verbatim: "×\(items.count)")
                  .font(.caption.bold().monospacedDigit())
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                  .font(.caption2.bold())
              }
              .foregroundStyle(.secondary)
              .padding(.horizontal, 8)
              .padding(.vertical, 5)
              .background(theme.reactionChipBackground, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isExpanded ? strings.collapseLabel : strings.expandLabel)
          }
        }

        if isExpanded {
          Divider()
          VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
              HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(item.occurredAt, style: .time)
                  .font(.caption2.monospacedDigit())
                  .foregroundStyle(.secondary)
                Text(item.message)
                  .font(.caption)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
          }
          .transition(.opacity.combined(with: .move(edge: .top)))
        }

        actions
      }
    }
  }
}

extension ChatSystemEventGroup where Actions == EmptyView {
  /// アプリ固有操作を持たないシステムイベントグループを作成する。
  public init(
    items: [ChatSystemEventItem],
    strings: ChatSystemEventGroupStrings = .localized,
    theme: ChatRoomTheme = .fanely,
    @ViewBuilder summary: () -> Summary
  ) {
    self.init(
      items: items,
      strings: strings,
      theme: theme,
      summary: summary,
      actions: { EmptyView() }
    )
  }
}
