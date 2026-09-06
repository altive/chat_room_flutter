package jp.co.altive.chat

import android.content.ClipboardManager
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.Dp
import java.text.DateFormat
import java.util.Date
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch

private val LocalChatComposerFocusRequester = compositionLocalOf<FocusRequester?> { null }

@Immutable
data class ChatRoomStrings(
  val emptyMessage: String,
  val messagePlaceholder: String,
  val sendButtonLabel: String,
  val sendingLabel: String,
  val failedLabel: String,
  val unknownSender: String,
  val cameraButtonLabel: String = "Camera",
  val photoLibraryButtonLabel: String = "Photo library",
  val expandSourceButtonsLabel: String = "Show attachment buttons",
  val removeImageButtonLabel: String = "Remove image",
  val imageLabel: String = "Image",
  val phoneActionTitle: String = "Contact phone number",
  val phoneActionMessage: String = "Choose an action",
  val callButtonLabel: String = "Call",
  val smsButtonLabel: String = "SMS",
  val cancelButtonLabel: String = "Cancel",
  val latestButtonLabel: String = "Latest messages",
  val stickerLabel: String = "Sticker",
  val stickerLoadingFailedLabel: String = "Failed to load sticker",
  val linkPreviewLabel: String = "Link preview",
  val linkPreviewLoadingLabel: String = "Loading link preview",
  val replyActionLabel: String = "Reply",
  val cancelReplyLabel: String = "Cancel reply",
  val replyToLabel: String = "Replying to",
  val replyUnavailableLabel: String = "This message is unavailable",
  val fileButtonLabel: String = "File",
  val clipboardButtonLabel: String = "Clipboard",
  val imageSourceMenuButtonLabel: String = "Choose image source",
) {
  companion object {
    @Composable fun localized(): ChatRoomStrings {
      return ChatRoomStrings(
        stringResource(R.string.altive_chat_empty),
        stringResource(R.string.altive_chat_placeholder),
        stringResource(R.string.altive_chat_send),
        stringResource(R.string.altive_chat_sending),
        stringResource(R.string.altive_chat_failed),
        stringResource(R.string.altive_chat_unknown_sender),
        stringResource(R.string.altive_chat_camera),
        stringResource(R.string.altive_chat_photo_library),
        stringResource(R.string.altive_chat_expand_source_buttons),
        stringResource(R.string.altive_chat_remove_image),
        stringResource(R.string.altive_chat_image),
        stringResource(R.string.altive_chat_phone_action_title),
        stringResource(R.string.altive_chat_phone_action_message),
        stringResource(R.string.altive_chat_call),
        stringResource(R.string.altive_chat_sms),
        stringResource(R.string.altive_chat_cancel),
        stringResource(R.string.altive_chat_latest),
        stringResource(R.string.altive_chat_sticker),
        stringResource(R.string.altive_chat_sticker_loading_failed),
        stringResource(R.string.altive_chat_link_preview),
        stringResource(R.string.altive_chat_link_preview_loading),
        stringResource(R.string.altive_chat_reply),
        stringResource(R.string.altive_chat_cancel_reply),
        stringResource(R.string.altive_chat_reply_to),
        stringResource(R.string.altive_chat_reply_unavailable),
        stringResource(R.string.altive_chat_file),
        stringResource(R.string.altive_chat_clipboard),
        stringResource(R.string.altive_chat_image_sources),
      )
    }
  }
}

