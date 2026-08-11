package jp.co.altive.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Keyboard
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.onClick
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
internal fun ChatImageComposer(
  draft: String,
  onDraftChange: (String) -> Unit,
  imageDrafts: List<ChatImageDraft>,
  configuration: ChatImageInputConfiguration,
  availableImageInputSources: Set<ChatImageInputSource>,
  isInlinePhotoLibraryPresented: Boolean,
  isInlinePhotoLibraryExpanded: Boolean,
  inputSurfaceHeight: Dp,
  isPreparingImages: Boolean,
  isPreparingCameraImage: Boolean,
  isSending: Boolean,
  strings: ChatRoomStrings,
  draftPolicy: ChatDraftPolicy,
  theme: ChatRoomTheme,
  onRequestCamera: () -> Unit,
  onRequestPhotoLibrary: () -> Unit,
  onToggleInlineExpansion: () -> Unit,
  onRemoveImage: (String) -> Unit,
  onSubmit: () -> Unit,
  imageContent: @Composable BoxScope.(ChatImage) -> Unit,
  inlinePhotoLibrary: @Composable BoxScope.() -> Unit,
) {
  val canSend = ChatComposerSendPolicy.canSend(
    draft = draft,
    imageCount = imageDrafts.size,
    maximumImageCount = configuration.maximumSelectionCount,
    isPreparingImages = isPreparingImages,
    isSending = isSending,
    draftPolicy = draftPolicy,
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
      Row(horizontalArrangement = Arrangement.spacedBy(1.dp)) {
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
            enabled = imageDrafts.size < configuration.maximumSelectionCount ||
              isInlinePhotoLibraryPresented,
            modifier = Modifier.size(44.dp)
              .semantics { contentDescription = strings.photoLibraryButtonLabel },
          ) {
            Icon(
              if (isInlinePhotoLibraryPresented) Icons.Default.Keyboard
              else Icons.Default.PhotoLibrary,
              contentDescription = null,
            )
          }
        }
      }

      BasicTextField(
        value = draft,
        onValueChange = { onDraftChange(draftPolicy.limited(it)) },
        modifier = Modifier.weight(1f)
          .background(theme.composerField, RoundedCornerShape(24.dp))
          .testTag("AltiveChatUI.Composer")
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

    if (isInlinePhotoLibraryPresented) {
      Column(Modifier.fillMaxWidth().height(inputSurfaceHeight)) {
        if (configuration.allowsInlineExpansion) {
          InlinePhotoLibraryHandle(
            isExpanded = isInlinePhotoLibraryExpanded,
            expandLabel = strings.expandPhotoLibraryLabel,
            collapseLabel = strings.collapsePhotoLibraryLabel,
            onToggle = onToggleInlineExpansion,
          )
        }
        Box(Modifier.fillMaxWidth().weight(1f), content = inlinePhotoLibrary)
      }
    }
  }
}

@Composable
private fun InlinePhotoLibraryHandle(
  isExpanded: Boolean,
  expandLabel: String,
  collapseLabel: String,
  onToggle: () -> Unit,
) {
  Box(
    Modifier.fillMaxWidth().height(28.dp)
      .pointerInput(isExpanded) {
        var dragDistance = 0f
        detectVerticalDragGestures(
          onDragStart = { dragDistance = 0f },
          onVerticalDrag = { _, amount -> dragDistance += amount },
          onDragEnd = {
            if ((dragDistance < -36f && !isExpanded) ||
              (dragDistance > 36f && isExpanded)
            ) {
              onToggle()
            }
          },
        )
      }
      .semantics {
        contentDescription = if (isExpanded) collapseLabel else expandLabel
        onClick {
          onToggle()
          true
        }
      },
    contentAlignment = Alignment.Center,
  ) {
    Box(
      Modifier.width(38.dp).height(5.dp)
        .background(MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .55f), CircleShape),
    )
  }
}
