package jp.co.altive.chat

import android.annotation.SuppressLint
import android.net.Uri
import android.os.Build
import android.os.ext.SdkExtensions
import android.provider.MediaStore
import android.widget.photopicker.EmbeddedPhotoPickerFeatureInfo
import androidx.annotation.RequiresApi
import androidx.annotation.RequiresExtension
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.photopicker.compose.EmbeddedPhotoPicker
import androidx.photopicker.compose.ExperimentalPhotoPickerComposeApi
import androidx.photopicker.compose.rememberEmbeddedPhotoPickerState
import kotlinx.coroutines.CancellationException

internal fun isEmbeddedPhotoPickerAvailable(): Boolean =
  Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
    SdkExtensions.getExtensionVersion(Build.VERSION_CODES.UPSIDE_DOWN_CAKE) >= 15

@SuppressLint("NewApi")
@Composable
internal fun BoxScope.ChatEmbeddedPhotoPicker(
  maximumSelectionCount: Int,
  initialSelectedUris: Set<String>,
  isExpanded: Boolean,
  pendingDeselectUris: Set<String>,
  onUrisSelected: (List<String>) -> Unit,
  onUrisDeselected: (List<String>) -> Unit,
  onPendingDeselectHandled: (Set<String>) -> Unit,
  onSelectionComplete: () -> Unit,
  onFailure: (Throwable) -> Unit,
) {
  if (!isEmbeddedPhotoPickerAvailable()) return
  ChatEmbeddedPhotoPickerApi34(
    maximumSelectionCount = maximumSelectionCount,
    initialSelectedUris = initialSelectedUris,
    isExpanded = isExpanded,
    pendingDeselectUris = pendingDeselectUris,
    onUrisSelected = onUrisSelected,
    onUrisDeselected = onUrisDeselected,
    onPendingDeselectHandled = onPendingDeselectHandled,
    onSelectionComplete = onSelectionComplete,
    onFailure = onFailure,
  )
}

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
@RequiresExtension(extension = Build.VERSION_CODES.UPSIDE_DOWN_CAKE, version = 15)
@OptIn(ExperimentalPhotoPickerComposeApi::class)
@Composable
private fun BoxScope.ChatEmbeddedPhotoPickerApi34(
  maximumSelectionCount: Int,
  initialSelectedUris: Set<String>,
  isExpanded: Boolean,
  pendingDeselectUris: Set<String>,
  onUrisSelected: (List<String>) -> Unit,
  onUrisDeselected: (List<String>) -> Unit,
  onPendingDeselectHandled: (Set<String>) -> Unit,
  onSelectionComplete: () -> Unit,
  onFailure: (Throwable) -> Unit,
) {
  val pickerState = rememberEmbeddedPhotoPickerState(
    initialExpandedValue = isExpanded,
    initialMediaSelection = initialSelectedUris.map(Uri::parse).toSet(),
    onSessionError = onFailure,
    onUriPermissionGranted = { onUrisSelected(it.map(Uri::toString)) },
    onUriPermissionRevoked = { onUrisDeselected(it.map(Uri::toString)) },
    onSelectionComplete = onSelectionComplete,
  )
  val platformMaximum = MediaStore.getPickImagesMaxLimit()
  val featureInfo = remember(maximumSelectionCount, platformMaximum) {
    EmbeddedPhotoPickerFeatureInfo.Builder()
      .setMaxSelectionLimit(maximumSelectionCount.coerceIn(1, platformMaximum))
      .setMimeTypes(listOf("image/*"))
      .setOrderedSelection(true)
      .build()
  }

  LaunchedEffect(isExpanded) {
    pickerState.isExpanded = isExpanded
  }
  LaunchedEffect(pendingDeselectUris) {
    if (pendingDeselectUris.isEmpty()) return@LaunchedEffect
    try {
      pickerState.deselectUris(pendingDeselectUris.map(Uri::parse))
      onPendingDeselectHandled(pendingDeselectUris)
    } catch (cancellation: CancellationException) {
      throw cancellation
    } catch (throwable: Throwable) {
      onFailure(throwable)
      onPendingDeselectHandled(pendingDeselectUris)
    }
  }

  EmbeddedPhotoPicker(
    state = pickerState,
    modifier = Modifier.fillMaxSize(),
    embeddedPhotoPickerFeatureInfo = featureInfo,
  )
}