@Composable
fun AltiveChatRoom(
  messages: List<ChatMessage>,
  currentUserId: String,
  draft: String,
  onDraftChange: (String) -> Unit,
  modifier: Modifier = Modifier,
  theme: ChatRoomTheme = ChatRoomTheme.standard(),
  strings: ChatRoomStrings = ChatRoomStrings.localized(),
  showsSenderName: Boolean = false,
  draftPolicy: ChatDraftPolicy = ChatDraftPolicy.Unrestricted,
  singleImageLayout: ChatSingleImageLayout = ChatSingleImageLayout.AdaptiveBounded(),
  multipleImageLayout: ChatMultipleImageLayout = ChatMultipleImageLayout.Mosaic,
  followLatestConfiguration: ChatTimelineFollowLatestConfiguration =
    ChatTimelineFollowLatestConfiguration(
      mode = ChatTimelineFollowLatestMode.WhenNearLatestOrForced,
    ),
  showsScrollToLatestButton: Boolean = true,
  onImageTap: ((messageId: String, imageIndex: Int) -> Unit)? = null,
  onRetry: ((String) -> Unit)? = null,
  imageContent: (@Composable BoxScope.(ChatImage) -> Unit)? = null,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)? = null,
  stickerImageLoader: ChatStickerImageLoader? = null,
  linkPreviewResolver: (suspend (String) -> ChatLinkPreview?)? = null,
  linkPreviewImageContent: (@Composable BoxScope.(ChatLinkPreviewImage) -> Unit)? = null,
  onLinkPreviewTap: ((String) -> Unit)? = null,
  replyConfiguration: ChatReplyConfiguration? = null,
  onSubmit: ((ChatComposerSubmission) -> Unit)? = null,
  onSend: (String) -> Unit,
) {
  val timelineState = rememberChatTimelineState()
  val coroutineScope = rememberCoroutineScope()
  val shouldShowLatestButton by remember(showsScrollToLatestButton) {
    derivedStateOf {
      showsScrollToLatestButton && timelineState.hasPositioned &&
        timelineState.listState.canScrollForward
    }
  }
  val draftLinkPreviewState = rememberChatDraftLinkPreviewState(draft, linkPreviewResolver)
  var selectedReply by remember { mutableStateOf<ChatReplyReference?>(null) }
  val replyFocusRequester = remember { FocusRequester() }
  Column(modifier.background(theme.background).imePadding()) {
    Box(Modifier.weight(1f).fillMaxWidth()) {
      ChatTimeline(
        timelineId = Unit,
        itemIds = messages.map(ChatMessage::id),
        itemIndex = { id -> messages.indexOfFirst { it.id == id }.takeIf { it >= 0 } },
        latestItemIndex = messages.lastIndex.coerceAtLeast(0),
        isReadyForInitialPositioning = true,
        followLatestTrigger = messages.lastOrNull()?.id,
        followLatestConfiguration = followLatestConfiguration,
        forceFollowLatest = messages.lastOrNull()?.isSentBy(currentUserId) == true,
        state = timelineState,
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
      ) {
        if (messages.isEmpty()) {
          item { Text(strings.emptyMessage, Modifier.fillMaxWidth().padding(vertical = 48.dp), textAlign = TextAlign.Center) }
        } else {
          items(messages, key = { it.id }) { message ->
            ReplyInteraction(
              message = message,
              configuration = replyConfiguration.takeIf { onSubmit != null },
              strings = strings,
              onSelect = {
                selectedReply = it
                replyFocusRequester.requestFocus()
              },
            ) {
              ChatMessageRow(
                message = message,
                currentUserId = currentUserId,
                theme = theme,
                strings = strings,
                showsSenderName = showsSenderName,
                singleImageLayout = singleImageLayout,
                multipleImageLayout = multipleImageLayout,
                onRetry = onRetry?.let { { it(message.id) } },
                onImageTap = onImageTap,
                imageContent = imageContent,
                transitioningImageContent = transitioningImageContent,
                stickerImageLoader = stickerImageLoader,
                linkPreviewImageContent = linkPreviewImageContent,
                onLinkPreviewTap = onLinkPreviewTap,
                onReplyReferenceTap = replyConfiguration?.onReferenceTap,
              )
            }
          }
        }
      }
      if (shouldShowLatestButton) {
        SmallFloatingActionButton(
          onClick = { coroutineScope.launch { timelineState.scrollToLatest() } },
          modifier = Modifier.align(Alignment.BottomEnd).padding(16.dp)
            .testTag("AltiveChatUI.ScrollToLatestButton")
            .semantics { contentDescription = strings.latestButtonLabel },
        ) { Text("↓") }
      }
    }
    selectedReply?.let { replyTo ->
      ChatReplyComposerBar(
        reference = replyTo,
        onCancel = { selectedReply = null },
        strings = strings,
        stickerImageLoader = stickerImageLoader,
      )
    }
    CompositionLocalProvider(LocalChatComposerFocusRequester provides replyFocusRequester) {
      ChatComposer(
        draft = draft,
        onDraftChange = onDraftChange,
        placeholder = strings.messagePlaceholder,
        sendButtonLabel = strings.sendButtonLabel,
        draftPolicy = draftPolicy,
        theme = theme,
        attachmentPreview = {
          ChatDraftLinkPreview(
            state = draftLinkPreviewState,
            strings = strings,
            imageContent = linkPreviewImageContent,
            onOpenLink = onLinkPreviewTap,
          )
        },
        onSend = { text ->
          val submission = ChatComposerSubmission.create(
            draft = text,
            images = emptyList(),
            policy = draftPolicy,
            linkPreview = draftLinkPreviewState.previewForSubmission(text),
            replyTo = selectedReply,
          )
          if (submission != null && onSubmit != null) onSubmit(submission) else onSend(text)
          onDraftChange("")
          selectedReply = null
        },
      )
    }
  }
}

