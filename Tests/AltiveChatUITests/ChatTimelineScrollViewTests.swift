#if os(macOS)
  import AppKit
  import SwiftUI
  import Testing

  @testable import AltiveChatUI

  @Suite("実ScrollViewのタイムライン初期位置")
  struct ChatTimelineScrollViewTests {
    @Test("通常起動では実ScrollViewを末尾へ配置する")
    @MainActor
    func positionsLatestAtBottom() async throws {
      let hosted = makeHostedTimeline(initialPosition: .latest)
      defer { hosted.window.close() }

      await settleLayout(of: hosted.view)
      let scrollView = try #require(findScrollView(in: hosted.view))
      let documentView = try #require(scrollView.documentView)
      let maximumOffset = max(0, documentView.bounds.height - scrollView.documentVisibleRect.height)

      #expect(abs(scrollView.documentVisibleRect.minY - maximumOffset) < 2)
    }

    @Test("指定項目を実ScrollViewの中央へ配置する")
    @MainActor
    func positionsSpecifiedItemAtCenter() async throws {
      let hosted = makeHostedTimeline(initialPosition: .item(10))
      defer { hosted.window.close() }

      await settleLayout(of: hosted.view)
      let scrollView = try #require(findScrollView(in: hosted.view))
      let expectedItemCenter = CGFloat(10 * 40 + 20)

      #expect(abs(scrollView.documentVisibleRect.midY - expectedItemCenter) < 24)
    }

    @Test("非表示中に項目が届いたタイムラインを表示時に末尾へ配置する")
    @MainActor
    func keepsValidPositionWhenHiddenTimelineBecomesReady() async throws {
      let model = ChatTimelineDelayedVisibilityTestModel()
      let content = ChatTimelineDelayedVisibilityTestView(model: model)
        .frame(width: 320, height: 320)
      let hostedView = NSHostingView(rootView: content)
      let hosted = host(view: hostedView)
      defer { hosted.window.close() }

      await settleLayout(of: hosted.view)
      #expect(model.initialPositioningCount == 0)

      model.items = Array(0..<40)
      model.composerHeight = 64
      model.isVisible = true
      await settleLayout(of: hosted.view, iterations: 12)

      let scrollView = try #require(findScrollView(in: hosted.view))
      expectValidPosition(in: scrollView)
      #expect(model.initialPositioningCount == 1)
    }

    @Test("履歴追加後も実ScrollViewで先頭項目の位置を維持する")
    @MainActor
    func preservesPositionWhenHistoryIsPrepended() async throws {
      let model = ChatTimelineHistoryTestModel()
      let proxyBox = ChatTimelineProxyBox()
      let content = ChatTimelineHistoryTestView(model: model, proxyBox: proxyBox)
        .frame(width: 320, height: 200)
      let hostedView = NSHostingView(rootView: content)
      let hosted = host(view: hostedView)
      defer { hosted.window.close() }

      await settleLayout(of: hosted.view)
      let scrollView = try #require(findScrollView(in: hosted.view))
      scrollView.contentView.scroll(to: .zero)
      scrollView.reflectScrolledClipView(scrollView.contentView)
      await settleLayout(of: hosted.view)
      let previousOffset = scrollView.documentVisibleRect.minY
      let proxy = try #require(proxyBox.proxy)

      await proxy.preservePosition(at: 0) {
        await model.loadOlder()
      }
      await settleLayout(of: hosted.view)

      #expect(model.loadCount == 1)
      #expect(abs((scrollView.documentVisibleRect.minY - previousOffset) - 200) < 24)
    }

    @MainActor
    private func makeHostedTimeline(
      initialPosition: ChatTimelineInitialPosition<Int>
    ) -> (window: NSWindow, view: NSHostingView<some View>) {
      let timeline = ChatTimeline(
        timelineID: "scroll-test",
        isReadyForInitialPositioning: true,
        initialPosition: initialPosition,
        followLatestTrigger: 0,
        followLatestAnimation: nil,
        spacing: 0
      ) { _ in
        ForEach(0..<20, id: \.self) { id in
          Text(verbatim: "項目\(id)")
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .id(id)
        }
      }
      let content = timeline.frame(width: 320, height: 200)
      let hostedView = NSHostingView(rootView: content)
      return host(view: hostedView)
    }

    @MainActor
    private func host<Content: View>(
      view hostedView: NSHostingView<Content>
    ) -> (window: NSWindow, view: NSHostingView<Content>) {
      hostedView.frame = NSRect(x: 0, y: 0, width: 320, height: 200)
      let window = NSWindow(
        contentRect: hostedView.frame,
        styleMask: .borderless,
        backing: .buffered,
        defer: false
      )
      window.contentView = hostedView
      window.orderFront(nil)
      return (window, hostedView)
    }

    @MainActor
    private func settleLayout(of view: NSView, iterations: Int = 6) async {
      for _ in 0..<iterations {
        view.layoutSubtreeIfNeeded()
        await withCheckedContinuation { continuation in
          DispatchQueue.main.async {
            continuation.resume()
          }
        }
      }
    }

    @MainActor
    private func expectLatestPosition(in scrollView: NSScrollView) {
      guard let documentView = scrollView.documentView else {
        Issue.record("ScrollViewのdocumentViewを取得できませんでした。")
        return
      }
      let visibleRect = scrollView.documentVisibleRect
      let maximumOffset = max(0, documentView.bounds.height - visibleRect.height)

      #expect(visibleRect.minY >= -2)
      #expect(visibleRect.minY <= maximumOffset + 2)
      #expect(abs(visibleRect.minY - maximumOffset) < 2)
    }

    @MainActor
    private func expectValidPosition(in scrollView: NSScrollView) {
      guard let documentView = scrollView.documentView else {
        Issue.record("ScrollViewのdocumentViewを取得できませんでした。")
        return
      }
      let visibleRect = scrollView.documentVisibleRect
      let maximumOffset = max(0, documentView.bounds.height - visibleRect.height)

      #expect(visibleRect.minY >= -2)
      #expect(visibleRect.minY <= maximumOffset + 2)
      #expect(visibleRect.intersects(documentView.bounds))
    }

    @MainActor
    private func findScrollView(in view: NSView) -> NSScrollView? {
      if let scrollView = view as? NSScrollView {
        return scrollView
      }
      for subview in view.subviews {
        if let scrollView = findScrollView(in: subview) {
          return scrollView
        }
      }
      return nil
    }

  }

  @MainActor
  private final class ChatTimelineHistoryTestModel: ObservableObject {
    @Published var items = Array(0..<20)
    private(set) var loadCount = 0

    func loadOlder() async {
      items.insert(contentsOf: -5..<0, at: 0)
      loadCount += 1
    }
  }

  @MainActor
  private final class ChatTimelineProxyBox {
    var proxy: ChatTimelineProxy?
  }

  @MainActor
  private final class ChatTimelineDelayedVisibilityTestModel: ObservableObject {
    @Published var items: [Int] = []
    @Published var isVisible = false
    @Published var composerHeight: CGFloat = 0
    var initialPositioningCount = 0
  }

  private struct ChatTimelineDelayedVisibilityTestView: View {
    @ObservedObject var model: ChatTimelineDelayedVisibilityTestModel

    var body: some View {
      VStack(spacing: 0) {
        ChatTimeline(
          timelineID: "delayed-visibility-test",
          isReadyForInitialPositioning: model.isVisible && !model.items.isEmpty,
          initialPosition: ChatTimelineInitialPosition<Int>.latest,
          followLatestTrigger: 0,
          followLatestAnimation: nil,
          spacing: 0,
          onInitialPositioning: { _ in model.initialPositioningCount += 1 }
        ) { _ in
          ForEach(model.items, id: \.self) { id in
            Text(verbatim: "項目\(id)")
              .frame(maxWidth: .infinity)
              .frame(height: 40)
              .id(id)
          }
        }
        Color.clear.frame(height: model.composerHeight)
      }
    }
  }

  private struct ChatTimelineHistoryTestView: View {
    @ObservedObject var model: ChatTimelineHistoryTestModel
    let proxyBox: ChatTimelineProxyBox

    var body: some View {
      ChatTimeline(
        timelineID: "history-test",
        isReadyForInitialPositioning: true,
        initialPosition: ChatTimelineInitialPosition<Int>.latest,
        followLatestTrigger: 0,
        followLatestAnimation: nil,
        spacing: 0,
        onInitialPositioning: { proxyBox.proxy = $0 },
        content: { _ in
          ForEach(model.items, id: \.self) { id in
            Text(verbatim: "項目\(id)")
              .frame(maxWidth: .infinity)
              .frame(height: 40)
              .id(id)
          }
        }
      )
    }
  }
#endif
