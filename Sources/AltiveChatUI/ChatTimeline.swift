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
  private let spacing: CGFloat
  private let contentInsets: EdgeInsets
  private let maximumContentWidth: CGFloat?
  private let onInitialPositioning: (ChatTimelineProxy) -> Void
  private let content: (ChatTimelineProxy) -> Content

  @State private var positioningState = ChatTimelinePositioningState<AnyHashable>()
  @State private var bottomAnchorID = ChatTimelineBottomAnchorID()

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
      .defaultScrollAnchor(.bottom)
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
    }
  }
}

private struct ChatTimelineBottomAnchorID: Hashable {
  let rawValue = UUID()
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