@Composable
fun AltiveChatRoom(
  messages: List<ChatMessage>,
  currentUserId: String,
  draft: String,
  onDraftChange: (String) -> Unit,
  imageDrafts: List<ChatImageDraft>,
  onImageDraftsChange: (List<ChatImageDraft>) -> Unit,
  resolvePhotoLibraryUri: suspend (String) -> ChatImageDraft,
  modifier: Modifier = Modifier,
  imageInputConfiguration: ChatImageInputConfiguration = ChatImageInputConfiguration(),
  availableImageInputSources: Set<ChatImageInputSource> = setOf(
    ChatImageInputSource.Camera,
    ChatImageInputSource.PhotoLibrary,
    ChatImageInputSource.File,
    ChatImageInputSource.Clipboard,
  ),
  isPreparingCameraImage: Boolean = false,
  isSending: Boolean = false,
  theme: ChatRoomTheme = ChatRoomTheme.standard(),
  strings: ChatRoomStrings = ChatRoomStrings.localized(),
  showsSenderName: Boolean = false,
  draftPolicy: ChatDraftPolicy = ChatDraftPolicy.Unrestricted,
  onRequestCamera: (() -> Unit)? = null,
  onImagePreparationFailure: ((Throwable) -> Unit)? = null,
  onImageTap: ((messageId: String, imageIndex: Int) -> Unit)? = null,
  singleImageLayout: ChatSingleImageLayout = ChatSingleImageLayout.AdaptiveBounded(),
  multipleImageLayout: ChatMultipleImageLayout = ChatMultipleImageLayout.Mosaic,
  followLatestConfiguration: ChatTimelineFollowLatestConfiguration =
    ChatTimelineFollowLatestConfiguration(
      mode = ChatTimelineFollowLatestMode.WhenNearLatestOrForced,
    ),
  showsScrollToLatestButton: Boolean = true,
  onRetry: ((String) -> Unit)? = null,
  focusRequester: FocusRequester = remember { FocusRequester() },
  imageContent: (@Composable BoxScope.(ChatImage) -> Unit)? = null,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)? = null,
  stickerImageLoader: ChatStickerImageLoader? = null,
  linkPreviewResolver: (suspend (String) -> ChatLinkPreview?)? = null,
  linkPreviewImageContent: (@Composable BoxScope.(ChatLinkPreviewImage) -> Unit)? = null,
  onLinkPreviewTap: ((String) -> Unit)? = null,
  replyConfiguration: ChatReplyConfiguration? = null,
  onSubmit: (ChatComposerSubmission) -> Unit,
) {
  val coroutineScope = rememberCoroutineScope()
  val context = LocalContext.current
  val focusManager = LocalFocusManager.current
  var photoUris by rememberSaveable { mutableStateOf(arrayListOf<String>()) }
  var photoDraftIdValues by rememberSaveable { mutableStateOf(arrayListOf<String>()) }
  var resolvingUris by remember { mutableStateOf(emptySet<String>()) }
  val timelineState = rememberChatTimelineState()
  val shouldShowLatestButton by remember(showsScrollToLatestButton) {
    derivedStateOf {
      showsScrollToLatestButton && timelineState.hasPositioned &&
        timelineState.listState.canScrollForward
    }
  }
  val draftLinkPreviewState = rememberChatDraftLinkPreviewState(
    draft = if (imageDrafts.isEmpty()) draft else "",
    resolver = linkPreviewResolver,
  )
  var selectedReply by remember { mutableStateOf<ChatReplyReference?>(null) }

  val latestImageDrafts by rememberUpdatedState(imageDrafts)
  val latestOnImageDraftsChange by rememberUpdatedState(onImageDraftsChange)
  val latestResolver by rememberUpdatedState(resolvePhotoLibraryUri)
  val latestFailureHandler by rememberUpdatedState(onImagePreparationFailure)
  val photoDraftIds = photoUris.zip(photoDraftIdValues).toMap()
  val mappedPhotoDraftIds = photoDraftIds.values.toSet()
  val cameraDraftCount = imageDrafts.count { it.id !in mappedPhotoDraftIds }
  val remainingCapacity = (
    imageInputConfiguration.maximumSelectionCount - imageDrafts.size - resolvingUris.size
  ).coerceAtLeast(0)
  val platformPickerMaximum = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    MediaStore.getPickImagesMaxLimit()
  } else {
    imageInputConfiguration.maximumSelectionCount
  }
  val multiplePickerMaximum = multiplePhotoPickerLimit(remainingCapacity, platformPickerMaximum)

  fun updatePhotoDraftIds(values: Map<String, String>) {
    photoUris = ArrayList(values.keys)
    photoDraftIdValues = ArrayList(values.values)
  }

  val resolveUris: (List<Uri>) -> Unit = { selectedUris ->
    val knownUris = photoUris.toSet() + resolvingUris
    val acceptedUris = selectedUris.map(Uri::toString)
      .filterNot { it in knownUris }
      .take(remainingCapacity)
    if (acceptedUris.isNotEmpty()) {
      resolvingUris = resolvingUris + acceptedUris
      coroutineScope.launch {
        val resolved = mutableListOf<Pair<String, ChatImageDraft>>()
        try {
          for (uri in acceptedUris) {
            try {
              val resolvedDraft = latestResolver(uri)
              resolved += uri to resolvedDraft
            } catch (cancellation: CancellationException) {
              throw cancellation
            } catch (throwable: Throwable) {
              latestFailureHandler?.invoke(throwable)
            }
          }

          val mergedDrafts = (latestImageDrafts + resolved.map { it.second })
            .distinctBy(ChatImageDraft::id)
            .take(imageInputConfiguration.maximumSelectionCount)
          val mergedIDs = mergedDrafts.map(ChatImageDraft::id).toSet()
          latestOnImageDraftsChange(mergedDrafts)

          val updatedMappings = photoUris.zip(photoDraftIdValues).toMap().toMutableMap()
          for ((uri, resolvedDraft) in resolved) {
            if (resolvedDraft.id in mergedIDs) updatedMappings[uri] = resolvedDraft.id
          }
          updatePhotoDraftIds(updatedMappings)
        } finally {
          resolvingUris = resolvingUris - acceptedUris.toSet()
        }
      }
    }
  }

  val singlePhotoPicker = rememberLauncherForActivityResult(
    contract = ActivityResultContracts.PickVisualMedia(),
  ) { uri ->
    if (uri != null) resolveUris(listOf(uri))
  }
  val multiplePhotoPicker = rememberLauncherForActivityResult(
    contract = ActivityResultContracts.PickMultipleVisualMedia(multiplePickerMaximum),
  ) { uris ->
    resolveUris(uris)
  }
  val singleFilePicker = rememberLauncherForActivityResult(
    contract = ActivityResultContracts.OpenDocument(),
  ) { uri ->
    if (uri != null) resolveUris(listOf(uri))
  }
  val multipleFilePicker = rememberLauncherForActivityResult(
    contract = ActivityResultContracts.OpenMultipleDocuments(),
  ) { uris ->
    resolveUris(uris)
  }

  fun launchClassicPhotoPicker() {
    val request = PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
    if (remainingCapacity <= 1) singlePhotoPicker.launch(request)
    else multiplePhotoPicker.launch(request)
  }

  fun launchFilePicker() {
    val mimeTypes = arrayOf("image/*")
    if (remainingCapacity <= 1) singleFilePicker.launch(mimeTypes)
    else multipleFilePicker.launch(mimeTypes)
  }

  val effectiveImageInputSources = availableImageInputSources.filterTo(mutableSetOf()) { source ->
    source != ChatImageInputSource.Camera || onRequestCamera != null
  }

  LaunchedEffect(imageDrafts.map(ChatImageDraft::id)) {
    val currentIDs = imageDrafts.map(ChatImageDraft::id).toSet()
    val currentMappings = photoUris.zip(photoDraftIdValues).toMap()
    val staleUris = currentMappings.filterValues { it !in currentIDs }.keys
    if (staleUris.isNotEmpty()) {
      updatePhotoDraftIds(currentMappings.filterKeys { it !in staleUris })
    }
  }

  Box(modifier) {
    Column(Modifier.background(theme.background).imePadding()) {
      Box(Modifier.weight(1f).fillMaxWidth()) {
        ChatTimeline(
          timelineId = Unit,
          itemIds = messages.map(ChatMessage::id),
          itemIndex = { id -> messages.indexOfFirst { it.id == id }.takeIf { it >= 0 } },
          latestItemIndex = messages.lastIndex.coerceAtLeast(0),
          isReadyForInitialPositioning = true,
          followLatestTrigger = messages.lastOrNull()?.id,
          followLatestConfiguration = followLatestConfiguration,
          forceFollowLatest = messages.lastOrNull()?.isSentBy(currentUserId) == true,
          state = timelineState,
          contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
          verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
          if (messages.isEmpty()) {
            item {
              Text(
                strings.emptyMessage,
                Modifier.fillMaxWidth().padding(vertical = 48.dp),
                textAlign = TextAlign.Center,
              )
            }
          } else {
            items(messages, key = { it.id }) { message ->
              ReplyInteraction(
                message = message,
                configuration = replyConfiguration,
                strings = strings,
                onSelect = {
                  selectedReply = it
                  focusRequester.requestFocus()
                },
              ) {
                ChatMessageRow(
                  message = message,
                  currentUserId = currentUserId,
                  theme = theme,
                  strings = strings,
                  showsSenderName = showsSenderName,
                  singleImageLayout = singleImageLayout,
                  multipleImageLayout = multipleImageLayout,
                  onRetry = onRetry?.let { { it(message.id) } },
                  onImageTap = onImageTap,
                  imageContent = imageContent,
                  transitioningImageContent = transitioningImageContent,
                  stickerImageLoader = stickerImageLoader,
                  linkPreviewImageContent = linkPreviewImageContent,
                  onLinkPreviewTap = onLinkPreviewTap,
                  onReplyReferenceTap = replyConfiguration?.onReferenceTap,
                )
              }
            }
          }
        }
        if (shouldShowLatestButton) {
          SmallFloatingActionButton(
            onClick = { coroutineScope.launch { timelineState.scrollToLatest() } },
            modifier = Modifier.align(Alignment.BottomEnd).padding(16.dp)
              .testTag("AltiveChatUI.ScrollToLatestButton")
              .semantics { contentDescription = strings.latestButtonLabel },
          ) { Text("↓") }
        }
      }

      selectedReply?.let { replyTo ->
        ChatReplyComposerBar(
          reference = replyTo,
          onCancel = { selectedReply = null },
          strings = strings,
          stickerImageLoader = stickerImageLoader,
        )
      }
      ChatImageComposer(
        draft = draft,
        onDraftChange = onDraftChange,
        imageDrafts = imageDrafts,
        configuration = imageInputConfiguration,
        availableImageInputSources = effectiveImageInputSources,
        isPreparingImages = resolvingUris.isNotEmpty() || isPreparingCameraImage,
        isPreparingCameraImage = isPreparingCameraImage,
        isSending = isSending,
        strings = strings,
        draftPolicy = draftPolicy,
        theme = theme,
        focusRequester = focusRequester,
        onRequestCamera = {
          focusManager.clearFocus()
          onRequestCamera?.invoke()
        },
        onRequestPhotoLibrary = {
          focusManager.clearFocus()
          launchClassicPhotoPicker()
        },
        onRequestFile = {
          focusManager.clearFocus()
          launchFilePicker()
        },
        onRequestClipboard = {
          val clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
          resolveUris(clipboardManager.imageUris())
        },
        onReceiveImageUris = if (canReceivePastedImages(remainingCapacity)) {
          { uris -> resolveUris(uris.map(Uri::parse)) }
        } else {
          null
        },
        onRemoveImage = { imageId ->
          latestOnImageDraftsChange(latestImageDrafts.filterNot { it.id == imageId })
          val currentMappings = photoUris.zip(photoDraftIdValues).toMap()
          updatePhotoDraftIds(currentMappings.filterValues { it != imageId })
        },
        onSubmit = {
          val submission = ChatComposerSubmission.create(
            draft = draft,
            images = imageDrafts,
            policy = draftPolicy,
            linkPreview = draftLinkPreviewState.previewForSubmission(draft),
            replyTo = selectedReply,
          ) ?: return@ChatImageComposer
          onSubmit(submission)
          onDraftChange("")
          onImageDraftsChange(emptyList())
          updatePhotoDraftIds(emptyMap())
          selectedReply = null
        },
        imageContent = imageContent ?: {
          Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(strings.imageLabel)
          }
        },
        linkPreviewContent = {
          ChatDraftLinkPreview(
            state = draftLinkPreviewState,
            strings = strings,
            imageContent = linkPreviewImageContent,
            onOpenLink = onLinkPreviewTap,
          )
        },
      )
    }
  }
}

