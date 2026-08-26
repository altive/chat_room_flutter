package jp.co.altive.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import coil3.compose.AsyncImagePainter
import coil3.compose.rememberAsyncImagePainter

/** 複数画像メッセージの配置方法。 */
enum class ChatMultipleImageLayout {
  /** 3枚では左側を大きくし、右側へ2枚を配置する。 */
  Mosaic,

  /** 3枚では先頭を横長にし、残りを下段の2列へ配置する。 */
  LeadingWideGrid,
}

/** 単一画像メッセージの配置方法。 */
sealed interface ChatSingleImageLayout {
  /** 元画像の縦横比を高さ範囲内で維持する。 */
  data class AdaptiveBounded(
    val minimumHeight: Dp = 160.dp,
    val maximumHeight: Dp = 260.dp,
  ) : ChatSingleImageLayout {
    init {
      require(minimumHeight > 0.dp)
      require(maximumHeight >= minimumHeight)
    }
  }

  /** 従来互換の正方形表示。 */
  data object Square : ChatSingleImageLayout
}

/** 画像リソース切替中に画像ローダーへ渡す描画契約。 */
data class ChatImageContentTransition(
  /** 新しく表示する画像。 */
  val image: ChatImage,
  /** 新しい画像の準備が完了するまで表示できる直前の画像。 */
  val previousImage: ChatImage?,
  /** 新しい画像の読み込み成功時に呼び出す。 */
  val onImageReady: () -> Unit,
)

@Composable
fun ChatImageGrid(
  messageId: String,
  images: List<ChatImage>,
  imageLabel: String,
  modifier: Modifier = Modifier,
  singleImageLayout: ChatSingleImageLayout = ChatSingleImageLayout.AdaptiveBounded(),
  multipleImageLayout: ChatMultipleImageLayout = ChatMultipleImageLayout.Mosaic,
  onImageTap: ((messageId: String, imageIndex: Int) -> Unit)? = null,
  imageContent: (@Composable BoxScope.(ChatImage) -> Unit)? = null,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)? = null,
) {
  val resolvedImageContent: @Composable BoxScope.(ChatImage) -> Unit =
    imageContent ?: { DefaultChatImageContent(imageLabel) }
  val resolvedTransitioningImageContent:
    (@Composable BoxScope.(ChatImageContentTransition) -> Unit)? =
    transitioningImageContent ?: if (imageContent == null) {
      { DefaultTransitioningChatImageContent(it) }
    } else {
      // 既存の描画slotを明示した利用側では、その描画を優先して互換性を維持する。
      null
    }
  val visibleImages = images.take(ChatImageGridMetrics.visibleCount(images.size))
  val shape = RoundedCornerShape(16.dp)
  Box(modifier.clip(shape)) {
    when (visibleImages.size) {
      0 -> Unit
      1 -> ChatImageTile(
        image = visibleImages[0],
        imageLabel = imageLabel,
        modifier = Modifier.width(240.dp).height(singleImageHeight(visibleImages[0], singleImageLayout)),
        onClick = onImageTap?.let { { it(messageId, 0) } },
        imageContent = resolvedImageContent,
        transitioningImageContent = resolvedTransitioningImageContent,
      )
      2 -> Row(
        Modifier.width(267.dp).height(176.dp),
        horizontalArrangement = Arrangement.spacedBy(3.dp),
      ) {
        visibleImages.forEachIndexed { index, image ->
          ChatImageTile(
            image,
            imageLabel,
            Modifier.weight(1f).fillMaxSize(),
            onImageTap?.let { { it(messageId, index) } },
            imageContent = resolvedImageContent,
            transitioningImageContent = resolvedTransitioningImageContent,
          )
        }
      }
      3 -> when (multipleImageLayout) {
        ChatMultipleImageLayout.Mosaic -> MosaicThreeImageGrid(
          messageId = messageId,
          images = visibleImages,
          imageLabel = imageLabel,
          onImageTap = onImageTap,
          imageContent = resolvedImageContent,
          transitioningImageContent = resolvedTransitioningImageContent,
        )
        ChatMultipleImageLayout.LeadingWideGrid -> LeadingWideThreeImageGrid(
          messageId = messageId,
          images = visibleImages,
          imageLabel = imageLabel,
          onImageTap = onImageTap,
          imageContent = resolvedImageContent,
          transitioningImageContent = resolvedTransitioningImageContent,
        )
      }
      else -> Column(
        Modifier.size(267.dp),
        verticalArrangement = Arrangement.spacedBy(3.dp),
      ) {
        visibleImages.chunked(2).forEachIndexed { rowIndex, rowImages ->
          Row(
            Modifier.weight(1f).fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(3.dp),
          ) {
            rowImages.forEachIndexed { columnIndex, image ->
              val index = rowIndex * 2 + columnIndex
              ChatImageTile(
                image,
                imageLabel,
                Modifier.weight(1f).fillMaxSize(),
                onImageTap?.let { { it(messageId, index) } },
                if (index == 3) ChatImageGridMetrics.overflowCount(images.size) else 0,
                resolvedImageContent,
                resolvedTransitioningImageContent,
              )
            }
          }
        }
      }
    }
  }
}

