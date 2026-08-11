package jp.co.altive.chat

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp

enum class ChatStickerPickerLoadState { Idle, Loading, Loaded, Unavailable, Failed }

data class ChatStickerPickerItem<Reference, Asset>(
  val id: String,
  val reference: Reference,
  val asset: Asset,
  val accessibilityLabel: String,
)

data class ChatStickerPickerPack<Reference, Asset>(
  val id: String,
  val displayName: String,
  val trayIcon: Asset,
  val stickers: List<ChatStickerPickerItem<Reference, Asset>>,
)

sealed interface ChatStickerPickerImageSource<out Reference, out Asset> {
  data class Asset<Asset>(val value: Asset) : ChatStickerPickerImageSource<Nothing, Asset>
  data class Reference<Reference>(val value: Reference) : ChatStickerPickerImageSource<Reference, Nothing>
}

data class ChatStickerPickerStrings(
  val historyLabel: String,
  val historyEmptyTitle: String,
  val unavailableTitle: String,
  val unavailableDescription: String? = null,
  val failedTitle: String,
  val retryLabel: String,
)

@Composable
fun <Reference, Asset> ChatStickerPicker(
  isCatalogLoading: Boolean,
  isCatalogAvailable: Boolean,
  loadState: ChatStickerPickerLoadState,
  packs: List<ChatStickerPickerPack<Reference, Asset>>,
  selectedPackId: String,
  isHistorySelected: Boolean,
  recentReferences: List<Reference>,
  strings: ChatStickerPickerStrings,
  onSelectHistory: () -> Unit,
  onSelectPack: (String) -> Unit,
  onSelect: (Reference) -> Unit,
  onRetry: () -> Unit,
  modifier: Modifier = Modifier,
  referenceAccessibilityLabel: (Reference) -> String = { it.toString() },
  image: @Composable (ChatStickerPickerImageSource<Reference, Asset>) -> Unit,
) {
  if (isCatalogLoading) {
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
    return
  }
  if (!isCatalogAvailable || loadState == ChatStickerPickerLoadState.Unavailable) {
    PickerMessage(strings.unavailableTitle, strings.unavailableDescription)
    return
  }
  if (loadState == ChatStickerPickerLoadState.Idle || loadState == ChatStickerPickerLoadState.Loading) {
    Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
    return
  }
  if (loadState == ChatStickerPickerLoadState.Failed) {
    Column(modifier.fillMaxSize(), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
      Text(strings.failedTitle, style = MaterialTheme.typography.titleMedium)
      Button(onClick = onRetry) { Text(strings.retryLabel) }
    }
    return
  }
  val selected = packs.firstOrNull { it.id == selectedPackId } ?: packs.firstOrNull()
  Column(modifier) {
    LazyRow(contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
      item { TextButton(onClick = onSelectHistory, modifier = Modifier.semantics { contentDescription = strings.historyLabel }) { Text("◷") } }
      items(packs.size) { index ->
        val pack = packs[index]
        TextButton(onClick = { onSelectPack(pack.id) }, modifier = Modifier.semantics { contentDescription = pack.displayName }) {
          image(ChatStickerPickerImageSource.Asset(pack.trayIcon))
        }
      }
    }
    HorizontalDivider()
    if (isHistorySelected && recentReferences.isEmpty()) PickerMessage(strings.historyEmptyTitle)
    else LazyVerticalGrid(columns = GridCells.Adaptive(88.dp), contentPadding = PaddingValues(12.dp)) {
      if (isHistorySelected) items(recentReferences) { reference ->
        TextButton(onClick = { onSelect(reference) }, modifier = Modifier.heightIn(min = 88.dp).semantics { contentDescription = referenceAccessibilityLabel(reference) }) {
          image(ChatStickerPickerImageSource.Reference(reference))
        }
      } else items(selected?.stickers.orEmpty(), key = { it.id }) { sticker ->
        TextButton(onClick = { onSelect(sticker.reference) }, modifier = Modifier.heightIn(min = 88.dp).semantics { contentDescription = sticker.accessibilityLabel }) {
          image(ChatStickerPickerImageSource.Asset(sticker.asset))
        }
      }
    }
  }
}

@Composable private fun PickerMessage(title: String, description: String? = null) {
  Column(Modifier.fillMaxSize().padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
    Text(title, style = MaterialTheme.typography.titleMedium)
    if (description != null) Text(description, style = MaterialTheme.typography.bodySmall)
  }
}