private fun ClipboardManager.imageUris(): List<Uri> {
  val clip = primaryClip ?: return emptyList()
  if (!clip.description.hasMimeType("image/*")) return emptyList()
  return buildList {
    for (index in 0 until clip.itemCount) {
      clip.getItemAt(index).uri?.let(::add)
    }
  }
}

@Composable
private fun ReplyInteraction(
  message: ChatMessage,
  configuration: ChatReplyConfiguration?,
  strings: ChatRoomStrings,
  onSelect: (ChatReplyReference) -> Unit,
  content: @Composable () -> Unit,
) {
  val reference = configuration?.referenceFor(message)
  if (reference == null) {
    content()
    return
  }
  var expanded by remember(message.id) { mutableStateOf(false) }
  ChatInteractionPopover(
    expanded = expanded,
    onExpandedChange = { expanded = it },
    actions = {
      DropdownMenuItem(
        text = { Text(strings.replyActionLabel) },
        onClick = {
          expanded = false
          onSelect(reference)
        },
      )
    },
    content = content,
  )
}

@Composable
fun ChatMessageRow(
  message: ChatMessage,
  currentUserId: String,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  strings: ChatRoomStrings = ChatRoomStrings.localized(),
  showsSenderName: Boolean = false,
  singleImageLayout: ChatSingleImageLayout = ChatSingleImageLayout.AdaptiveBounded(),
  multipleImageLayout: ChatMultipleImageLayout = ChatMultipleImageLayout.Mosaic,
  onRetry: (() -> Unit)? = null,
  onImageTap: ((messageId: String, imageIndex: Int) -> Unit)? = null,
  imageContent: (@Composable BoxScope.(ChatImage) -> Unit)? = null,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)? = null,
  stickerImageLoader: ChatStickerImageLoader? = null,
  linkPreviewImageContent: (@Composable BoxScope.(ChatLinkPreviewImage) -> Unit)? = null,
  onLinkPreviewTap: ((String) -> Unit)? = null,
  onReplyReferenceTap: ((messageId: String, imageIndex: Int?) -> Unit)? = null,
) {
  when (val content = message.content) {
    is ChatMessageContent.System -> ChatSystemEventCard(theme) {
      Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        ChatLinkifiedText(
          text = content.value,
          strings = strings,
          modifier = Modifier.fillMaxWidth(),
          style = MaterialTheme.typography.bodySmall,
          textAlign = TextAlign.Center,
        )
        Text(formatTime(message.createdAtEpochMillis), Modifier.fillMaxWidth(), style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant, textAlign = TextAlign.Center)
      }
    }
    is ChatMessageContent.Text -> {
      val own = message.isSentBy(currentUserId)
      Row(Modifier.fillMaxWidth(), horizontalArrangement = if (own) Arrangement.End else Arrangement.Start) {
        Column(horizontalAlignment = if (own) Alignment.End else Alignment.Start) {
          if (showsSenderName && !own) Text(message.sender?.displayName ?: strings.unknownSender, style = MaterialTheme.typography.labelSmall)
          ChatMessageBubble(isOwnMessage = own, theme = theme) {
            Column(
              Modifier.padding(
                start = if (own) 14.dp else 22.dp,
                end = if (own) 22.dp else 14.dp,
                top = 10.dp,
                bottom = 10.dp,
              ),
            ) {
              message.replyTo?.let { replyTo ->
                ChatReplyQuote(
                  reference = replyTo,
                  strings = strings,
                  stickerImageLoader = stickerImageLoader,
                  onTap = onReplyReferenceTap?.let { callback ->
                    { callback(replyTo.messageId, replyTo.imageIndex) }
                  },
                )
                Spacer(Modifier.height(8.dp))
              }
              ChatLinkifiedText(
                text = content.value,
                strings = strings,
              )
              message.linkPreview?.takeIf { it.isDisplayable }?.let { preview ->
                Spacer(Modifier.height(8.dp))
                ChatLinkPreviewCard(
                  preview = preview,
                  linkPreviewLabel = strings.linkPreviewLabel,
                  imageContent = linkPreviewImageContent,
                  onOpenLink = onLinkPreviewTap,
                )
              }
            }
          }
          Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
            Text(formatTime(message.createdAtEpochMillis), style = MaterialTheme.typography.labelSmall)
            ChatDeliveryIndicator(message.deliveryState, strings.sendingLabel, strings.failedLabel, theme, onRetry)
          }
        }
      }
    }
    is ChatMessageContent.Images -> {
      ChatImageMessageRow(
        message = message,
        images = content.values,
        caption = null,
        currentUserId = currentUserId,
        theme = theme,
        strings = strings,
        showsSenderName = showsSenderName,
        onRetry = onRetry,
        onImageTap = onImageTap,
        singleImageLayout = singleImageLayout,
        multipleImageLayout = multipleImageLayout,
        imageContent = imageContent,
        transitioningImageContent = transitioningImageContent,
        onReplyReferenceTap = onReplyReferenceTap,
        stickerImageLoader = stickerImageLoader,
      )
    }
    is ChatMessageContent.ImagesWithCaption -> {
      ChatImageMessageRow(
        message = message,
        images = content.values,
        caption = content.caption,
        currentUserId = currentUserId,
        theme = theme,
        strings = strings,
        showsSenderName = showsSenderName,
        onRetry = onRetry,
        onImageTap = onImageTap,
        singleImageLayout = singleImageLayout,
        multipleImageLayout = multipleImageLayout,
        imageContent = imageContent,
        transitioningImageContent = transitioningImageContent,
        onReplyReferenceTap = onReplyReferenceTap,
        stickerImageLoader = stickerImageLoader,
      )
    }
    is ChatMessageContent.Sticker -> {
      ChatStickerMessageRow(
        message = message,
        reference = content.reference,
        currentUserId = currentUserId,
        theme = theme,
        strings = strings,
        showsSenderName = showsSenderName,
        imageLoader = stickerImageLoader,
        onRetry = onRetry,
        onReplyReferenceTap = onReplyReferenceTap,
      )
    }
  }
}

