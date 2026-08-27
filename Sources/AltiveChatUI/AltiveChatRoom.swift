import AltiveChatCore
import PhotosUI
import SwiftUI

/// メッセージ一覧と入力欄を表示するチャット画面。
@MainActor
public struct AltiveChatRoom: View {
  private let messages: [ChatMessage]
  private let currentUserID: String
  private let theme: ChatRoomTheme
  private let strings: ChatRoomStrings
  private let showsSenderName: Bool
  private let draftPolicy: ChatDraftPolicy
  private let imageInputConfiguration: ChatImageInputConfiguration?
  private let availableImageInputSources: Set<ChatImageInputSource>
  private let isPreparingCameraImage: Bool
  private let isSending: Bool
  private let imageLoader: ChatImageLoader
  private let stickerImageLoader: ChatStickerImageLoader?
  private let singleImageLayout: ChatSingleImageLayout
  private let multipleImageLayout: ChatMultipleImageLayout
  private let latestProximityThreshold: CGFloat
  private let onRequestCamera: (() -> Void)?
  private let resolvePhotoLibraryItem:
    (@Sendable (PhotosPickerItem) async throws -> ChatImageDraft)?
  private let onImagePreparationFailure: ((Error) -> Void)?
  private let onImageTap: ((String, Int) -> Void)?
  private let onSubmit: ((ChatComposerSubmission) -> Void)?
  private let onTextSend: ((String) -> Void)?
  private let onRetry: ((String) -> Void)?

  @Binding private var draft: String
  @Binding private var imageDrafts: [ChatImageDraft]
  @FocusState private var isComposerFocused: Bool
  @State private var selectedPhotoItems: [PhotosPickerItem] = []
  @State private var photoDraftIDs: [PhotosPickerItem: String] = [:]
  @State private var isPreparingPhotoLibraryItem = false
  @State private var hasPresentedMessages = false

  /// テキスト送信だけを利用するチャット画面を作成する。
  ///
  /// `messages` は作成日時の昇順で渡す。送信や永続化は `onSend` を受け取る
  /// アプリ側が担当する。このinitializerでは画像入力ボタンを表示しない。
  public init(
    messages: [ChatMessage],
    currentUserID: String,
    draft: Binding<String>,
    theme: ChatRoomTheme = .standard,
    strings: ChatRoomStrings = .localized,
    showsSenderName: Bool = false,
    draftPolicy: ChatDraftPolicy = .unrestricted,
    imageLoader: ChatImageLoader = .standard,
    stickerImageLoader: ChatStickerImageLoader? = nil,
    singleImageLayout: ChatSingleImageLayout = .adaptiveBounded(),
    multipleImageLayout: ChatMultipleImageLayout = .mosaic,
    latestProximityThreshold: CGFloat = 80,
    onImageTap: ((String, Int) -> Void)? = nil,
    onRetry: ((String) -> Void)? = nil,
    onSend: @escaping (String) -> Void
  ) {
    self.messages = messages
    self.currentUserID = currentUserID
    _draft = draft
    _imageDrafts = .constant([])
    self.theme = theme
    self.strings = strings
    self.showsSenderName = showsSenderName
    self.draftPolicy = draftPolicy
    imageInputConfiguration = nil
    availableImageInputSources = []
    isPreparingCameraImage = false
    isSending = false
    self.imageLoader = imageLoader
    self.stickerImageLoader = stickerImageLoader
    self.singleImageLayout = singleImageLayout
    self.multipleImageLayout = multipleImageLayout
    self.latestProximityThreshold = max(0, latestProximityThreshold)
    onRequestCamera = nil
    resolvePhotoLibraryItem = nil
    onImagePreparationFailure = nil
    self.onImageTap = onImageTap
    onSubmit = nil
    onTextSend = onSend
    self.onRetry = onRetry
  }

