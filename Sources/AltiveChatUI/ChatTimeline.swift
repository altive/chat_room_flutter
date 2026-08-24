import Foundation
import SwiftUI

/// チャットタイムラインのスクロール操作を提供する。
@MainActor
public struct ChatTimelineProxy {
  fileprivate let scrollProxy: ScrollViewProxy
  fileprivate let bottomAnchorID: ChatTimelineBottomAnchorID

  /// 指定した表示要素へ移動する。
  public func scrollTo<ID: Hashable>(
    _ id: ID,
    anchor: UnitPoint? = nil,
    animation: Animation? = nil
  ) {
    perform(animation: animation) {
      scrollProxy.scrollTo(id, anchor: anchor)
    }
  }

  /// タイムラインの末尾へ移動する。
  public func scrollToBottom(animation: Animation? = nil) {
    perform(animation: animation) {
      scrollProxy.scrollTo(bottomAnchorID, anchor: .bottom)
    }
  }

  /// 履歴追加後も指定した表示要素の位置を維持する。
  public func preservePosition<ID: Hashable>(
    at id: ID,
    anchor: UnitPoint = .top,
    while operation: @MainActor () async -> Void
  ) async {
    await operation()
    await waitForTimelineLayout()
    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction) {
      scrollProxy.scrollTo(id, anchor: anchor)
    }
  }

  private func perform(animation: Animation?, action: () -> Void) {
    if let animation {
      withAnimation(animation, action)
    } else {
      action()
    }
  }

  private func waitForTimelineLayout() async {
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        DispatchQueue.main.async {
          continuation.resume()
        }
      }
    }
  }
}

/// タイムラインを最初に表示する位置。
public enum ChatTimelineInitialPosition<ID: Hashable>: Hashable {
  /// 最新項目が見える末尾。
  case latest
  /// 指定項目と配置anchor。
  case item(ID, anchor: UnitPoint)

  /// 指定項目を中央へ表示する初期位置を返す。
  public static func item(_ id: ID) -> Self {
    .item(id, anchor: .center)
  }
}

/// タイムライン上端で履歴を追加する方法。
public enum ChatTimelineHistoryLoadingMode: Hashable, Sendable {
  /// 利用者の操作で追加する。
  case manual
  /// 上端へ到達したときに自動で追加する。
  case automatic
}

/// 履歴読み込み操作の外観。
public enum ChatTimelineHistoryControlStyle: Hashable, Sendable {
  /// テキスト中心の簡潔な表示。
  case plain
  /// システム画像と枠線を持つボタン表示。
  case bordered(systemImage: String)
}

/// タイムラインの履歴追加設定。
@MainActor
public struct ChatTimelineHistoryConfiguration<ID: Hashable> {
  fileprivate let mode: ChatTimelineHistoryLoadingMode?
  fileprivate let canLoadOlder: Bool
  fileprivate let isLoading: Bool
  fileprivate let anchorID: ID?
  fileprivate let loadOlderLabel: String
  fileprivate let controlStyle: ChatTimelineHistoryControlStyle
  fileprivate let onLoadOlder: () async -> Void

  /// 履歴追加を使用しない設定。
  public static var disabled: Self {
    .init(
      mode: nil,
      canLoadOlder: false,
      isLoading: false,
      anchorID: nil,
      loadOlderLabel: "",
      controlStyle: .plain,
      onLoadOlder: {}
    )
  }

  /// 利用者の操作で履歴を追加する設定を作成する。
  public static func manual(
    canLoadOlder: Bool,
    isLoading: Bool,
    anchorID: ID?,
    loadOlderLabel: String,
    controlStyle: ChatTimelineHistoryControlStyle = .plain,
    onLoadOlder: @escaping () async -> Void
  ) -> Self {
    .init(
      mode: .manual,
      canLoadOlder: canLoadOlder,
      isLoading: isLoading,
      anchorID: anchorID,
      loadOlderLabel: loadOlderLabel,
      controlStyle: controlStyle,
      onLoadOlder: onLoadOlder
    )
  }

  /// 上端への到達時に履歴を自動追加する設定を作成する。
  public static func automatic(
    canLoadOlder: Bool,
    isLoading: Bool,
    anchorID: ID?,
    loadOlderLabel: String,
    controlStyle: ChatTimelineHistoryControlStyle = .plain,
    onLoadOlder: @escaping () async -> Void
  ) -> Self {
    .init(
      mode: .automatic,
      canLoadOlder: canLoadOlder,
      isLoading: isLoading,
      anchorID: anchorID,
      loadOlderLabel: loadOlderLabel,
      controlStyle: controlStyle,
      onLoadOlder: onLoadOlder
    )
  }
}