@Composable
private fun ChatStickerMessageRow(
  message: ChatMessage,
  reference: ChatStickerReference,
  currentUserId: String,
  theme: ChatRoomTheme,
  strings: ChatRoomStrings,
  showsSenderName: Boolean,
  imageLoader: ChatStickerImageLoader?,
  onRetry: (() -> Unit)?,
  onReplyReferenceTap: ((messageId: String, imageIndex: Int?) -> Unit)?,
) {
  val own = message.isSentBy(currentUserId)
  Row(
    Modifier.fillMaxWidth(),
    horizontalArrangement = if (own) Arrangement.End else Arrangement.Start,
  ) {
    Column(horizontalAlignment = if (own) Alignment.End else Alignment.Start) {
      if (showsSenderName && !own) {
        Text(
          message.sender?.displayName ?: strings.unknownSender,
          style = MaterialTheme.typography.labelSmall,
        )
      }
      message.replyTo?.let { replyTo ->
        ChatReplyQuote(
          reference = replyTo,
          strings = strings,
          stickerImageLoader = imageLoader,
          onTap = onReplyReferenceTap?.let { callback ->
            { callback(replyTo.messageId, replyTo.imageIndex) }
          },
        )
        Spacer(Modifier.height(4.dp))
      }
      ChatStickerMessageContent(
        reference = reference,
        imageLoader = imageLoader,
        stickerLabel = strings.stickerLabel,
        loadingFailureLabel = strings.stickerLoadingFailedLabel,
      )
      Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
        Text(formatTime(message.createdAtEpochMillis), style = MaterialTheme.typography.labelSmall)
        ChatDeliveryIndicator(
          message.deliveryState,
          strings.sendingLabel,
          strings.failedLabel,
          theme,
          onRetry,
        )
      }
    }
  }
}