  /// テキストと複数画像を送信できるチャット画面を作成する。
  ///
  /// カメラ画面、画像の正規化・圧縮、一時ファイル作成、アップロードと永続化は
  /// アプリ側が担当する。`onSubmit` はテキストと画像を1回の要求として返す。
  public init(
    messages: [ChatMessage],
    currentUserID: String,
    draft: Binding<String>,
    imageDrafts: Binding<[ChatImageDraft]>,
    imageInputConfiguration: ChatImageInputConfiguration = .init(),
    availableImageInputSources: Set<ChatImageInputSource> = [.camera, .photoLibrary],
    isPreparingCameraImage: Bool = false,
    isSending: Bool = false,
    theme: ChatRoomTheme = .standard,
    strings: ChatRoomStrings = .localized,
    showsSenderName: Bool = false,
    draftPolicy: ChatDraftPolicy = .unrestricted,
    imageLoader: ChatImageLoader = .standard,
    stickerImageLoader: ChatStickerImageLoader? = nil,
    singleImageLayout: ChatSingleImageLayout = .adaptiveBounded(),
    multipleImageLayout: ChatMultipleImageLayout = .mosaic,
    latestProximityThreshold: CGFloat = 80,
    onRequestCamera: (() -> Void)? = nil,
    resolvePhotoLibraryItem:
      (@Sendable (PhotosPickerItem) async throws -> ChatImageDraft)? = nil,
    onImagePreparationFailure: ((Error) -> Void)? = nil,
    onImageTap: ((String, Int) -> Void)? = nil,
    onRetry: ((String) -> Void)? = nil,
    onSubmit: @escaping (ChatComposerSubmission) -> Void
  ) {
    self.messages = messages
    self.currentUserID = currentUserID
    _draft = draft
    _imageDrafts = imageDrafts
    self.theme = theme
    self.strings = strings
    self.showsSenderName = showsSenderName
    self.draftPolicy = draftPolicy
    self.imageInputConfiguration = imageInputConfiguration
    self.availableImageInputSources = availableImageInputSources
    self.isPreparingCameraImage = isPreparingCameraImage
    self.isSending = isSending
    self.imageLoader = imageLoader
    self.stickerImageLoader = stickerImageLoader
    self.singleImageLayout = singleImageLayout
    self.multipleImageLayout = multipleImageLayout
    self.latestProximityThreshold = max(0, latestProximityThreshold)
    self.onRequestCamera = onRequestCamera
    self.resolvePhotoLibraryItem = resolvePhotoLibraryItem
    self.onImagePreparationFailure = onImagePreparationFailure
    self.onImageTap = onImageTap
    self.onSubmit = onSubmit
    onTextSend = nil
    self.onRetry = onRetry
  }

  public var body: some View {
    roomContent
  }