/// アプリ固有の行を差し込める、チャット向けの汎用タイムライン。
///
/// 初期位置、末尾追従、履歴追加時の位置保持を共通化し、行の内容やページング判断は
/// 利用アプリが所有する。
@MainActor
public struct ChatTimeline<ID: Hashable, FollowTrigger: Equatable, Content: View>: View {
  private let timelineID: AnyHashable
  private let isReadyForInitialPositioning: Bool
  private let initialPosition: ChatTimelineInitialPosition<ID>
  private let followLatestTrigger: FollowTrigger
  private let followLatestAnimation: Animation?
  private let history: ChatTimelineHistoryConfiguration<ID>
  private let spacing: CGFloat
  private let contentInsets: EdgeInsets
  private let maximumContentWidth: CGFloat?
  private let onInitialPositioning: (ChatTimelineProxy) -> Void
  private let content: (ChatTimelineProxy) -> Content

  @State private var positioningState = ChatTimelinePositioningState<AnyHashable>()
  @State private var bottomAnchorID = ChatTimelineBottomAnchorID()
  @State private var historyCoordinateSpaceID = UUID()
  @State private var historyTopOffset: CGFloat?
  @State private var isHistoryLoadScheduled = false

  /// 汎用タイムラインを作成する。
  ///
  /// 通常起動では`initialPosition`へ`.latest`を、通知などで指定項目を表示するときは
  /// `.item(id)`を渡す。
  public init(
    timelineID: AnyHashable,
    isReadyForInitialPositioning: Bool,
    initialPosition: ChatTimelineInitialPosition<ID> = .latest,
    followLatestTrigger: FollowTrigger,
    followLatestAnimation: Animation? = .easeOut(duration: 0.2),
    history: ChatTimelineHistoryConfiguration<ID> = .disabled,
    spacing: CGFloat = 12,
    contentInsets: EdgeInsets = EdgeInsets(),
    maximumContentWidth: CGFloat? = nil,
    onInitialPositioning: @escaping (ChatTimelineProxy) -> Void = { _ in },
    @ViewBuilder content: @escaping (ChatTimelineProxy) -> Content
  ) {
    self.timelineID = timelineID
    self.isReadyForInitialPositioning = isReadyForInitialPositioning
    self.initialPosition = initialPosition
    self.followLatestTrigger = followLatestTrigger
    self.followLatestAnimation = followLatestAnimation
    self.history = history
    self.spacing = spacing
    self.contentInsets = contentInsets
    self.maximumContentWidth = maximumContentWidth
    self.onInitialPositioning = onInitialPositioning
    self.content = content
  }

  /// 従来の位置指定引数から汎用タイムラインを作成する。
  @available(
    *,
    deprecated,
    message: "timelineIDとChatTimelineInitialPositionを使用してください。"
  )
  public init(
    positioningScope: AnyHashable,
    isReadyForInitialPositioning: Bool,
    initialTargetID: ID? = nil,
    initialTargetAnchor: UnitPoint = .center,
    followLatestTrigger: FollowTrigger,
    followLatestAnimation: Animation? = .easeOut(duration: 0.2),
    history: ChatTimelineHistoryConfiguration<ID> = .disabled,
    spacing: CGFloat = 12,
    contentInsets: EdgeInsets = EdgeInsets(),
    maximumContentWidth: CGFloat? = nil,
    onInitialPositioning: @escaping (ChatTimelineProxy) -> Void = { _ in },
    @ViewBuilder content: @escaping (ChatTimelineProxy) -> Content
  ) {
    self.init(
      timelineID: positioningScope,
      isReadyForInitialPositioning: isReadyForInitialPositioning,
      initialPosition: initialTargetID.map {
        .item($0, anchor: initialTargetAnchor)
      } ?? .latest,
      followLatestTrigger: followLatestTrigger,
      followLatestAnimation: followLatestAnimation,
      history: history,
      spacing: spacing,
      contentInsets: contentInsets,
      maximumContentWidth: maximumContentWidth,
      onInitialPositioning: onInitialPositioning,
      content: content
    )
  }

  public var body: some View {
    ScrollViewReader { scrollProxy in
      let timelineProxy = ChatTimelineProxy(
        scrollProxy: scrollProxy,
        bottomAnchorID: bottomAnchorID
      )
      ScrollView {
        LazyVStack(spacing: spacing) {
          historyControl(using: timelineProxy)
          content(timelineProxy)
          Color.clear
            .frame(height: 1)
            .id(bottomAnchorID)
        }
        .scrollTargetLayout()
        .frame(maxWidth: maximumContentWidth ?? .infinity)
        .padding(contentInsets)
        .frame(maxWidth: .infinity)
      }
      .coordinateSpace(name: historyCoordinateSpaceID)
      .defaultScrollAnchor(.bottom)
      .onPreferenceChange(ChatTimelineHistoryTopOffsetKey.self) { offset in
        historyTopOffset = offset
        requestAutomaticHistoryIfNeeded(using: timelineProxy)
      }
      .onAppear {
        positionInitiallyIfNeeded(using: timelineProxy)
      }
      .onChange(of: positioningScope) { _, _ in
        positioningState.reset()
        positionInitiallyIfNeeded(using: timelineProxy)
      }
      .onChange(of: isReadyForInitialPositioning) { _, _ in
        positionInitiallyIfNeeded(using: timelineProxy)
      }
      .onChange(of: followLatestTrigger) { previousTrigger, trigger in
        guard
          positioningState.shouldFollowLatest(
            scope: positioningScope,
            previousTrigger: previousTrigger,
            trigger: trigger
          )
        else { return }
        timelineProxy.scrollToBottom(animation: followLatestAnimation)
        Task { @MainActor in
          await Task.yield()
          guard positioningState.positionedScope == positioningScope else { return }
          timelineProxy.scrollToBottom()
        }
      }
    }
  }

