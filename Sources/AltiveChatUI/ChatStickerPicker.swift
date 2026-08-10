import SwiftUI

/// ステッカー一覧の取得状態。
public enum ChatStickerPickerLoadState: Hashable, Sendable {
  /// 取得開始前。
  case idle

  /// 取得中。
  case loading

  /// 一覧を表示できる状態。
  case loaded

  /// 機能を利用できない状態。
  case unavailable

  /// 再試行可能な取得失敗。
  case failed
}

/// ステッカーpickerへ表示する1件分。
public struct ChatStickerPickerItem<Reference, Asset>: Identifiable, Sendable
where Reference: Hashable & Sendable, Asset: Sendable {
  /// ステッカーID。
  public let id: String

  /// 選択時にアプリへ返す参照。
  public let reference: Reference

  /// 画像表示へ渡すasset。
  public let asset: Asset

  /// VoiceOverへ伝える名前。
  public let accessibilityLabel: String

  /// ステッカー表示値を作成する。
  public init(id: String, reference: Reference, asset: Asset, accessibilityLabel: String) {
    self.id = id
    self.reference = reference
    self.asset = asset
    self.accessibilityLabel = accessibilityLabel
  }
}

/// ステッカーpickerへ表示するパック。
public struct ChatStickerPickerPack<Reference, Asset>: Identifiable, Sendable
where Reference: Hashable & Sendable, Asset: Sendable {
  /// パックID。
  public let id: String

  /// パック表示名。
  public let displayName: String

  /// タブへ表示するasset。
  public let trayIcon: Asset

  /// パックに含まれるステッカー。
  public let stickers: [ChatStickerPickerItem<Reference, Asset>]

  /// ステッカーパック表示値を作成する。
  public init(
    id: String,
    displayName: String,
    trayIcon: Asset,
    stickers: [ChatStickerPickerItem<Reference, Asset>]
  ) {
    self.id = id
    self.displayName = displayName
    self.trayIcon = trayIcon
    self.stickers = stickers
  }
}

/// ステッカー画像の解決元。
public enum ChatStickerPickerImageSource<Reference, Asset>: Sendable
where Reference: Hashable & Sendable, Asset: Sendable {
  /// 現在のパックに含まれる検証済みasset。
  case asset(Asset)

  /// 最近利用した履歴などの固定参照。
  case reference(Reference)
}

/// ステッカーpickerの文言。
public struct ChatStickerPickerStrings: Hashable, Sendable {
  /// 履歴タブのVoiceOver名。
  public let historyLabel: String

  /// 履歴が空の場合の文言。
  public let historyEmptyTitle: String

  /// 利用できない場合の見出し。
  public let unavailableTitle: String

  /// 利用できない場合の説明。
  public let unavailableDescription: String?

  /// 読み込み失敗時の見出し。
  public let failedTitle: String

  /// 再試行ボタンの文言。
  public let retryLabel: String

  /// ステッカーpickerの文言を作成する。
  public init(
    historyLabel: String,
    historyEmptyTitle: String,
    unavailableTitle: String,
    unavailableDescription: String? = nil,
    failedTitle: String,
    retryLabel: String
  ) {
    self.historyLabel = historyLabel
    self.historyEmptyTitle = historyEmptyTitle
    self.unavailableTitle = unavailableTitle
    self.unavailableDescription = unavailableDescription
    self.failedTitle = failedTitle
    self.retryLabel = retryLabel
  }
}

