import SwiftUI

/// 送信中と失敗時の再送導線を共通表示する部品。
@MainActor
public struct ChatDeliveryIndicator: View {
  private let state: ChatMessageDeliveryState?
  private let sendingLabel: String
  private let retryLabel: String
  private let sendingAccessibilityIdentifier: String?
  private let retryAccessibilityIdentifier: String?
  private let reservesSpace: Bool
  private let controlSize: ControlSize
  private let theme: ChatRoomTheme
  private let onRetry: (() -> Void)?

  /// 送信状態表示を作成する。
  public init(
    state: ChatMessageDeliveryState?,
    sendingLabel: String,
    retryLabel: String,
    sendingAccessibilityIdentifier: String? = nil,
    retryAccessibilityIdentifier: String? = nil,
    reservesSpace: Bool = false,
    controlSize: ControlSize = .small,
    theme: ChatRoomTheme = .fanely,
    onRetry: (() -> Void)? = nil
  ) {
    self.state = state
    self.sendingLabel = sendingLabel
    self.retryLabel = retryLabel
    self.sendingAccessibilityIdentifier = sendingAccessibilityIdentifier
    self.retryAccessibilityIdentifier = retryAccessibilityIdentifier
    self.reservesSpace = reservesSpace
    self.controlSize = controlSize
    self.theme = theme
    self.onRetry = onRetry
  }

  public var body: some View {
    Group {
      switch state {
      case .sending:
        ProgressView()
          .controlSize(controlSize)
          .accessibilityLabel(sendingLabel)
          .applyAccessibilityIdentifier(sendingAccessibilityIdentifier)
      case .failed:
        if let onRetry {
          Button(action: onRetry) {
            failureImage
          }
          .buttonStyle(.plain)
          .accessibilityLabel(retryLabel)
          .applyAccessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
          failureImage
            .accessibilityLabel(retryLabel)
            .applyAccessibilityIdentifier(retryAccessibilityIdentifier)
        }
      case .sent, nil:
        if reservesSpace {
          Color.clear
        } else {
          EmptyView()
        }
      }
    }
    .frame(width: reservesSpace ? 20 : nil, height: reservesSpace ? 20 : nil)
  }

  private var failureImage: some View {
    Image(systemName: "exclamationmark.circle.fill")
      .foregroundStyle(theme.deliveryFailure)
  }
}

extension View {
  @ViewBuilder
  func applyAccessibilityIdentifier(_ identifier: String?) -> some View {
    if let identifier {
      accessibilityIdentifier(identifier)
    } else {
      self
    }
  }
}
