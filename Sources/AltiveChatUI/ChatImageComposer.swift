import AltiveChatCore
import PhotosUI
import SwiftUI

func showsChatComposerSourceButtons(isFocused: Bool) -> Bool {
  !isFocused
}

/// テキストまたは画像を送信できるかを判定する純粋な方針。
public enum ChatComposerSendPolicy {
  /// 入力の準備中・送信中ではなく、テキストか画像が存在する場合に `true`。
  public static func canSend(
    draft: String,
    imageCount: Int,
    maximumImageCount: Int? = nil,
    isPreparingImages: Bool,
    isSending: Bool,
    draftPolicy: ChatDraftPolicy
  ) -> Bool {
    let isWithinImageLimit = maximumImageCount.map { imageCount <= $0 } ?? true
    return !isPreparingImages && !isSending && isWithinImageLimit
      && (draftPolicy.normalizedText(from: draft) != nil || imageCount > 0)
  }
}

@MainActor
public struct ChatImageComposer: View {
  @Binding var draft: String
  @Binding var imageDrafts: [ChatImageDraft]
  @Binding var selectedPhotoItems: [PhotosPickerItem]
  let focus: FocusState<Bool>.Binding
  let configuration: ChatImageInputConfiguration
  let availableImageInputSources: Set<ChatImageInputSource>
  let maximumPhotoSelectionCount: Int
  let isPhotoLibrarySelectionEnabled: Bool
  let isPreparingImages: Bool
  let isPreparingCameraImage: Bool
  let isSending: Bool
  let strings: ChatRoomStrings
  let draftPolicy: ChatDraftPolicy
  let theme: ChatRoomTheme
  let imageLoader: ChatImageLoader
  let onRequestCamera: (() -> Void)?
  let onRemoveImage: (String) -> Void
  let onSubmit: () -> Void
  private let additionalSourceButton: AnyView?

  /// 画像入力に対応したチャット入力欄を作成する。
  public init(
    draft: Binding<String>,
    imageDrafts: Binding<[ChatImageDraft]>,
    selectedPhotoItems: Binding<[PhotosPickerItem]>,
    focus: FocusState<Bool>.Binding,
    configuration: ChatImageInputConfiguration,
    availableImageInputSources: Set<ChatImageInputSource>,
    maximumPhotoSelectionCount: Int,
    isPhotoLibrarySelectionEnabled: Bool,
    isPreparingImages: Bool,
    isPreparingCameraImage: Bool,
    isSending: Bool,
    strings: ChatRoomStrings = .localized,
    draftPolicy: ChatDraftPolicy = .unrestricted,
    theme: ChatRoomTheme = .fanely,
    imageLoader: ChatImageLoader = .standard,
    onRequestCamera: (() -> Void)?,
    onRemoveImage: @escaping (String) -> Void,
    onSubmit: @escaping () -> Void,
    additionalSourceButton: AnyView? = nil
  ) {
    _draft = draft
    _imageDrafts = imageDrafts
    _selectedPhotoItems = selectedPhotoItems
    self.focus = focus
    self.configuration = configuration
    self.availableImageInputSources = availableImageInputSources
    self.maximumPhotoSelectionCount = maximumPhotoSelectionCount
    self.isPhotoLibrarySelectionEnabled = isPhotoLibrarySelectionEnabled
    self.isPreparingImages = isPreparingImages
    self.isPreparingCameraImage = isPreparingCameraImage
    self.isSending = isSending
    self.strings = strings
    self.draftPolicy = draftPolicy
    self.theme = theme
    self.imageLoader = imageLoader
    self.onRequestCamera = onRequestCamera
    self.onRemoveImage = onRemoveImage
    self.onSubmit = onSubmit
    self.additionalSourceButton = additionalSourceButton
  }

