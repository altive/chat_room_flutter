import SwiftUI

/// タイムラインと入力面を共通の配置で合成するチャットRoomシェル。
@MainActor
public struct ChatRoomLayout<Timeline: View, Composer: View>: View {
  private let timeline: Timeline
  private let composer: Composer
  private let composerSpacing: CGFloat?

  /// チャットRoomシェルを作成する。
  public init(
    composerSpacing: CGFloat? = nil,
    @ViewBuilder timeline: () -> Timeline,
    @ViewBuilder composer: () -> Composer
  ) {
    self.timeline = timeline()
    self.composer = composer()
    self.composerSpacing = composerSpacing
  }

  public var body: some View {
    timeline
      .scrollDismissesKeyboard(.interactively)
      .safeAreaInset(edge: .bottom, spacing: composerSpacing) {
        composer
      }
  }
}
