import Foundation

/// キーボードとスタンプなどの入力面を切り替える際の共通レイアウト計算。
public enum ChatInputSurfaceGeometry {
  /// ウインドウとキーボードの重なりから、安全領域を除いた入力面の高さを返す。
  public static func keyboardContentHeight(
    keyboardEndFrame: CGRect,
    windowBounds: CGRect,
    bottomSafeAreaInset: CGFloat
  ) -> CGFloat {
    let overlapHeight = windowBounds.intersection(keyboardEndFrame).height
    return max(0, overlapHeight - bottomSafeAreaInset)
  }

  /// キーボードと同じ位置へ表示する入力面から、タブバーなどの高さを除く。
  public static func inputSurfaceHeight(
    keyboardContentHeight: CGFloat,
    bottomChromeHeight: CGFloat
  ) -> CGFloat {
    max(0, keyboardContentHeight - bottomChromeHeight)
  }

}