  public var body: some View {
    VStack(alignment: .trailing, spacing: 7) {
      previewStrip

      HStack(alignment: .bottom, spacing: 7) {
        if hasSourceButtons {
          if showsSourceButtons {
            sourceButtons
          } else {
            Button {
              focus.wrappedValue = false
            } label: {
              Image(systemName: "chevron.forward")
                .font(.system(size: 19, weight: .medium))
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel(strings.expandSourceButtonsLabel)
            .accessibilityIdentifier("AltiveChatUI.ExpandSourceButtons")
          }
        }

        TextField(strings.messagePlaceholder, text: limitedDraft, axis: .vertical)
          .lineLimit(1...5)
          .focused(focus)
          .textFieldStyle(.plain)
          .padding(.horizontal, 14)
          .padding(.vertical, 11)
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
          .accessibilityIdentifier("AltiveChatUI.Composer")

        Button(action: onSubmit) {
          if isPreparingImages || isSending {
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
        .accessibilityLabel(strings.sendButtonLabel)
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
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(.ultraThinMaterial)
    .overlay(alignment: .top) {
      Divider().opacity(0.35)
    }
  }

  @ViewBuilder
  private var sourceButtons: some View {
    HStack(spacing: 1) {
      additionalSourceButton
      if availableImageInputSources.contains(.camera) {
        Button {
          focus.wrappedValue = false
          onRequestCamera?()
        } label: {
          if isPreparingCameraImage {
            ProgressView()
              .controlSize(.small)
          } else {
            Image(systemName: "camera")
          }
        }
        .frame(width: 44, height: 44)
        .buttonStyle(.plain)
        .disabled(
          imageDrafts.count >= configuration.maximumSelectionCount || isPreparingCameraImage
        )
        .accessibilityLabel(strings.cameraButtonLabel)
      }

      if availableImageInputSources.contains(.photoLibrary) {
        PhotosPicker(
          selection: $selectedPhotoItems,
          maxSelectionCount: maximumPhotoSelectionCount,
          selectionBehavior: .ordered,
          matching: .images
        ) {
          Image(systemName: "photo.on.rectangle")
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .disabled(!isPhotoLibrarySelectionEnabled)
        .accessibilityLabel(strings.photoLibraryButtonLabel)
        .simultaneousGesture(
          TapGesture().onEnded {
            focus.wrappedValue = false
          }
        )
      }
    }
    .font(.system(size: 19, weight: .medium))
    .foregroundStyle(.secondary)
  }

  @ViewBuilder
  private var previewStrip: some View {
    if !imageDrafts.isEmpty || isPreparingImages {
      ScrollView(.horizontal) {
        HStack(spacing: 10) {
          ForEach(imageDrafts) { imageDraft in
            ZStack(alignment: .topTrailing) {
              ChatImageTile(
                image: imageDraft.previewImage,
                imageLoader: imageLoader,
                fallbackLabel: imageDraft.accessibilityLabel ?? strings.imageLabel,
                loadingFailureLabel: strings.imageLoadingFailedLabel,
                overflowCount: 0,
                onTap: nil
              )
              .frame(width: 76, height: 76)
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

              Button {
                onRemoveImage(imageDraft.id)
              } label: {
                Image(systemName: "xmark.circle.fill")
                  .font(.title3)
                  .symbolRenderingMode(.palette)
                  .foregroundStyle(.white, Color.black.opacity(0.58))
              }
              .buttonStyle(.plain)
              .offset(x: 6, y: -6)
              .accessibilityLabel(strings.removeImageButtonLabel)
            }
            .padding(.top, 6)
          }

          if isPreparingImages {
            ProgressView()
              .frame(width: 76, height: 76)
              .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
          }
        }
        .padding(.horizontal, 6)
      }
      .scrollIndicators(.hidden)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var canSend: Bool {
    ChatComposerSendPolicy.canSend(
      draft: draft,
      imageCount: imageDrafts.count,
      maximumImageCount: configuration.maximumSelectionCount,
      isPreparingImages: isPreparingImages,
      isSending: isSending,
      draftPolicy: draftPolicy
    )
  }

  private var hasSourceButtons: Bool {
    additionalSourceButton != nil || !availableImageInputSources.isEmpty
  }

  private var showsSourceButtons: Bool {
    showsChatComposerSourceButtons(isFocused: focus.wrappedValue)
  }

  private var limitedDraft: Binding<String> {
    Binding(
      get: { draft },
      set: { draft = draftPolicy.limited($0) }
    )
  }
}
