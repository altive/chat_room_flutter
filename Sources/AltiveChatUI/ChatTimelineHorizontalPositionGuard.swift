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
    private weak var observedScrollView: UIScrollView?
    private var contentOffsetObservation: NSKeyValueObservation?

    var isCorrectionEnabled = false {
      didSet {
        if !isCorrectionEnabled {
          stopObservingScrollView()
          return
        }
        guard isCorrectionEnabled, !oldValue else { return }
        setNeedsLayout()
        scheduleCorrection()
      }
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      if window == nil {
        stopObservingScrollView()
      }
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
        self?.startObservingScrollViewIfNeeded()
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

    private func startObservingScrollViewIfNeeded() {
      guard isCorrectionEnabled, let scrollView = enclosingScrollView() else { return }
      guard observedScrollView !== scrollView else { return }
      stopObservingScrollView()
      observedScrollView = scrollView
      contentOffsetObservation = scrollView.observe(\.contentOffset, options: [.new]) {
        [weak self] _, _ in
        DispatchQueue.main.async { [weak self] in
          self?.correctHorizontalPosition()
        }
      }
    }

    private func stopObservingScrollView() {
      contentOffsetObservation?.invalidate()
      contentOffsetObservation = nil
      observedScrollView = nil
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
