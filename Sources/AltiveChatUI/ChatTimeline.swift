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
    await Task.yield()
    scrollProxy.scrollTo(id, anchor: anchor)
  }

  private func perform(animation: Animation?, action: () -> Void) {
    if let animation {
      withAnimation(animation, action)
    } else {
      action()
    }
  }
}

/// タイムライン上端で履歴を追加する方法。
public enum ChatTimelineHistoryLoadingMode: Hashable, Sendable {
  /// 利用者の操作で追加する。
  case manual
  /// 上端へ到達したときに自動で追加する。
  case automatic
}

/// タイムラインの履歴追加設定。
@MainActor
public struct ChatTimelineHistoryConfiguration<ID: Hashable> {
  fileprivate let mode: ChatTimelineHistoryLoadingMode?
  fileprivate let canLoadOlder: Bool
  fileprivate let isLoading: Bool
  fileprivate let anchorID: ID?
  fileprivate let loadOlderLabel: String
  fileprivate let onLoadOlder: () async -> Void

  /// 履歴追加を使用しない設定。
  public static var disabled: Self {
    .init(
      mode: nil,
      canLoadOlder: false,
      isLoading: false,
      anchorID: nil,
      loadOlderLabel: "",
      onLoadOlder: {}
    )
  }

  /// 利用者の操作で履歴を追加する設定を作成する。
  public static func manual(
    canLoadOlder: Bool,
    isLoading: Bool,
    anchorID: ID?,
    loadOlderLabel: String,
    onLoadOlder: @escaping () async -> Void
  ) -> Self {
    .init(
      mode: .manual,
      canLoadOlder: canLoadOlder,
      isLoading: isLoading,
      anchorID: anchorID,
      loadOlderLabel: loadOlderLabel,
      onLoadOlder: onLoadOlder
    )
  }

  /// 上端への到達時に履歴を自動追加する設定を作成する。
  public static func automatic(
    canLoadOlder: Bool,
    isLoading: Bool,
    anchorID: ID?,
    loadOlderLabel: String,
    onLoadOlder: @escaping () async -> Void
  ) -> Self {
    .init(
      mode: .automatic,
      canLoadOlder: canLoadOlder,
      isLoading: isLoading,
      anchorID: anchorID,
      loadOlderLabel: loadOlderLabel,
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
  private let positioningScope: AnyHashable
  private let isReadyForInitialPositioning: Bool
  private let initialTargetID: ID?
  private let initialTargetAnchor: UnitPoint
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
  /// `initialTargetID` が `nil` の場合は末尾から表示する。通知などで指定項目を
  /// 表示するときだけ対象IDと `.center` を渡す。
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
    self.positioningScope = positioningScope
    self.isReadyForInitialPositioning = isReadyForInitialPositioning
    self.initialTargetID = initialTargetID
    self.initialTargetAnchor = initialTargetAnchor
    self.followLatestTrigger = followLatestTrigger
    self.followLatestAnimation = followLatestAnimation
    self.history = history
    self.spacing = spacing
    self.contentInsets = contentInsets
    self.maximumContentWidth = maximumContentWidth
    self.onInitialPositioning = onInitialPositioning
    self.content = content
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
      .onChange(of: initialTargetID) { _, _ in
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
      Button {
        requestHistory(using: proxy)
      } label: {
        if history.isLoading {
          ProgressView()
        } else {
          Text(history.loadOlderLabel)
        }
      }
      .disabled(history.isLoading || isHistoryLoadScheduled)
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

    if let initialTargetID {
      proxy.scrollTo(initialTargetID, anchor: initialTargetAnchor)
    } else {
      proxy.scrollToBottom()
    }
    Task { @MainActor in
      await Task.yield()
      guard positioningState.positionedScope == positioningScope else { return }
      if let initialTargetID {
        proxy.scrollTo(initialTargetID, anchor: initialTargetAnchor)
      } else {
        proxy.scrollToBottom()
      }
      onInitialPositioning(proxy)
      requestAutomaticHistoryIfNeeded(using: proxy)
    }
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