  private var roomContent: some View {
    ChatRoomLayout {
      ChatTimeline(
        timelineID: "AltiveChatRoom",
        isReadyForInitialPositioning: true,
        initialPosition: ChatTimelineInitialPosition<String>.latest,
        followLatestTrigger: messages.last?.id,
        followLatestAnimation: hasPresentedMessages ? .easeOut(duration: 0.2) : nil,
        latestFollowingPolicy: .whenNearBottom,
        latestProximityThreshold: latestProximityThreshold,
        forceFollowLatest: messages.last?.isSent(by: currentUserID) == true,
        latestControl: .button(label: strings.latestMessagesLabel),
        spacing: 12,
        contentInsets: EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16)
      ) { _ in
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
              imageLoader: imageLoader,
              stickerImageLoader: stickerImageLoader,
              singleImageLayout: singleImageLayout,
              multipleImageLayout: multipleImageLayout,
              onImageTap: onImageTap,
              onRetry: onRetry.map { retry in
                { retry(message.id) }
              }
            )
            .id(message.id)
          }
        }
      }
      .background(theme.background)
      .onAppear {
        hasPresentedMessages = !messages.isEmpty
      }
      .onChange(of: messages.last?.id) { _, currentID in
        hasPresentedMessages = currentID != nil
      }
    } composer: {
      composer
    }
    .task(id: selectedPhotoItems) {
      await synchronizePhotoLibrarySelection()
    }
  }

  @ViewBuilder
  private var composer: some View {
    if let configuration = imageInputConfiguration {
      ChatImageComposer(
        draft: $draft,
        imageDrafts: $imageDrafts,
        selectedPhotoItems: $selectedPhotoItems,
        focus: $isComposerFocused,
        configuration: configuration,
        availableImageInputSources: effectiveImageInputSources,
        maximumPhotoSelectionCount: maximumPhotoSelectionCount,
        isPhotoLibrarySelectionEnabled: isPhotoLibrarySelectionEnabled,
        isPreparingImages: isPreparingPhotoLibraryItem || isPreparingCameraImage,
        isPreparingCameraImage: isPreparingCameraImage,
        isSending: isSending,
        strings: strings,
        draftPolicy: draftPolicy,
        theme: theme,
        imageLoader: imageLoader,
        onRequestCamera: onRequestCamera,
        onRemoveImage: removeImageDraft,
        onSubmit: submitImagesAndText
      )
    } else {
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
          onTextSend?(text)
          draft = ""
        },
        attachmentPreview: { EmptyView() },
        inputSurface: { EmptyView() }
      )
    }
  }

  private var effectiveImageInputSources: Set<ChatImageInputSource> {
    availableImageInputSources.filter { source in
      switch source {
      case .camera:
        onRequestCamera != nil
      case .photoLibrary:
        resolvePhotoLibraryItem != nil
      }
    }
  }

  private var mappedPhotoDraftIDs: Set<String> {
    Set(photoDraftIDs.values)
  }

  private var cameraDraftCount: Int {
    imageDrafts.lazy.filter { !mappedPhotoDraftIDs.contains($0.id) }.count
  }

  private var maximumPhotoSelectionCount: Int {
    guard let configuration = imageInputConfiguration else { return 1 }
    let availableCount = max(0, configuration.maximumSelectionCount - cameraDraftCount)
    return max(1, selectedPhotoItems.count, availableCount)
  }

  private var isPhotoLibrarySelectionEnabled: Bool {
    guard let configuration = imageInputConfiguration else { return false }
    return !selectedPhotoItems.isEmpty
      || cameraDraftCount < configuration.maximumSelectionCount
  }

  private func synchronizePhotoLibrarySelection() async {
    guard let configuration = imageInputConfiguration,
      let resolvePhotoLibraryItem
    else { return }

    let selectedSet = Set(selectedPhotoItems)
    let removedItems = photoDraftIDs.keys.filter { !selectedSet.contains($0) }
    let removedDraftIDs = Set(removedItems.compactMap { photoDraftIDs[$0] })
    if !removedDraftIDs.isEmpty {
      imageDrafts.removeAll { removedDraftIDs.contains($0.id) }
      for item in removedItems {
        photoDraftIDs.removeValue(forKey: item)
      }
    }

    let unresolvedItems = selectedPhotoItems.filter { photoDraftIDs[$0] == nil }
    guard !unresolvedItems.isEmpty else {
      reorderPhotoDrafts()
      return
    }

    isPreparingPhotoLibraryItem = true
    defer { isPreparingPhotoLibraryItem = false }

    for item in unresolvedItems {
      guard !Task.isCancelled else { return }
      guard imageDrafts.count < configuration.maximumSelectionCount else { break }

      do {
        let imageDraft = try await resolvePhotoLibraryItem(item)
        try Task.checkCancellation()
        guard selectedPhotoItems.contains(item) else { continue }
        guard imageDrafts.count < configuration.maximumSelectionCount else { break }

        photoDraftIDs[item] = imageDraft.id
        if !imageDrafts.contains(where: { $0.id == imageDraft.id }) {
          imageDrafts.append(imageDraft)
        }
      } catch is CancellationError {
        return
      } catch {
        selectedPhotoItems.removeAll { $0 == item }
        onImagePreparationFailure?(error)
      }
    }

    reorderPhotoDrafts()
  }

  private func reorderPhotoDrafts() {
    let photoIDs = mappedPhotoDraftIDs
    let cameraDrafts = imageDrafts.filter { !photoIDs.contains($0.id) }
    var draftsByID: [String: ChatImageDraft] = [:]
    for imageDraft in imageDrafts {
      draftsByID[imageDraft.id] = imageDraft
    }
    let orderedPhotoDrafts = selectedPhotoItems.compactMap { item in
      photoDraftIDs[item].flatMap { draftsByID[$0] }
    }
    imageDrafts = cameraDrafts + orderedPhotoDrafts
  }

  private func removeImageDraft(id: String) {
    imageDrafts.removeAll { $0.id == id }
    let photoItems = photoDraftIDs.compactMap { item, draftID in
      draftID == id ? item : nil
    }
    for item in photoItems {
      photoDraftIDs.removeValue(forKey: item)
      selectedPhotoItems.removeAll { $0 == item }
    }
  }

  private func submitImagesAndText() {
    guard
      let submission = ChatComposerSubmission(
        draft: draft,
        images: imageDrafts,
        policy: draftPolicy
      )
    else { return }

    onSubmit?(submission)
    draft = ""
    imageDrafts.removeAll()
    selectedPhotoItems.removeAll()
    photoDraftIDs.removeAll()
  }
}