/// 取得・保存・画像解決をアプリ側へ注入する共通ステッカーpicker。
@MainActor
public struct ChatStickerPicker<Reference, Asset, ImageContent>: View
where Reference: Hashable & Sendable, Asset: Sendable, ImageContent: View {
  private let isCatalogLoading: Bool
  private let isCatalogAvailable: Bool
  private let loadState: ChatStickerPickerLoadState
  private let packs: [ChatStickerPickerPack<Reference, Asset>]
  private let selectedPackID: String
  private let isHistorySelected: Bool
  private let recentReferences: [Reference]
  private let strings: ChatStickerPickerStrings
  private let referenceAccessibilityLabel: (Reference) -> String
  private let onSelectHistory: () -> Void
  private let onSelectPack: (String) -> Void
  private let onSelect: (Reference) -> Void
  private let onRetry: () -> Void
  private let image: (ChatStickerPickerImageSource<Reference, Asset>) -> ImageContent

  private let columns = [GridItem(.adaptive(minimum: 88), spacing: 10)]

  /// ステッカーpickerを作成する。
  public init(
    isCatalogLoading: Bool,
    isCatalogAvailable: Bool,
    loadState: ChatStickerPickerLoadState,
    packs: [ChatStickerPickerPack<Reference, Asset>],
    selectedPackID: String,
    isHistorySelected: Bool,
    recentReferences: [Reference],
    strings: ChatStickerPickerStrings,
    referenceAccessibilityLabel: @escaping (Reference) -> String = { String(describing: $0) },
    onSelectHistory: @escaping () -> Void,
    onSelectPack: @escaping (String) -> Void,
    onSelect: @escaping (Reference) -> Void,
    onRetry: @escaping () -> Void,
    @ViewBuilder image: @escaping (ChatStickerPickerImageSource<Reference, Asset>) -> ImageContent
  ) {
    self.isCatalogLoading = isCatalogLoading
    self.isCatalogAvailable = isCatalogAvailable
    self.loadState = loadState
    self.packs = packs
    self.selectedPackID = selectedPackID
    self.isHistorySelected = isHistorySelected
    self.recentReferences = recentReferences
    self.strings = strings
    self.referenceAccessibilityLabel = referenceAccessibilityLabel
    self.onSelectHistory = onSelectHistory
    self.onSelectPack = onSelectPack
    self.onSelect = onSelect
    self.onRetry = onRetry
    self.image = image
  }

  public var body: some View {
    Group {
      if isCatalogLoading {
        ProgressView()
      } else if !isCatalogAvailable {
        unavailableContent
      } else {
        switch loadState {
        case .idle, .loading:
          ProgressView()
        case .unavailable:
          unavailableContent
        case .failed:
          failureContent
        case .loaded:
          loadedContent
        }
      }
    }
  }

  private var selectedPack: ChatStickerPickerPack<Reference, Asset>? {
    packs.first(where: { $0.id == selectedPackID }) ?? packs.first
  }

  private var unavailableContent: some View {
    VStack(spacing: 12) {
      Image(systemName: "face.smiling.inverse")
        .font(.largeTitle)
        .foregroundStyle(.secondary)
      Text(strings.unavailableTitle)
        .font(.headline)
      if let description = strings.unavailableDescription {
        Text(description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .multilineTextAlignment(.center)
    .padding()
  }

  private var failureContent: some View {
    VStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle")
        .font(.largeTitle)
        .foregroundStyle(.secondary)
      Text(strings.failedTitle)
        .font(.headline)
      Button(strings.retryLabel, action: onRetry)
    }
    .multilineTextAlignment(.center)
    .padding()
  }

  private var loadedContent: some View {
    VStack(spacing: 0) {
      packTabs
      Divider()
      stickerGrid
    }
  }

  private var packTabs: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 12) {
        Button(action: onSelectHistory) {
          Image(systemName: "clock.arrow.circlepath")
            .font(.title2)
            .frame(width: 54, height: 44)
            .padding(6)
            .background(
              isHistorySelected ? Color.accentColor.opacity(0.16) : Color.clear,
              in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(strings.historyLabel)

        ForEach(packs) { pack in
          Button {
            onSelectPack(pack.id)
          } label: {
            image(.asset(pack.trayIcon))
              .frame(width: 54, height: 44)
              .padding(6)
              .background(
                selectedPackID == pack.id ? Color.accentColor.opacity(0.16) : Color.clear,
                in: RoundedRectangle(cornerRadius: 12)
              )
          }
          .buttonStyle(.plain)
          .accessibilityLabel(pack.displayName)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    }
    .scrollIndicators(.hidden)
  }

  private var stickerGrid: some View {
    ScrollView {
      if isHistorySelected, recentReferences.isEmpty {
        ContentUnavailableView(strings.historyEmptyTitle, systemImage: "clock.arrow.circlepath")
          .padding(.top, 40)
      } else {
        LazyVGrid(columns: columns, spacing: 10) {
          if isHistorySelected {
            ForEach(recentReferences, id: \.self) { reference in
              Button {
                onSelect(reference)
              } label: {
                image(.reference(reference))
                  .frame(minHeight: 88)
              }
              .buttonStyle(.plain)
              .accessibilityLabel(referenceAccessibilityLabel(reference))
            }
          } else {
            ForEach(selectedPack?.stickers ?? []) { sticker in
              Button {
                onSelect(sticker.reference)
              } label: {
                image(.asset(sticker.asset))
                  .frame(minHeight: 88)
              }
              .buttonStyle(.plain)
              .accessibilityLabel(sticker.accessibilityLabel)
            }
          }
        }
        .padding(12)
      }
    }
  }
}