@Composable
internal fun ChatImageTile(
  image: ChatImage,
  imageLabel: String,
  modifier: Modifier = Modifier,
  onClick: (() -> Unit)? = null,
  overflowCount: Int = 0,
  imageContent: @Composable BoxScope.(ChatImage) -> Unit,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)? = null,
) {
  var presentedImage by remember(image.id) { mutableStateOf(image) }
  val latestImage by rememberUpdatedState(image)
  Box(
    modifier
      .background(MaterialTheme.colorScheme.surfaceContainerHighest)
      .then(if (onClick == null) Modifier else Modifier.clickable(onClick = onClick))
      .semantics { contentDescription = image.accessibilityLabel ?: imageLabel },
    contentAlignment = Alignment.Center,
  ) {
    if (transitioningImageContent == null) {
      imageContent(image)
    } else {
      val previousImage = presentedImage.takeIf { it.resource != image.resource }
      transitioningImageContent(
        ChatImageContentTransition(
          image = image,
          previousImage = previousImage,
          onImageReady = {
            // 遅れて完了した旧リクエストで新しい表示を巻き戻さない。
            if (latestImage.id == image.id && latestImage.resource == image.resource) {
              presentedImage = image
            }
          },
        ),
      )
    }
    if (overflowCount > 0) {
      Box(
        Modifier.fillMaxSize().background(Color.Black.copy(alpha = .48f)),
        contentAlignment = Alignment.Center,
      ) {
        Text(
          "+$overflowCount",
          color = Color.White,
          style = MaterialTheme.typography.headlineSmall,
          fontWeight = FontWeight.Bold,
        )
      }
    }
  }
}

/** 3枚を左大・右2枚で配置する。 */
@Composable
private fun MosaicThreeImageGrid(
  messageId: String,
  images: List<ChatImage>,
  imageLabel: String,
  onImageTap: ((messageId: String, imageIndex: Int) -> Unit)?,
  imageContent: @Composable BoxScope.(ChatImage) -> Unit,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)?,
) {
  Row(
    Modifier.width(267.dp).height(221.dp),
    horizontalArrangement = Arrangement.spacedBy(3.dp),
  ) {
    ChatImageTile(
      images[0],
      imageLabel,
      Modifier.width(176.dp).fillMaxSize(),
      onImageTap?.let { { it(messageId, 0) } },
      imageContent = imageContent,
      transitioningImageContent = transitioningImageContent,
    )
    Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
      images.drop(1).forEachIndexed { offset, image ->
        ChatImageTile(
          image,
          imageLabel,
          Modifier.weight(1f).fillMaxWidth(),
          onImageTap?.let { { it(messageId, offset + 1) } },
          imageContent = imageContent,
          transitioningImageContent = transitioningImageContent,
        )
      }
    }
  }
}

/** 3枚を先頭横長・下段2列で配置する。 */
@Composable
private fun LeadingWideThreeImageGrid(
  messageId: String,
  images: List<ChatImage>,
  imageLabel: String,
  onImageTap: ((messageId: String, imageIndex: Int) -> Unit)?,
  imageContent: @Composable BoxScope.(ChatImage) -> Unit,
  transitioningImageContent: (@Composable BoxScope.(ChatImageContentTransition) -> Unit)?,
) {
  Column(
    Modifier.size(267.dp),
    verticalArrangement = Arrangement.spacedBy(3.dp),
  ) {
    ChatImageTile(
      images[0],
      imageLabel,
      Modifier.weight(1f).fillMaxWidth(),
      onImageTap?.let { { it(messageId, 0) } },
      imageContent = imageContent,
      transitioningImageContent = transitioningImageContent,
    )
    Row(
      Modifier.weight(1f).fillMaxWidth(),
      horizontalArrangement = Arrangement.spacedBy(3.dp),
    ) {
      images.drop(1).forEachIndexed { offset, image ->
        ChatImageTile(
          image,
          imageLabel,
          Modifier.weight(1f).fillMaxSize(),
          onImageTap?.let { { it(messageId, offset + 1) } },
          imageContent = imageContent,
          transitioningImageContent = transitioningImageContent,
        )
      }
    }
  }
}

@Composable
private fun DefaultChatImageContent(imageLabel: String) {
  Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
    Text(imageLabel, color = MaterialTheme.colorScheme.onSurfaceVariant)
  }
}

/** Coilを使って直前の画像を残しながら新しいresourceへ切り替える標準描画。 */
@Composable
internal fun BoxScope.DefaultTransitioningChatImageContent(
  transition: ChatImageContentTransition,
) {
  val previousModel = transition.previousImage?.resource?.modelValue()
  if (previousModel != null) {
    AsyncImage(
      model = previousModel,
      contentDescription = null,
      modifier = Modifier.fillMaxSize(),
      contentScale = ContentScale.Crop,
    )
  }

  val painter = rememberAsyncImagePainter(transition.image.resource.modelValue())
  val state by painter.state.collectAsState()
  LaunchedEffect(state) {
    if (state is AsyncImagePainter.State.Success) {
      transition.onImageReady()
    }
  }
  if (state is AsyncImagePainter.State.Success || previousModel == null) {
    Image(
      painter = painter,
      contentDescription = null,
      modifier = Modifier.fillMaxSize(),
      contentScale = ContentScale.Crop,
    )
  }
}

/** Coilへ渡せるresource値へ変換する。 */
private fun ChatImageResource.modelValue(): String = when (this) {
  is ChatImageResource.LocalUri -> value
  is ChatImageResource.RemoteUrl -> value
}

/** 単一画像の表示高さを返す。 */
internal fun singleImageHeight(image: ChatImage, layout: ChatSingleImageLayout): Dp {
  if (layout is ChatSingleImageLayout.Square) return 240.dp
  layout as ChatSingleImageLayout.AdaptiveBounded
  val width = image.pixelWidth?.takeIf { it > 0 } ?: return 220.dp
  val height = image.pixelHeight?.takeIf { it > 0 } ?: return 220.dp
  return (240f / width * height).dp.coerceIn(layout.minimumHeight, layout.maximumHeight)
}
