package jp.co.altive.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp

internal fun shouldShowChatComposerSourceButtons(
  isFocused: Boolean,
  isExpandedWhileFocused: Boolean,
): Boolean = !isFocused || isExpandedWhileFocused

@Composable
fun ChatImageComposer(
  draft: String,
  onDraftChange: (String) -> Unit,
  imageDrafts: List<ChatImageDraft>,
  configuration: ChatImageInputConfiguration,
  availableImageInputSources: Set<ChatImageInputSource>,
  isPreparingImages: Boolean,
  isPreparingCameraImage: Boolean,
  isSending: Boolean,
  strings: ChatRoomStrings,
  draftPolicy: ChatDraftPolicy,
  theme: ChatRoomTheme,
  onRequestCamera: () -> Unit,
  onRequestPhotoLibrary: () -> Unit,
  onRemoveImage: (String) -> Unit,
  onSubmit: () -> Unit,
  imageContent: @Composable BoxScope.(ChatImage) -> Unit,
  additionalSourceContent: (@Composable () -> Unit)? = null,
) {
  val canSend = ChatComposerSendPolicy.canSend(
    draft = draft,
    imageCount = imageDrafts.size,
    maximumImageCount = configuration.maximumSelectionCount,
    isPreparingImages = isPreparingImages,
    isSending = isSending,
    draftPolicy = draftPolicy,
  )
  var isComposerFocused by rememberSaveable { mutableStateOf(false) }
  var isSourceButtonsExpandedWhileFocused by rememberSaveable { mutableStateOf(false) }
  val hasSourceButtons = additionalSourceContent != null || availableImageInputSources.isNotEmpty()
  val showsSourceButtons = shouldShowChatComposerSourceButtons(
    isFocused = isComposerFocused,
    isExpandedWhileFocused = isSourceButtonsExpandedWhileFocused,
  )

  Column(
    Modifier.fillMaxWidth()
      .background(MaterialTheme.colorScheme.surface)
      .padding(horizontal = 16.dp, vertical = 10.dp),
    horizontalAlignment = Alignment.End,
    verticalArrangement = Arrangement.spacedBy(7.dp),
  ) {
    if (imageDrafts.isNotEmpty() || isPreparingImages) {
      Row(
        Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(top = 6.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
      ) {
        imageDrafts.forEach { draftImage ->
          Box(Modifier.size(76.dp)) {
            ChatImageTile(
              image = draftImage.previewImage,
              imageLabel = strings.imageLabel,
              modifier = Modifier.fillMaxSize().clip(RoundedCornerShape(10.dp)),
              imageContent = imageContent,
            )
            IconButton(
              onClick = { onRemoveImage(draftImage.id) },
              modifier = Modifier.align(Alignment.TopEnd).size(32.dp)
                .semantics { contentDescription = strings.removeImageButtonLabel },
            ) {
              Icon(Icons.Default.Close, contentDescription = null)
            }
          }
        }
        if (isPreparingImages) {
          Box(
            Modifier.size(76.dp)
              .background(MaterialTheme.colorScheme.surfaceContainerHighest, RoundedCornerShape(10.dp)),
            contentAlignment = Alignment.Center,
          ) {
            CircularProgressIndicator(Modifier.size(22.dp))
          }
        }
      }
    }

    Row(
      verticalAlignment = Alignment.Bottom,
      horizontalArrangement = Arrangement.spacedBy(7.dp),
    ) {
      if (hasSourceButtons) {
        if (showsSourceButtons) {
          Row(horizontalArrangement = Arrangement.spacedBy(1.dp)) {
            additionalSourceContent?.invoke()
            if (ChatImageInputSource.Camera in availableImageInputSources) {
              IconButton(
                onClick = onRequestCamera,
                enabled = imageDrafts.size < configuration.maximumSelectionCount &&
                  !isPreparingCameraImage,
                modifier = Modifier.size(44.dp)
                  .semantics { contentDescription = strings.cameraButtonLabel },
              ) {
                if (isPreparingCameraImage) CircularProgressIndicator(Modifier.size(18.dp))
                else Icon(Icons.Default.CameraAlt, contentDescription = null)
              }
            }
            if (ChatImageInputSource.PhotoLibrary in availableImageInputSources) {
              IconButton(
                onClick = onRequestPhotoLibrary,
                enabled = imageDrafts.size < configuration.maximumSelectionCount,
                modifier = Modifier.size(44.dp)
                  .semantics { contentDescription = strings.photoLibraryButtonLabel },
              ) {
                Icon(Icons.Default.PhotoLibrary, contentDescription = null)
              }
            }
          }
        } else {
          IconButton(
            onClick = { isSourceButtonsExpandedWhileFocused = true },
            modifier = Modifier.size(44.dp)
              .testTag("AltiveChatUI.ExpandSourceButtons")
              .semantics { contentDescription = strings.expandSourceButtonsLabel },
          ) {
            Icon(Icons.Default.KeyboardArrowRight, contentDescription = null)
          }
        }
      }

      BasicTextField(
        value = draft,
        onValueChange = { onDraftChange(draftPolicy.limited(it)) },
        modifier = Modifier.weight(1f)
          .background(theme.composerField, RoundedCornerShape(24.dp))
          .testTag("AltiveChatUI.Composer")
          .onFocusChanged { focusState ->
            val gainedFocus = focusState.isFocused && !isComposerFocused
            isComposerFocused = focusState.isFocused
            if (gainedFocus) {
              isSourceButtonsExpandedWhileFocused = false
            }
          }
          .padding(horizontal = 14.dp, vertical = 12.dp),
        textStyle = MaterialTheme.typography.bodyLarge.copy(
          color = MaterialTheme.colorScheme.onSurface,
        ),
        cursorBrush = SolidColor(MaterialTheme.colorScheme.primary),
        decorationBox = { inner ->
          if (draft.isEmpty()) {
            Text(strings.messagePlaceholder, color = MaterialTheme.colorScheme.onSurfaceVariant)
          }
          inner()
        },
      )

      IconButton(
        onClick = onSubmit,
        enabled = canSend,
        modifier = Modifier.size(42.dp)
          .testTag("AltiveChatUI.SendButton")
          .clip(CircleShape)
          .background(theme.sendButtonBackground)
          .semantics { contentDescription = strings.sendButtonLabel },
      ) {
        if (isPreparingImages || isSending) {
          CircularProgressIndicator(Modifier.size(20.dp), color = theme.sendButtonForeground)
        } else {
          Icon(
            Icons.AutoMirrored.Filled.Send,
            contentDescription = null,
            tint = theme.sendButtonForeground,
          )
        }
      }
    }

    if (draftPolicy.shouldShowLength(draft) && draftPolicy.maximumLength != null) {
      Text(
        "${draftPolicy.length(draft)}/${draftPolicy.maximumLength}",
        style = MaterialTheme.typography.labelSmall,
      )
    }

  }
}