@Composable
private fun ChatImageMessageRow(
  message: ChatMessage,
  images: List<ChatImage>,
  caption: String?,
  currentUserId: String,
  theme: ChatRoomTheme,
  strings: ChatRoomStrings,
  showsSenderName: Boolean,
  onRetry: (() -> Unit)?,
  onImageTap: ((messageId: String, imageIndex: Int) -> Unit)?,
  singleImageLayout: ChatSingleImageLayout,
  multipleImageLayout: ChatMultipleImageLayout,
  imageContent: (@Composable BoxScope.(ChatImage) -> Unit)?,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)?,
  onReplyReferenceTap: ((messageId: String, imageIndex: Int?) -> Unit)?,
  stickerImageLoader: ChatStickerImageLoader?,
) {
  val own = message.isSentBy(currentUserId)
  Row(
    Modifier.fillMaxWidth(),
    horizontalArrangement = if (own) Arrangement.End else Arrangement.Start,
  ) {
    Column(horizontalAlignment = if (own) Alignment.End else Alignment.Start) {
      if (showsSenderName && !own) {
        Text(
          message.sender?.displayName ?: strings.unknownSender,
          style = MaterialTheme.typography.labelSmall,
        )
      }
      message.replyTo?.let { replyTo ->
        ChatReplyQuote(
          reference = replyTo,
          strings = strings,
          stickerImageLoader = stickerImageLoader,
          onTap = onReplyReferenceTap?.let { callback ->
            { callback(replyTo.messageId, replyTo.imageIndex) }
          },
        )
        Spacer(Modifier.height(4.dp))
      }
      ChatImageGrid(
        messageId = message.id,
        images = images,
        imageLabel = strings.imageLabel,
        singleImageLayout = singleImageLayout,
        multipleImageLayout = multipleImageLayout,
        onImageTap = onImageTap,
        imageContent = imageContent,
        transitioningImageContent = transitioningImageContent,
      )
      if (caption != null) {
        Spacer(Modifier.height(4.dp))
        ChatMessageBubble(isOwnMessage = own, theme = theme) {
          ChatLinkifiedText(
            text = caption,
            strings = strings,
            modifier = Modifier.padding(
              start = if (own) 14.dp else 22.dp,
              end = if (own) 22.dp else 14.dp,
              top = 10.dp,
              bottom = 10.dp,
            ),
          )
        }
      }
      Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(5.dp),
      ) {
        Text(
          formatTime(message.createdAtEpochMillis),
          style = MaterialTheme.typography.labelSmall,
        )
        ChatDeliveryIndicator(
          message.deliveryState,
          strings.sendingLabel,
          strings.failedLabel,
          theme,
          onRetry,
        )
      }
    }
  }
}

