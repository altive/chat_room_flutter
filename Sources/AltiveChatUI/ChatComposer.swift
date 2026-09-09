import Foundation
import SwiftUI

let chatComposerCornerRadius: CGFloat = 22

/// 共通UI契約に従うチャット入力欄。
///
/// 入力値の永続化や送信状態はアプリ側が所有します。`onSend` には前後の空白と
/// 改行を除いた文字列だけを渡し、コールバックの直後に入力値を空にします。
@MainActor
public struct ChatComposer<AttachmentPreview: View, InputSurface: View>: View {
  @Binding private var draft: String

  private let focus: FocusState<Bool>.Binding
  private let isInputSurfacePresented: Bool
  private let inputSurfaceHeight: CGFloat
  private let isSending: Bool
  private let placeholder: String
  private let sendButtonLabel: String
  private let inputSurfaceButtonLabel: String
  private let inputSurfaceButtonHint: String?
  private let showsInputSurfaceButton: Bool
  private let draftPolicy: ChatDraftPolicy
  private let lineLimit: ClosedRange<Int>
  private let theme: ChatRoomTheme
  private let accessibilityIdentifier: String
  private let onToggleInputSurface: () -> Void
  private let onSend: ((String) -> Void)?
  private let onSubmit: ((ChatComposerSubmission) -> Void)?
  private let linkPreviewImageLoader: ChatLinkPreviewImageLoader?
  private let linkPreviewAccessibilityLabel: String
  private let linkPreviewLoadingLabel: String
  private let onLinkPreviewTap: ((URL) -> Void)?
  private let attachmentPreview: AttachmentPreview
  private let inputSurface: InputSurface

  @State private var linkPreviewCoordinator: ChatLinkPreviewDraftCoordinator

  /// チャット入力欄を作成する。
  public init(
    draft: Binding<String>,
    focus: FocusState<Bool>.Binding,
    isInputSurfacePresented: Bool,
    inputSurfaceHeight: CGFloat,
    isSending: Bool,
    placeholder: String,
    sendButtonLabel: String,
    inputSurfaceButtonLabel: String = "",
    inputSurfaceButtonHint: String? = nil,
    showsInputSurfaceButton: Bool = true,
    maximumLength: Int? = 500,
    characterCountWarningThreshold: Int? = 450,
    draftPolicy: ChatDraftPolicy? = nil,
    lineLimit: ClosedRange<Int> = 1...5,
    theme: ChatRoomTheme = .fanely,
    accessibilityIdentifier: String = "AltiveChatUI.Composer",
    linkPreviewResolver: ChatLinkPreviewResolver? = nil,
    linkPreviewImageLoader: ChatLinkPreviewImageLoader? = nil,
    linkPreviewAccessibilityLabel: String = "Link preview",
    linkPreviewLoadingLabel: String = "Loading link preview",
    onLinkPreviewTap: ((URL) -> Void)? = nil,
    onToggleInputSurface: @escaping () -> Void,
    onSend: ((String) -> Void)? = nil,
    onSubmit: ((ChatComposerSubmission) -> Void)? = nil,
    @ViewBuilder attachmentPreview: () -> AttachmentPreview,
    @ViewBuilder inputSurface: () -> InputSurface
  ) {
    _draft = draft
    self.focus = focus
    self.isInputSurfacePresented = isInputSurfacePresented
    self.inputSurfaceHeight = inputSurfaceHeight
    self.isSending = isSending
    self.placeholder = placeholder
    self.sendButtonLabel = sendButtonLabel
    self.inputSurfaceButtonLabel = inputSurfaceButtonLabel
    self.inputSurfaceButtonHint = inputSurfaceButtonHint
    self.showsInputSurfaceButton = showsInputSurfaceButton
    self.draftPolicy =
      draftPolicy
      ?? ChatDraftPolicy(
        maximumLength: maximumLength,
        warningThreshold: characterCountWarningThreshold
      )
    self.lineLimit = lineLimit
    self.theme = theme
    self.accessibilityIdentifier = accessibilityIdentifier
    self.onToggleInputSurface = onToggleInputSurface
    self.onSend = onSend
    self.onSubmit = onSubmit
    self.linkPreviewImageLoader = linkPreviewImageLoader
    self.linkPreviewAccessibilityLabel = linkPreviewAccessibilityLabel
    self.linkPreviewLoadingLabel = linkPreviewLoadingLabel
    self.onLinkPreviewTap = onLinkPreviewTap
    self.attachmentPreview = attachmentPreview()
    self.inputSurface = inputSurface()
    _linkPreviewCoordinator = State(
      initialValue: ChatLinkPreviewDraftCoordinator(resolver: linkPreviewResolver)
    )
  }

