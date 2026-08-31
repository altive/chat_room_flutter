import SwiftUI

enum ChatSystemEventCardLayoutMetrics {
  static func availableWidth(proposedWidth: CGFloat?, idealWidth: CGFloat) -> CGFloat {
    if let proposedWidth, proposedWidth.isFinite {
      return max(0, proposedWidth)
    }
    if idealWidth.isFinite {
      return max(0, idealWidth)
    }
    return 0
  }

  static func compactCardWidth(idealWidth: CGFloat, availableWidth: CGFloat) -> CGFloat {
    let safeAvailableWidth =
      availableWidth.isFinite
      ? max(0, availableWidth)
      : (idealWidth.isFinite ? max(0, idealWidth) : 0)
    guard idealWidth.isFinite else { return safeAvailableWidth }
    return min(max(0, idealWidth), safeAvailableWidth)
  }

  static func centeredOriginX(containerWidth: CGFloat, cardWidth: CGFloat) -> CGFloat {
    (containerWidth - cardWidth) / 2
  }
}

private struct CompactCenteredSystemEventCardLayout: Layout {
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) -> CGSize {
    guard let subview = subviews.first else { return .zero }
    let idealSize = subview.sizeThatFits(.unspecified)
    let availableWidth = ChatSystemEventCardLayoutMetrics.availableWidth(
      proposedWidth: proposal.width,
      idealWidth: idealSize.width
    )
    let cardWidth = ChatSystemEventCardLayoutMetrics.compactCardWidth(
      idealWidth: idealSize.width,
      availableWidth: availableWidth
    )
    let cardSize = subview.sizeThatFits(
      ProposedViewSize(width: cardWidth, height: proposal.height)
    )
    return CGSize(width: availableWidth, height: cardSize.height)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal _: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) {
    guard let subview = subviews.first else { return }
    let idealSize = subview.sizeThatFits(.unspecified)
    let availableWidth = ChatSystemEventCardLayoutMetrics.availableWidth(
      proposedWidth: bounds.width,
      idealWidth: idealSize.width
    )
    let cardWidth = ChatSystemEventCardLayoutMetrics.compactCardWidth(
      idealWidth: idealSize.width,
      availableWidth: availableWidth
    )
    let cardSize = subview.sizeThatFits(
      ProposedViewSize(width: cardWidth, height: bounds.height)
    )
    subview.place(
      at: CGPoint(
        x: (bounds.minX.isFinite ? bounds.minX : 0)
          + ChatSystemEventCardLayoutMetrics.centeredOriginX(
            containerWidth: availableWidth,
            cardWidth: cardWidth
          ),
        y: bounds.minY
      ),
      anchor: .topLeading,
      proposal: ProposedViewSize(width: cardWidth, height: cardSize.height)
    )
  }
}

/// ファネリーの Family Room を基準にしたシステムイベントカード。
@MainActor
public struct ChatSystemEventCard<Content: View>: View {
  private let theme: ChatRoomTheme
  private let content: Content

  /// システムイベントカードを作成する。
  public init(
    theme: ChatRoomTheme = .fanely,
    @ViewBuilder content: () -> Content
  ) {
    self.theme = theme
    self.content = content()
  }

  public var body: some View {
    CompactCenteredSystemEventCardLayout {
      cardSurface(
        content.multilineTextAlignment(.center)
      )
    }
  }

  private func cardSurface(_ content: some View) -> some View {
    content
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(theme.systemBubble, in: RoundedRectangle(cornerRadius: 18))
      .overlay {
        RoundedRectangle(cornerRadius: 18)
          .stroke(theme.systemBubbleBorder, lineWidth: 1)
      }
  }
}
