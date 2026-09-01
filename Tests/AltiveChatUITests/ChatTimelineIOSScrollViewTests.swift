#if os(iOS)
  import SwiftUI
  import Testing
  import UIKit

  @testable import AltiveChatUI

  @Suite("iOS実ScrollViewのタイムライン横位置", .serialized)
  struct ChatTimelineIOSScrollViewTests {
    @Test("システムイベントを含む初期表示で横方向をviewport内へ固定する")
    @MainActor
    func keepsSystemEventWithinViewportOnInitialDisplay() async throws {
      let cardFrameBox = ChatTimelineIOSFrameBox()
      let timeline = ChatTimeline(
        timelineID: "ios-horizontal-layout-test",
        isReadyForInitialPositioning: true,
        initialPosition: ChatTimelineInitialPosition<Int>.latest,
        followLatestTrigger: 0,
        followLatestAnimation: nil,
        contentInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        maximumContentWidth: 720
      ) { _ in
        ForEach(0..<1, id: \.self) { id in
          VStack(alignment: .leading, spacing: 6) {
            HStack {
              Spacer()
              Text(verbatim: "1日前")
            }
            ChatSystemEventCard {
              Text(verbatim: String(repeating: "新しいクエストが発注されました", count: 8))
            }
            .background {
              GeometryReader { geometry in
                Color.clear
                  .onAppear { cardFrameBox.frame = geometry.frame(in: .global) }
                  .onChange(of: geometry.size) { _, _ in
                    cardFrameBox.frame = geometry.frame(in: .global)
                  }
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .id(id)
        }
      }
      .frame(width: 320, height: 480)
      let controller = UIHostingController(rootView: timeline)
      let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
      window.rootViewController = controller
      window.makeKeyAndVisible()
      defer {
        window.isHidden = true
        window.rootViewController = nil
      }

      await settleLayout(of: controller.view)
      let scrollView = try #require(findScrollView(in: controller.view))
      let leadingOffset = -scrollView.adjustedContentInset.left
      let cardFrame = try #require(cardFrameBox.frame)

      #expect(scrollView.contentSize.width <= scrollView.bounds.width + 2)
      #expect(abs(scrollView.contentOffset.x - leadingOffset) < 2)
      #expect(abs(cardFrame.midX - scrollView.bounds.midX) < 2)
    }

    @Test("非表示中にデータが届いたタブを初めて開いても横位置を維持する")
    @MainActor
    func keepsHorizontalPositionWhenSelectingReadyTab() async throws {
      let model = ChatTimelineIOSTabModel()
      let cardFrameBox = ChatTimelineIOSFrameBox()
      let content = ChatTimelineIOSTabTestView(model: model, cardFrameBox: cardFrameBox)
        .frame(width: 320, height: 640)
      let controller = UIHostingController(rootView: content)
      let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
      window.rootViewController = controller
      window.makeKeyAndVisible()
      defer {
        window.isHidden = true
        window.rootViewController = nil
      }

      await settleLayout(of: controller.view)
      model.hasEntries = true
      model.selectedTab = 1
      await settleLayout(of: controller.view, iterations: 12)

      let scrollViews = findScrollViews(in: controller.view)
      let scrollView = try #require(
        scrollViews.first {
          $0.contentSize.height > $0.bounds.height + 2 && $0.bounds.width > 300
        }
      )
      let cardFrame = try #require(cardFrameBox.frame)
      let leadingOffset = -scrollView.adjustedContentInset.left

      #expect(scrollView.contentSize.width <= scrollView.bounds.width + 2)
      #expect(abs(scrollView.contentOffset.x - leadingOffset) < 2)
      #expect(abs(cardFrame.midX - scrollView.frame(in: window).midX) < 2)
    }

    @MainActor
    private func settleLayout(of view: UIView, iterations: Int = 8) async {
      for _ in 0..<iterations {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        await withCheckedContinuation { continuation in
          DispatchQueue.main.async {
            continuation.resume()
          }
        }
      }
    }

    @MainActor
    private func findScrollView(in view: UIView) -> UIScrollView? {
      if let scrollView = view as? UIScrollView {
        return scrollView
      }
      for subview in view.subviews {
        if let scrollView = findScrollView(in: subview) {
          return scrollView
        }
      }
      return nil
    }

    @MainActor
    private func findScrollViews(in view: UIView) -> [UIScrollView] {
      let current = (view as? UIScrollView).map { [$0] } ?? []
      return current + view.subviews.flatMap(findScrollViews)
    }
  }

  @MainActor
  private final class ChatTimelineIOSFrameBox {
    var frame: CGRect?
  }

  @MainActor
  private final class ChatTimelineIOSTabModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var hasEntries = false
  }

  private struct ChatTimelineIOSTabTestView: View {
    @ObservedObject var model: ChatTimelineIOSTabModel
    let cardFrameBox: ChatTimelineIOSFrameBox

    var body: some View {
      Group {
        if model.selectedTab == 0 {
          Color.clear
        } else {
          NavigationStack {
            ChatTimeline(
              timelineID: "ios-tab-horizontal-layout-test",
              isReadyForInitialPositioning: model.selectedTab == 1 && model.hasEntries,
              initialPosition: ChatTimelineInitialPosition<Int>.latest,
              followLatestTrigger: 0,
              followLatestAnimation: nil,
              contentInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
              maximumContentWidth: 720
            ) { _ in
              if model.hasEntries {
                ForEach(0..<20, id: \.self) { id in
                  VStack(alignment: .leading, spacing: 6) {
                    HStack {
                      Spacer()
                      Text(verbatim: "1日前")
                    }
                    ChatSystemEventCard {
                      Text(verbatim: String(repeating: "新しいクエストが発注されました", count: 4))
                    }
                    .background {
                      if id == 19 {
                        GeometryReader { geometry in
                          Color.clear
                            .onAppear { cardFrameBox.frame = geometry.frame(in: .global) }
                            .onChange(of: geometry.size) { _, _ in
                              cardFrameBox.frame = geometry.frame(in: .global)
                            }
                        }
                      }
                    }
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .id(id)
                }
              }
            }
            .navigationTitle("タイムライン")
          }
        }
      }
    }
  }

  extension UIView {
    fileprivate func frame(in view: UIView) -> CGRect {
      convert(bounds, to: view)
    }
  }
#endif