  @ViewBuilder
  private func historyControl(using proxy: ChatTimelineProxy) -> some View {
    if history.mode != nil, history.canLoadOlder {
      historyButton(using: proxy)
        .background {
          if history.mode == .automatic {
            GeometryReader { geometry in
              Color.clear.preference(
                key: ChatTimelineHistoryTopOffsetKey.self,
                value: geometry.frame(in: .named(historyCoordinateSpaceID)).minY
              )
            }
          }
        }
    }
  }

  @ViewBuilder
  private func historyButton(using proxy: ChatTimelineProxy) -> some View {
    let button = Button {
      requestHistory(using: proxy)
    } label: {
      if history.isLoading {
        ProgressView()
          .padding(.bottom, history.controlStyle.isBordered ? 4 : 0)
      } else {
        switch history.controlStyle {
        case .plain:
          Text(history.loadOlderLabel)
        case .bordered(let systemImage):
          Label(history.loadOlderLabel, systemImage: systemImage)
        }
      }
    }
    .disabled(history.isLoading || isHistoryLoadScheduled)

    switch history.controlStyle {
    case .plain:
      button
    case .bordered:
      button
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
    }
  }

  private func requestAutomaticHistoryIfNeeded(using proxy: ChatTimelineProxy) {
    guard history.mode == .automatic, historyTopOffset.map({ $0 >= -1 }) == true else { return }
    requestHistory(using: proxy)
  }

  private func requestHistory(using proxy: ChatTimelineProxy) {
    guard
      positioningState.positionedScope == positioningScope,
      history.canLoadOlder,
      !history.isLoading,
      !isHistoryLoadScheduled
    else { return }

    isHistoryLoadScheduled = true
    Task { @MainActor in
      defer { isHistoryLoadScheduled = false }
      if let anchorID = history.anchorID {
        await proxy.preservePosition(at: anchorID) {
          await history.onLoadOlder()
        }
      } else {
        await history.onLoadOlder()
      }
    }
  }

  private func positionInitiallyIfNeeded(using proxy: ChatTimelineProxy) {
    guard
      positioningState.beginInitialPositioning(
        scope: positioningScope,
        isReady: isReadyForInitialPositioning
      )
    else { return }

    applyInitialPosition(using: proxy)
    Task { @MainActor in
      await waitForInitialLayout()
      guard positioningState.positionedScope == positioningScope else { return }
      applyInitialPosition(using: proxy)
      onInitialPositioning(proxy)
      requestAutomaticHistoryIfNeeded(using: proxy)
    }
  }

  private var positioningScope: AnyHashable {
    AnyHashable(
      ChatTimelinePositioningScope(
        timelineID: timelineID,
        initialPosition: initialPosition
      )
    )
  }

  private func applyInitialPosition(using proxy: ChatTimelineProxy) {
    switch initialPosition {
    case .latest:
      proxy.scrollToBottom()
    case .item(let id, let anchor):
      proxy.scrollTo(id, anchor: anchor)
    }
  }

  private func waitForInitialLayout() async {
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        continuation.resume()
      }
    }
  }
}

struct ChatTimelinePositioningScope<ID: Hashable>: Hashable {
  let timelineID: AnyHashable
  let initialPosition: ChatTimelineInitialPosition<ID>
}

extension ChatTimelineHistoryControlStyle {
  fileprivate var isBordered: Bool {
    if case .bordered = self { return true }
    return false
  }
}

private struct ChatTimelineBottomAnchorID: Hashable {
  let rawValue = UUID()
}

private struct ChatTimelineHistoryTopOffsetKey: PreferenceKey {
  static let defaultValue: CGFloat? = nil

  static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    value = nextValue() ?? value
  }
}

struct ChatTimelinePositioningState<Scope: Hashable> {
  private(set) var positionedScope: Scope?

  mutating func beginInitialPositioning(scope: Scope, isReady: Bool) -> Bool {
    guard isReady, positionedScope != scope else { return false }
    positionedScope = scope
    return true
  }

  mutating func reset() {
    positionedScope = nil
  }

  func shouldFollowLatest<Trigger: Equatable>(
    scope: Scope,
    previousTrigger: Trigger,
    trigger: Trigger
  ) -> Bool {
    positionedScope == scope && previousTrigger != trigger
  }
}
