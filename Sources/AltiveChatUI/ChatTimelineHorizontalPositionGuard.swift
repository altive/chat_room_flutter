#if os(iOS)
  import SwiftUI
  import UIKit

  /// SwiftUIの末尾位置決め後に残る横方向のoffsetを先頭へ戻す。
  struct ChatTimelineHorizontalPositionGuard: UIViewRepresentable {
    let isEnabled: Bool

    func makeUIView(context: Context) -> ChatTimelineHorizontalPositionGuardView {
      ChatTimelineHorizontalPositionGuardView()
    }

    func updateUIView(
      _ uiView: ChatTimelineHorizontalPositionGuardView,
      context: Context
    ) {
      uiView.isCorrectionEnabled = isEnabled
      uiView.scheduleCorrection()
    }
  }

  final class ChatTimelineHorizontalPositionGuardView: UIView {
    var isCorrectionEnabled = false {
      didSet {
        guard isCorrectionEnabled, !oldValue else { return }
        setNeedsLayout()
        scheduleCorrection()
      }
    }

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
      guard isCorrectionEnabled else { return }
      DispatchQueue.main.async { [weak self] in
        self?.correctHorizontalPosition()
      }
    }

    func correctHorizontalPosition() {
      guard
        isCorrectionEnabled,
        let scrollView = enclosingScrollView(),
        scrollView.window != nil
      else { return }
      scrollView.alwaysBounceHorizontal = false
      scrollView.isDirectionalLockEnabled = true
      let leadingOffset = -scrollView.adjustedContentInset.left
      guard abs(scrollView.contentOffset.x - leadingOffset) > 0.5 else { return }
      scrollView.setContentOffset(
        CGPoint(x: leadingOffset, y: scrollView.contentOffset.y),
        animated: false
      )
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
