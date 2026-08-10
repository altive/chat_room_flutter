import SwiftUI

/// アバター右下へ重ねる状態バッジ。
public struct ChatAvatarStatus {
  /// バッジ色。
  public let color: Color

  /// VoiceOverへ伝える状態名。
  public let accessibilityLabel: String

  /// 状態バッジを作成する。
  public init(color: Color, accessibilityLabel: String) {
    self.color = color
    self.accessibilityLabel = accessibilityLabel
  }
}

/// 画像取得方法をアプリ側へ残したまま、代替文字と状態表示を共通化するアバター。
@MainActor
public struct ChatAvatar<ImageContent: View>: View {
  private let displayName: String
  private let size: CGFloat
  private let accentColor: Color?
  private let status: ChatAvatarStatus?
  private let theme: ChatRoomTheme
  private let imageContent: ImageContent

  /// アバターを作成する。
  public init(
    displayName: String,
    size: CGFloat = 34,
    accentColor: Color? = nil,
    status: ChatAvatarStatus? = nil,
    theme: ChatRoomTheme = .fanely,
    @ViewBuilder image: () -> ImageContent
  ) {
    self.displayName = displayName
    self.size = size
    self.accentColor = accentColor
    self.status = status
    self.theme = theme
    self.imageContent = image()
  }

  public var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ZStack {
        Circle()
          .fill(accentColor?.opacity(0.2) ?? theme.avatarFallbackBackground)
        Text(initial)
          .font(.caption.weight(.semibold))
          .foregroundStyle(theme.avatarFallbackForeground)
        imageContent
      }
      .frame(width: size, height: size)
      .clipShape(Circle())
      .overlay {
        if let accentColor {
          Circle().stroke(accentColor.opacity(0.45), lineWidth: 1)
        }
      }

      if let status {
        Circle()
          .fill(status.color)
          .frame(width: max(8, size * 0.27), height: max(8, size * 0.27))
          .overlay {
            Circle().stroke(.background, lineWidth: 2)
          }
          .accessibilityLabel(status.accessibilityLabel)
      }
    }
    .accessibilityElement(children: status == nil ? .ignore : .contain)
    .accessibilityLabel(displayName)
  }

  private var initial: String {
    displayName.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? "?"
  }
}

/// `AsyncImage`を使い、失敗時は背面の代替文字を見せる画像部品。
@MainActor
public struct ChatRemoteAvatarImage: View {
  private let url: URL?

  /// 画像URLを指定して作成する。
  public init(url: URL?) {
    self.url = url
  }

  public var body: some View {
    if let url {
      AsyncImage(url: url) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
        case .empty, .failure:
          Color.clear
        @unknown default:
          Color.clear
        }
      }
    }
  }
}
