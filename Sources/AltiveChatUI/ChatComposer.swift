import Foundation
import SwiftUI

/// 入力中テキストを送信可能な形式へ整える処理。
enum ChatDraft {
  /// 前後の空白と改行を除き、空文字の場合は `nil` を返す。
  static func normalizedText(from draft: String) -> String? {
    let value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    return value.isEmpty ? nil : value
  }
}

/// ファネリーの Family Room を基準にしたチャット入力欄。
///
/// 入力値の永続化や送信状態はアプリ側が所有します。`onSend` には前後の空白と
/// 改行を除いた文字列だけを渡し、送信後に入力値を消すタイミングは呼び出し側が
/// 決定します。
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
  private let maximumLength: Int?
  private let characterCountWarningThreshold: Int?
  private let lineLimit: ClosedRange<Int>
  private let theme: ChatRoomTheme
  private let accessibilityIdentifier: String
  private let onToggleInputSurface: () -> Void
  private let onSend: (String) -> Void
  private let attachmentPreview: AttachmentPreview
  private let inputSurface: InputSurface

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
    lineLimit: ClosedRange<Int> = 1...5,
    theme: ChatRoomTheme = .fanely,
    accessibilityIdentifier: String = "AltiveChatUI.Composer",
    onToggleInputSurface: @escaping () -> Void,
    onSend: @escaping (String) -> Void,
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
    self.maximumLength = maximumLength
    self.characterCountWarningThreshold = characterCountWarningThreshold
    self.lineLimit = lineLimit
    self.theme = theme
    self.accessibilityIdentifier = accessibilityIdentifier
    self.onToggleInputSurface = onToggleInputSurface
    self.onSend = onSend
    self.attachmentPreview = attachmentPreview()
    self.inputSurface = inputSurface()
  }

  public var body: some View {
    VStack(alignment: .trailing, spacing: 6) {
      attachmentPreview

      HStack(alignment: .bottom, spacing: 8) {
        HStack(spacing: 4) {
          TextField(placeholder, text: $draft, axis: .vertical)
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
        .background(theme.composerField, in: Capsule(style: .continuous))
        .overlay {
          Capsule(style: .continuous)
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

      if shouldShowCharacterCount, let maximumLength {
        Text(verbatim: "\(draft.count)/\(maximumLength)")
          .font(.caption2.monospacedDigit())
          .foregroundStyle(draft.count > maximumLength ? .red : .secondary)
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
  }

  private var canSend: Bool {
    guard !isSending, ChatDraft.normalizedText(from: draft) != nil else { return false }
    guard let maximumLength else { return true }
    return draft.count <= maximumLength
  }

  private var shouldShowCharacterCount: Bool {
    guard let threshold = characterCountWarningThreshold else { return false }
    return draft.count >= threshold
  }

  private func sendDraft() {
    guard canSend, let text = ChatDraft.normalizedText(from: draft) else { return }
    onSend(text)
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
