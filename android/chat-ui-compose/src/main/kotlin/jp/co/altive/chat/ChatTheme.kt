package jp.co.altive.chat

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color

@Immutable
data class ChatRoomTheme(
  val background: Color = Color.Transparent,
  val outgoingBubble: Color,
  val outgoingText: Color,
  val incomingBubble: Color,
  val incomingText: Color,
  val incomingBubbleBorder: Color,
  val systemBubble: Color,
  val systemBubbleBorder: Color,
  val composerField: Color,
  val composerFieldBorder: Color,
  val sendButtonBackground: Color,
  val sendButtonForeground: Color,
  val reactionChipBackground: Color,
  val reactionChipBorder: Color,
  val reactionPickerItemBackground: Color,
  val avatarFallbackBackground: Color,
  val avatarFallbackForeground: Color,
  val deliveryFailure: Color,
  val timelineBoundaryForeground: Color,
  val celebrationCardBackgroundStart: Color = Color(0xFFFFF3E0),
  val celebrationCardBackgroundEnd: Color = Color(0xFFFCE4EC),
  val celebrationCardBorder: Color = Color(0x66F57C00),
  val celebrationCardForeground: Color = Color(0xFF241A14),
  val celebrationCardAccent: Color = Color(0xFFF57C00),
) {
  companion object {
    @Composable
    fun fanely(): ChatRoomTheme {
      val colors = MaterialTheme.colorScheme
      return ChatRoomTheme(
        outgoingBubble = colors.primary,
        outgoingText = colors.onPrimary,
        incomingBubble = colors.surfaceContainer,
        incomingText = colors.onSurface,
        incomingBubbleBorder = colors.outlineVariant,
        systemBubble = colors.surfaceContainer,
        systemBubbleBorder = colors.outlineVariant,
        composerField = colors.surfaceContainerHigh,
        composerFieldBorder = colors.outlineVariant,
        sendButtonBackground = colors.primary,
        sendButtonForeground = colors.onPrimary,
        reactionChipBackground = colors.surfaceContainerHighest,
        reactionChipBorder = colors.outlineVariant,
        reactionPickerItemBackground = colors.onSurface.copy(alpha = .06f),
        avatarFallbackBackground = colors.surfaceContainerHighest,
        avatarFallbackForeground = colors.onSurfaceVariant,
        deliveryFailure = colors.error,
        timelineBoundaryForeground = colors.onSurfaceVariant,
        celebrationCardBackgroundStart = colors.tertiaryContainer.copy(alpha = .62f),
        celebrationCardBackgroundEnd = colors.secondaryContainer.copy(alpha = .5f),
        celebrationCardBorder = colors.tertiary.copy(alpha = .42f),
        celebrationCardForeground = colors.onTertiaryContainer,
        celebrationCardAccent = colors.tertiary,
      )
    }

    @Composable fun standard(): ChatRoomTheme = fanely()
  }
}
