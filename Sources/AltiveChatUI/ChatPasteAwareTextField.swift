import Foundation
import SwiftUI
import UniformTypeIdentifiers

func chatImageProviders(
  from providers: [NSItemProvider],
  isEnabled: Bool
) -> [NSItemProvider] {
  guard isEnabled else { return [] }
  return providers.filter {
    $0.hasItemConformingToTypeIdentifier(UTType.image.identifier)
  }
}

@MainActor
struct ChatPasteAwareTextField: View {
  @Binding var text: String
  let focus: FocusState<Bool>.Binding
  let placeholder: String
  let lineLimit: ClosedRange<Int>
  let draftPolicy: ChatDraftPolicy
  let isImagePasteEnabled: Bool
  let onPasteImages: (([NSItemProvider]) -> Void)?

  var body: some View {
    #if os(iOS)
      ZStack(alignment: .topLeading) {
        if text.isEmpty {
          Text(placeholder)
            .foregroundStyle(.tertiary)
            .allowsHitTesting(false)
        }

        ChatPasteAwareTextView(
          text: $text,
          focus: focus,
          lineLimit: lineLimit,
          draftPolicy: draftPolicy,
          isImagePasteEnabled: isImagePasteEnabled,
          onPasteImages: onPasteImages
        )
      }
      .frame(maxWidth: .infinity, minHeight: 22, alignment: .topLeading)
      .contentShape(Rectangle())
      .simultaneousGesture(
        TapGesture().onEnded {
          focus.wrappedValue = true
        }
      )
    #else
      TextField(placeholder, text: limitedText, axis: .vertical)
        .lineLimit(lineLimit)
        .focused(focus)
        .onPasteCommand(of: isImagePasteEnabled ? [.image] : []) { providers in
          let images = chatImageProviders(from: providers, isEnabled: isImagePasteEnabled)
          guard !images.isEmpty else { return }
          onPasteImages?(images)
        }
    #endif
  }

  private var limitedText: Binding<String> {
    Binding(
      get: { text },
      set: { text = draftPolicy.limited($0) }
    )
  }
}

#if os(iOS)
  import UIKit

  @MainActor
  private struct ChatPasteAwareTextView: UIViewRepresentable {
    @Binding var text: String
    let focus: FocusState<Bool>.Binding
    let lineLimit: ClosedRange<Int>
    let draftPolicy: ChatDraftPolicy
    let isImagePasteEnabled: Bool
    let onPasteImages: (([NSItemProvider]) -> Void)?

    func makeCoordinator() -> Coordinator {
      Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> ImagePasteTextView {
      let textView = ImagePasteTextView()
      textView.delegate = context.coordinator
      textView.backgroundColor = .clear
      textView.font = .preferredFont(forTextStyle: .body)
      textView.adjustsFontForContentSizeCategory = true
      textView.textContainerInset = .zero
      textView.textContainer.lineFragmentPadding = 0
      textView.isScrollEnabled = false
      textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
      updatePasteHandling(of: textView)
      return textView
    }

    func updateUIView(_ textView: ImagePasteTextView, context: Context) {
      context.coordinator.parent = self
      updatePasteHandling(of: textView)

      // 変換中の文字列は通常の再描画で上書きしない。ただし送信後などの
      // 明示的なクリアは未確定文字も破棄して入力欄へ即座に反映する。
      if textView.markedTextRange == nil || text.isEmpty, textView.text != text {
        let selection = textView.selectedRange
        textView.text = text
        textView.selectedRange = NSRange(
          location: min(selection.location, textView.text.utf16.count),
          length: 0
        )
      }

      if focus.wrappedValue {
        if !textView.isFirstResponder {
          textView.becomeFirstResponder()
        }
      } else if context.coordinator.lastRequestedFocus, textView.isFirstResponder {
        // UIKitのタップでfirst responderになった直後は、FocusStateの更新が
        // updateUIViewより遅れることがある。古いfalseで即座に解除せず、
        // SwiftUI側でtrueを観測した後のtrue→falseだけを解除として扱う。
        textView.resignFirstResponder()
      }
      context.coordinator.lastRequestedFocus = focus.wrappedValue
    }

    func sizeThatFits(
      _ proposal: ProposedViewSize,
      uiView: ImagePasteTextView,
      context _: Context
    ) -> CGSize? {
      guard let width = proposal.width else { return nil }
      let fittingSize = uiView.sizeThatFits(
        CGSize(width: width, height: .greatestFiniteMagnitude)
      )
      let lineHeight =
        uiView.font?.lineHeight
        ?? UIFont.preferredFont(forTextStyle: .body).lineHeight
      let minimumHeight = lineHeight * CGFloat(lineLimit.lowerBound)
      let maximumHeight = lineHeight * CGFloat(lineLimit.upperBound)
      let height = min(max(fittingSize.height, minimumHeight), maximumHeight)
      uiView.isScrollEnabled = fittingSize.height > maximumHeight
      return CGSize(width: width, height: ceil(height))
    }

    private func updatePasteHandling(of textView: ImagePasteTextView) {
      textView.isImagePasteEnabled = isImagePasteEnabled && onPasteImages != nil
      textView.onPasteImages = onPasteImages
      textView.pasteConfiguration =
        textView.isImagePasteEnabled
        ? UIPasteConfiguration(
          acceptableTypeIdentifiers: [UTType.image.identifier, UTType.text.identifier]
        ) : nil
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
      var parent: ChatPasteAwareTextView
      var lastRequestedFocus = false

      init(parent: ChatPasteAwareTextView) {
        self.parent = parent
      }

      func textViewDidBeginEditing(_: UITextView) {
        parent.focus.wrappedValue = true
      }

      func textViewDidEndEditing(_: UITextView) {
        parent.focus.wrappedValue = false
      }

      func textViewDidChange(_ textView: UITextView) {
        let currentText = textView.text ?? ""
        guard textView.markedTextRange == nil else {
          parent.text = currentText
          return
        }

        let limitedText = parent.draftPolicy.limited(currentText)
        if limitedText != currentText {
          let selection = textView.selectedRange
          textView.text = limitedText
          textView.selectedRange = NSRange(
            location: min(selection.location, limitedText.utf16.count),
            length: 0
          )
        }
        parent.text = limitedText
        textView.invalidateIntrinsicContentSize()
      }
    }
  }

  @MainActor
  private final class ImagePasteTextView: UITextView {
    var isImagePasteEnabled = false
    var onPasteImages: (([NSItemProvider]) -> Void)?

    override func paste(itemProviders: [NSItemProvider]) {
      let images = chatImageProviders(
        from: itemProviders,
        isEnabled: isImagePasteEnabled
      )
      guard !images.isEmpty, let onPasteImages else {
        super.paste(itemProviders: itemProviders)
        return
      }
      onPasteImages(images)
    }
  }
#endif