@Composable
fun ChatComposer(
  draft: String,
  onDraftChange: (String) -> Unit,
  placeholder: String,
  sendButtonLabel: String,
  modifier: Modifier = Modifier,
  isInputSurfacePresented: Boolean = false,
  inputSurfaceHeight: Dp = 0.dp,
  inputSurfaceButtonLabel: String = "",
  inputSurfaceButtonHint: String? = null,
  showsInputSurfaceButton: Boolean = false,
  isSending: Boolean = false,
  draftPolicy: ChatDraftPolicy = ChatDraftPolicy(maximumLength = 500, warningThreshold = 450),
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  attachmentPreview: @Composable () -> Unit = {},
  inputSurface: @Composable () -> Unit = {},
  onToggleInputSurface: () -> Unit = {},
  onSend: (String) -> Unit,
) {
  val normalized = draftPolicy.normalizedText(draft)
  val focusManager = LocalFocusManager.current
  val rememberedFocusRequester = remember { FocusRequester() }
  val focusRequester = LocalChatComposerFocusRequester.current ?: rememberedFocusRequester
  val keyboardController = LocalSoftwareKeyboardController.current
  Column(modifier.fillMaxWidth().background(MaterialTheme.colorScheme.surface).padding(horizontal = 16.dp, vertical = 10.dp), horizontalAlignment = Alignment.End) {
    attachmentPreview()
    Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
      Row(Modifier.weight(1f).background(theme.composerField, RoundedCornerShape(24.dp)), verticalAlignment = Alignment.CenterVertically) {
        BasicTextField(
          value = draft,
          onValueChange = { onDraftChange(draftPolicy.limited(it)) },
          modifier = Modifier.weight(1f).focusRequester(focusRequester).testTag("AltiveChatUI.Composer").padding(horizontal = 16.dp, vertical = 12.dp),
          textStyle = MaterialTheme.typography.bodyLarge.copy(color = MaterialTheme.colorScheme.onSurface),
          cursorBrush = SolidColor(MaterialTheme.colorScheme.primary),
          decorationBox = { inner -> if (draft.isEmpty()) Text(placeholder, color = MaterialTheme.colorScheme.onSurfaceVariant); inner() },
        )
        if (showsInputSurfaceButton) TextButton(
          onClick = {
            if (isInputSurfacePresented) {
              onToggleInputSurface()
              focusRequester.requestFocus()
              keyboardController?.show()
            } else {
              focusManager.clearFocus()
              keyboardController?.hide()
              onToggleInputSurface()
            }
          },
          modifier = Modifier.semantics {
            contentDescription = listOfNotNull(inputSurfaceButtonLabel, inputSurfaceButtonHint).joinToString(". ")
          },
        ) { Text(if (isInputSurfacePresented) "⌨" else "☺") }
      }
      IconButton(
        onClick = { normalized?.let(onSend) },
        enabled = normalized != null && !isSending,
        modifier = Modifier.size(42.dp).testTag("AltiveChatUI.SendButton").clip(CircleShape).background(theme.sendButtonBackground).semantics { contentDescription = sendButtonLabel },
      ) {
        if (isSending) CircularProgressIndicator(Modifier.size(20.dp), color = theme.sendButtonForeground)
        else Text("↑", color = theme.sendButtonForeground, style = MaterialTheme.typography.titleLarge)
      }
    }
    if (draftPolicy.shouldShowLength(draft) && draftPolicy.maximumLength != null) {
      Text("${draftPolicy.length(draft)}/${draftPolicy.maximumLength}", style = MaterialTheme.typography.labelSmall)
    }
    if (isInputSurfacePresented) Box(Modifier.fillMaxWidth().height(inputSurfaceHeight)) { inputSurface() }
  }
}