  public var body: some View {
    VStack(alignment: .trailing, spacing: 6) {
      attachmentPreview

      ChatLinkPreviewDraftContent(
        state: linkPreviewCoordinator.state,
        imageLoader: linkPreviewImageLoader,
        accessibilityLabel: linkPreviewAccessibilityLabel,
        loadingLabel: linkPreviewLoadingLabel,
        onTap: onLinkPreviewTap
      )

      HStack(alignment: .bottom, spacing: 8) {
        HStack(spacing: 4) {
          TextField(placeholder, text: limitedDraft, axis: .vertical)
            .lineLimit(lineLimit)
            .focused(focus)
            .textFieldStyle(.plain)
            .padding(.leading, 16)
            .padding(.vertical, 11)
            .accessibilityIdentifier(accessibilityIdentifier)

          if showsInputSurfaceButton {
            Button(action: onToggleInputSurface) {
              ZStack {
                Image(systemName: "face.smiling.inverse")
                  .opacity(isInputSurfacePresented ? 0 : 1)
                  .scaleEffect(isInputSurfacePresented ? 0.82 : 1)
                Image(systemName: "keyboard")
                  .opacity(isInputSurfacePresented ? 1 : 0)
                  .scaleEffect(isInputSurfacePresented ? 1 : 0.82)
              }
              .font(.system(size: 19, weight: .semibold))
              .frame(width: 38, height: 38)
              .animation(.easeInOut(duration: 0.16), value: isInputSurfacePresented)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(inputSurfaceButtonLabel)
            .accessibilityHint(inputSurfaceButtonHint ?? "")
          }
        }
        .background(
          theme.composerField,
          in: RoundedRectangle(
            cornerRadius: chatComposerCornerRadius,
            style: .continuous
          )
        )
        .overlay {
          RoundedRectangle(
            cornerRadius: chatComposerCornerRadius,
            style: .continuous
          )
          .stroke(theme.composerFieldBorder, lineWidth: 0.5)
        }

        Button(action: sendDraft) {
          if isSending {
            ProgressView()
              .tint(theme.sendButtonForeground)
          } else {
            Image(systemName: "arrow.up")
              .font(.system(size: 17, weight: .bold))
          }
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.sendButtonForeground)
        .frame(width: 42, height: 42)
        .background(theme.sendButtonBackground, in: Circle())
        .contentShape(Circle())
        .disabled(!canSend)
        .opacity(canSend ? 1 : 0.38)
        .accessibilityLabel(sendButtonLabel)
        .accessibilityIdentifier("AltiveChatUI.SendButton")
      }

      if draftPolicy.shouldShowLength(for: draft), let maximumLength = draftPolicy.maximumLength {
        Text(verbatim: "\(draftPolicy.length(of: draft))/\(maximumLength)")
          .font(.caption2.monospacedDigit())
          .foregroundStyle(
            draftPolicy.length(of: draft) > maximumLength ? theme.deliveryFailure : .secondary
          )
          .padding(.trailing, 50)
      }

      ZStack(alignment: .top) {
        inputSurface
      }
      .frame(height: isInputSurfacePresented ? inputSurfaceHeight : 0)
      .padding(.horizontal, -16)
      .clipped()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(.ultraThinMaterial)
    .overlay(alignment: .top) {
      Divider().opacity(0.35)
    }
    .onChange(of: draft, initial: true) { _, currentDraft in
      linkPreviewCoordinator.update(draft: currentDraft)
    }
  }

  private var canSend: Bool {
    !isSending && draftPolicy.normalizedText(from: draft) != nil
  }

  private var limitedDraft: Binding<String> {
    Binding(
      get: { draft },
      set: { draft = draftPolicy.limited($0) }
    )
  }

  private func sendDraft() {
    guard canSend, let text = draftPolicy.normalizedText(from: draft) else { return }
    if let onSubmit,
      let submission = ChatComposerSubmission(
        text: text,
        images: [],
        linkPreview: linkPreviewCoordinator.previewForSubmission(text: text)
      )
    {
      onSubmit(submission)
    } else {
      guard let onSend else { return }
      onSend(text)
    }
    draft = ""
  }
}

/// チャット入力欄の上へ表示する添付コンテンツの送信プレビュー。
@MainActor
public struct ChatComposerAttachmentPreview<Content: View>: View {
  private let isSending: Bool
  private let sendButtonLabel: String
  private let removeButtonLabel: String
  private let onSend: () -> Void
  private let onRemove: () -> Void
  private let content: Content

  /// 添付コンテンツの送信プレビューを作成する。
  public init(
    isSending: Bool,
    sendButtonLabel: String,
    removeButtonLabel: String,
    onSend: @escaping () -> Void,
    onRemove: @escaping () -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self.isSending = isSending
    self.sendButtonLabel = sendButtonLabel
    self.removeButtonLabel = removeButtonLabel
    self.onSend = onSend
    self.onRemove = onRemove
    self.content = content()
  }

  public var body: some View {
    HStack {
      Spacer()
      ZStack(alignment: .topTrailing) {
        Button(action: onSend) {
          content
            .frame(width: 120, height: 120)
            .clipped()
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(isSending)
        .accessibilityLabel(sendButtonLabel)

        Button(action: onRemove) {
          Image(systemName: "xmark.circle.fill")
            .font(.title2)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, Color.black.opacity(0.55))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(removeButtonLabel)
      }
      .frame(width: 120, height: 120)
      Spacer()
    }
  }
}
