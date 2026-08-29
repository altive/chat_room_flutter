import 'package:flutter/material.dart';

import 'models.dart';

/// Webリンクプレビューを表示するカード。
class ChatLinkPreviewCard extends StatelessWidget {
  /// Webリンクプレビューを表示するカードを作成する。
  const ChatLinkPreviewCard({
    super.key,
    required this.preview,
    this.imageBuilder,
    this.onTap,
    this.compact = false,
    this.semanticLabel = 'Link preview',
  });

  /// 表示値。
  final ChatLinkPreview preview;

  /// 画像loaderをアプリ側で構築する処理。
  final ChatLinkPreviewImageBuilder? imageBuilder;

  /// カード操作時の処理。
  final VoidCallback? onTap;

  /// 入力欄向けの密度で表示するかどうか。
  final bool compact;

  /// カードの読み上げ文。
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (!preview.isDisplayable) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final image = preview.image;
    final canShowImage =
        image != null && image.isDisplayable && imageBuilder != null;
    final semanticsParts = <String>[
      semanticLabel,
      if (preview.siteName?.trim() case final site? when site.isNotEmpty) site,
      preview.title.trim(),
      if (preview.description?.trim() case final description?
          when description.isNotEmpty)
        description,
      preview.sourceUrl.toString(),
    ];
    final content = Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (preview.siteName?.trim() case final site?
                    when site.isNotEmpty)
                  Text(
                    site,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  preview.title.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (preview.description?.trim() case final description?
                    when description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (canShowImage) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: compact ? 56 : 72,
                height: compact ? 56 : 72,
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: (compact ? 56 : 72) * image.aspectRatio,
                    height: compact ? 56 : 72,
                    child: imageBuilder!(context, image),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      link: true,
      button: onTap != null,
      label: semanticsParts.join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: content,
            ),
    );
  }
}

/// 入力中のリンク解決待ちを表示する固定高のplaceholder。
class ChatLinkPreviewPlaceholder extends StatelessWidget {
  /// 入力中のリンク解決待ちを表示するplaceholderを作成する。
  const ChatLinkPreviewPlaceholder({
    super.key,
    this.semanticLabel = 'Loading link preview',
  });

  /// 読み込み中状態の読み上げ文。
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
    );
  }
}