@Composable
fun ChatComposerAttachmentPreview(
  isSending: Boolean,
  sendButtonLabel: String,
  removeButtonLabel: String,
  onSend: () -> Unit,
  onRemove: () -> Unit,
  modifier: Modifier = Modifier,
  content: @Composable BoxScope.() -> Unit,
) {
  Box(modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
    Box(Modifier.size(120.dp)) {
      TextButton(
        onClick = onSend,
        enabled = !isSending,
        modifier = Modifier.fillMaxSize().semantics { contentDescription = sendButtonLabel },
      ) { Box(Modifier.fillMaxSize(), content = content) }
      TextButton(
        onClick = onRemove,
        modifier = Modifier.align(Alignment.TopEnd).semantics { contentDescription = removeButtonLabel },
      ) { Text("×") }
    }
  }
}

@Composable
fun ChatDeliveryIndicator(
  state: ChatMessageDeliveryState?,
  sendingLabel: String,
  retryLabel: String,
  theme: ChatRoomTheme = ChatRoomTheme.fanely(),
  onRetry: (() -> Unit)? = null,
) {
  when (state) {
    ChatMessageDeliveryState.Sending -> CircularProgressIndicator(Modifier.size(12.dp).semantics { contentDescription = sendingLabel }, strokeWidth = 1.5.dp)
    ChatMessageDeliveryState.Failed -> IconButton(onClick = { onRetry?.invoke() }, enabled = onRetry != null, modifier = Modifier.size(24.dp).semantics { contentDescription = retryLabel }) {
      Text("!", color = theme.deliveryFailure, fontWeight = androidx.compose.ui.text.font.FontWeight.Bold)
    }
    else -> Unit
  }
}

private fun formatTime(epochMillis: Long): String = DateFormat.getTimeInstance(DateFormat.SHORT).format(Date(epochMillis))
