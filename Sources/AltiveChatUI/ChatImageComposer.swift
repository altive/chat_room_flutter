import PhotosUI
import SwiftUI

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
struct ChatImageComposer: View {
  @Binding var draft: String
  @Binding var imageDrafts: [ChatImageDraft]
  @Binding var selectedPhotoItems: [PhotosPickerItem]
  @Binding var isInlinePhotoLibraryPresented: Bool
  @Binding var isInlinePhotoLibraryExpanded: Bool

  let focus: FocusState<Bool>.Binding
  let configuration: ChatImageInputConfiguration
  let availableImageInputSources: Set<ChatImageInputSource>
  let maximumPhotoSelectionCount: Int
  let isPhotoLibrarySelectionEnabled: Bool
  let inputSurfaceHeight: CGFloat
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

  var body: some View {
    VStack(alignment: .trailing, spacing: 7) {
      previewStrip

      HStack(alignment: .bottom, spacing: 7) {
        sourceButtons

        TextField(strings.messagePlaceholder, text: limitedDraft, axis: .vertical)
          .lineLimit(1...5)
          .focused(focus)
          .textFieldStyle(.plain)
          .padding(.horizontal, 14)
          .padding(.vertical, 11)
          .background(theme.composerField, in: Capsule(style: .continuous))
          .overlay {
            Capsule(style: .continuous)
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

      inlinePhotoLibrary
        .frame(height: isInlinePhotoLibraryPresented ? inputSurfaceHeight : 0)
        .padding(.horizontal, -16)
        .clipped()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(.ultraThinMaterial)
    .overlay(alignment: .top) {
      Divider().opacity(0.35)
    }
    .animation(.easeInOut(duration: 0.22), value: inputSurfaceHeight)
    .animation(.easeInOut(duration: 0.18), value: isInlinePhotoLibraryPresented)
  }

  @ViewBuilder
  private var sourceButtons: some View {
    HStack(spacing: 1) {
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
        switch configuration.photoLibraryPresentationStyle {
        case .system:
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
        case .inline:
          Button {
            focus.wrappedValue = false
            isInlinePhotoLibraryPresented.toggle()
            if !isInlinePhotoLibraryPresented {
              isInlinePhotoLibraryExpanded = false
            }
          } label: {
            Image(systemName: isInlinePhotoLibraryPresented ? "keyboard" : "photo.on.rectangle")
              .frame(width: 44, height: 44)
          }
          .buttonStyle(.plain)
          .accessibilityLabel(strings.photoLibraryButtonLabel)
        }
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

  @ViewBuilder
  private var inlinePhotoLibrary: some View {
    if configuration.photoLibraryPresentationStyle == .inline,
      isInlinePhotoLibraryPresented
    {
      VStack(spacing: 0) {
        if configuration.allowsInlineExpansion {
          inlineExpansionHandle
        }

        PhotosPicker(
          selection: $selectedPhotoItems,
          maxSelectionCount: maximumPhotoSelectionCount,
          selectionBehavior: .continuousAndOrdered,
          matching: .images
        ) {
          Text(strings.photoLibraryButtonLabel)
        }
        .photosPickerStyle(.inline)
        .disabled(!isPhotoLibrarySelectionEnabled)
      }
    }
  }

  private var inlineExpansionHandle: some View {
    Capsule()
      .fill(.secondary.opacity(0.55))
      .frame(width: 38, height: 5)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 9)
      .contentShape(.rect)
      .onTapGesture {
        isInlinePhotoLibraryExpanded.toggle()
      }
      .accessibilityLabel(
        isInlinePhotoLibraryExpanded
          ? strings.collapsePhotoLibraryLabel : strings.expandPhotoLibraryLabel
      )
      .accessibilityAddTraits(.isButton)
      .accessibilityAction {
        isInlinePhotoLibraryExpanded.toggle()
      }
      .gesture(
        DragGesture(minimumDistance: 12)
          .onEnded { value in
            if value.translation.height < -36 {
              isInlinePhotoLibraryExpanded = true
            } else if value.translation.height > 36 {
              isInlinePhotoLibraryExpanded = false
            }
          }
      )
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

  private var limitedDraft: Binding<String> {
    Binding(
      get: { draft },
      set: { draft = draftPolicy.limited($0) }
    )
  }
}
