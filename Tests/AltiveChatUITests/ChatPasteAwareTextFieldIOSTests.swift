#if os(iOS)
  import SwiftUI
  import Testing
  import UIKit

  @testable import AltiveChatUI

  @Suite("iOSメッセージ入力欄", .serialized)
  struct ChatPasteAwareTextFieldIOSTests {
    @Test("装飾された空の入力欄がSwiftUI更新後もfirst responderを維持する")
    @MainActor
    func emptyFieldCanBecomeFirstResponder() async throws {
      let textBox = ChatPasteAwareTextBox()
      let content = ChatPasteAwareTextFieldHarness(
        text: Binding(
          get: { textBox.text },
          set: { textBox.text = $0 }
        )
      )
      .frame(width: 280)
      let controller = UIHostingController(rootView: content)
      let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
      window.rootViewController = controller
      window.makeKeyAndVisible()
      controller.view.frame = window.bounds
      defer {
        window.isHidden = true
        window.rootViewController = nil
      }

      await settleLayout(of: controller.view)
      let textView = try #require(findTextView(in: controller.view))

      #expect(textView.bounds.height >= 22)
      #expect(textView.bounds.width >= 240)
      let textViewCenter = CGPoint(x: textView.bounds.midX, y: textView.bounds.midY)
      let hitPoint = textView.convert(textViewCenter, to: controller.view)
      let hitView = controller.view.hitTest(hitPoint, with: nil)
      #expect(hitView === textView || hitView?.isDescendant(of: textView) == true)
      #expect(textView.becomeFirstResponder())
      await settleLayout(of: controller.view)
      #expect(textView.isFirstResponder)

      textView.insertText("test")
      await settleLayout(of: controller.view)
      #expect(textBox.text == "test")
      #expect(textView.bounds.width >= 240)
      #expect(textView.isFirstResponder)
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
    private func findTextView(in view: UIView) -> UITextView? {
      if let textView = view as? UITextView { return textView }
      for subview in view.subviews {
        if let textView = findTextView(in: subview) { return textView }
      }
      return nil
    }
  }

  @MainActor
  private final class ChatPasteAwareTextBox {
    var text = ""
  }

  private struct ChatPasteAwareTextFieldHarness: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
      ChatPasteAwareTextField(
        text: $text,
        focus: $isFocused,
        placeholder: "Message",
        lineLimit: 1...5,
        draftPolicy: .unrestricted,
        isImagePasteEnabled: true,
        onPasteImages: { _ in }
      )
      .padding(.horizontal, 14)
      .padding(.vertical, 11)
      .background(.background, in: RoundedRectangle(cornerRadius: 22))
      .overlay {
        RoundedRectangle(cornerRadius: 22)
          .stroke(.separator, lineWidth: 0.5)
      }
      .accessibilityIdentifier("AltiveChatUI.Composer")
    }
  }
#endif
