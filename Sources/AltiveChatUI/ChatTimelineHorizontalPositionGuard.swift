#if os(iOS)
  import SwiftUI
  import UIKit

  /// SwiftUIの末尾位置決め後に残る横方向のoffsetを先頭へ戻す。
  struct ChatTimelineHorizontalPositionGuard: UIViewRepresentable {
    func makeUIView(context: Context) -> ChatTimelineHorizontalPositionGuardView {
      ChatTimelineHorizontalPositionGuardView()
    }

    func updateUIView(
      _ uiView: ChatTimelineHorizontalPositionGuardView,
      context: Context
    ) {
      uiView.scheduleCorrection()
    }
  }

  final class ChatTimelineHorizontalPositionGuardView: UIView {
    override func didMoveToWindow() {
      super.didMoveToWindow()
      scheduleCorrection()
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      correctHorizontalPosition()
      scheduleCorrection()
    }

    func scheduleCorrection() {
      DispatchQueue.main.async { [weak self] in
        self?.correctHorizontalPosition()
      }
    }

    func correctHorizontalPosition() {
      guard
        let scrollView = enclosingScrollView(),
        let window = scrollView.window
      else { return }
      scrollView.alwaysBounceHorizontal = false
      scrollView.isDirectionalLockEnabled = true
      let contentMinX = convert(bounds, to: window).minX
      let viewportMinX = scrollView.convert(scrollView.bounds, to: window).minX
      let correction = contentMinX - viewportMinX
      guard abs(correction) > 0.5 else { return }
      scrollView.contentOffset.x += correction
    }

    private func enclosingScrollView() -> UIScrollView? {
      var ancestor = superview
      while let view = ancestor {
        if let scrollView = view as? UIScrollView {
          return scrollView
        }
        ancestor = view.superview
      }
      return nil
    }
  }
#endif
