import SwiftUI

/// 長押し操作とコンパクト環境でも維持する操作popoverを組み合わせる部品。
@MainActor
public struct ChatInteractionPopover<Content: View, Actions: View>: View {
  @Binding private var isPresented: Bool

  private let isEnabled: Bool
  private let minimumDuration: Double
  private let content: Content
  private let actions: Actions

  /// 長押し対象と表示する操作を作成する。
  public init(
    isPresented: Binding<Bool>,
    isEnabled: Bool = true,
    minimumDuration: Double = 0.4,
    @ViewBuilder content: () -> Content,
    @ViewBuilder actions: () -> Actions
  ) {
    _isPresented = isPresented
    self.isEnabled = isEnabled
    self.minimumDuration = minimumDuration
    self.content = content()
    self.actions = actions()
  }

  public var body: some View {
    content
      .contentShape(.rect)
      .simultaneousGesture(
        LongPressGesture(minimumDuration: minimumDuration)
          .onEnded { didComplete in
            guard didComplete, isEnabled else { return }
            withAnimation(.snappy(duration: 0.18)) {
              isPresented = true
            }
          }
      )
      .popover(
        isPresented: $isPresented,
        attachmentAnchor: .rect(.bounds),
        arrowEdge: .bottom
      ) {
        actions
          .presentationCompactAdaptation(.popover)
          .presentationBackground(.ultraThinMaterial)
          .presentationCornerRadius(28)
      }
  }
}
