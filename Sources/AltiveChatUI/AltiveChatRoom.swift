import AltiveChatCore
import SwiftUI

/// メッセージ一覧と入力欄を表示するチャット画面。
@MainActor
public struct AltiveChatRoom: View {
  private static let bottomAnchorID = "AltiveChatUI.BottomAnchor"

  private let messages: [ChatMessage]
  private let currentUserID: String
  private let theme: ChatRoomTheme
  private let strings: ChatRoomStrings
  private let showsSenderName: Bool
  private let onSend: (String) -> Void
  private let onRetry: ((String) -> Void)?
  private let draftPolicy: ChatDraftPolicy

  @Binding private var draft: String
  @FocusState private var isComposerFocused: Bool

  /// チャット画面を作成する。
  ///
  /// `messages` は作成日時の昇順で渡す。送信や永続化は `onSend` を受け取る
  /// アプリ側が担当する。
  public init(
    messages: [ChatMessage],
    currentUserID: String,
    draft: Binding<String>,
    theme: ChatRoomTheme = .standard,
    strings: ChatRoomStrings = .localized,
    showsSenderName: Bool = false,
    draftPolicy: ChatDraftPolicy = .unrestricted,
    onRetry: ((String) -> Void)? = nil,
    onSend: @escaping (String) -> Void
  ) {
    self.messages = messages
    self.currentUserID = currentUserID
    _draft = draft
    self.theme = theme
    self.strings = strings
    self.showsSenderName = showsSenderName
    self.draftPolicy = draftPolicy
    self.onRetry = onRetry
    self.onSend = onSend
  }

  public var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 12) {
          if messages.isEmpty {
            Text(strings.emptyMessage)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 48)
          } else {
            ForEach(messages) { message in
              ChatMessageRow(
                message: message,
                currentUserID: currentUserID,
                theme: theme,
                strings: strings,
                showsSenderName: showsSenderName,
                onRetry: onRetry.map { retry in
                  { retry(message.id) }
                }
              )
              .id(message.id)
            }
          }

          Color.clear
            .frame(height: 1)
            .id(Self.bottomAnchorID)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
      }
      .background(theme.background)
      .scrollDismissesKeyboard(.interactively)
      .safeAreaInset(edge: .bottom) {
        composer
      }
      .onAppear {
        proxy.scrollTo(Self.bottomAnchorID, anchor: .bottom)
      }
      .onChange(of: messages.last?.id) { previousID, currentID in
        guard previousID != currentID else { return }
        withAnimation(.easeOut(duration: 0.2)) {
          proxy.scrollTo(Self.bottomAnchorID, anchor: .bottom)
        }
      }
    }
  }

  private var composer: some View {
    ChatComposer(
      draft: $draft,
      focus: $isComposerFocused,
      isInputSurfacePresented: false,
      inputSurfaceHeight: 0,
      isSending: false,
      placeholder: strings.messagePlaceholder,
      sendButtonLabel: strings.sendButtonLabel,
      showsInputSurfaceButton: false,
      maximumLength: nil,
      characterCountWarningThreshold: nil,
      draftPolicy: draftPolicy,
      theme: theme,
      onToggleInputSurface: {},
      onSend: { text in
        onSend(text)
        draft = ""
      },
      attachmentPreview: { EmptyView() },
      inputSurface: { EmptyView() }
    )
  }
}
