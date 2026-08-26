import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'common_cached_network_image.dart';
import 'inherited_altive_chat_room_theme.dart';
import 'models.dart';

/// {@template altive_chat_room.BottomWidget}
/// ボトムに配置するWidget。
///
/// テキストフィールドとメッセージの送信ボタンを表示する。
/// {@endtemplate}
class BottomWidget extends StatefulWidget {
  /// {@macro altive_chat_room.BottomWidget}
  const BottomWidget({
    super.key,
    this.textEditingController,
    required this.onSendIconPressed,
    required this.hintText,
    required this.showSendButtonInTextField,
    required this.sendButtonWidget,
    required this.expandButtonIcon,
    required this.textFieldSuffixBuilder,
    required this.messageTypeNotifier,
    required this.leadingWidgets,
    required this.replyToMessageBar,
    required this.stickerPackages,
    required this.stickerPickerFooter,
    required this.onLockedStickerTap,
    required this.lockedStickerSemanticLabel,
    required this.selectedSticker,
    required this.onStickerSelected,
  });

  /// 外部から渡す入力欄のコントローラー。
  final TextEditingController? textEditingController;

  /// 送信ボタン押下時のコールバック。
  final ValueChanged<({String text, Sticker? sticker})> onSendIconPressed;

  /// 入力欄のプレースホルダーテキスト。
  final String hintText;

  /// 送信ボタンをTextField内に表示するかどうか。
  final bool showSendButtonInTextField;

  /// 送信ボタンに表示するWidget。
  final Widget? sendButtonWidget;

  /// 先頭ウィジェットを再表示するボタンのアイコン。
  final Icon? expandButtonIcon;

  /// 入力欄サフィックスの構築処理。
  final Widget Function(MessageInputType type)? textFieldSuffixBuilder;

  /// 入力種別（テキスト/ステッカー）を管理する Notifier。
  final ValueNotifier<MessageInputType> messageTypeNotifier;

  /// 入力欄先頭に表示するウィジェット一覧。
  final List<Widget>? leadingWidgets;

  /// 返信先メッセージ表示バー。
  final Widget? replyToMessageBar;

  /// 利用可能なステッカーパッケージ一覧。
  final List<StickerPackage> stickerPackages;

  /// ステッカー一覧の最下部に表示するWidget。
  final Widget? stickerPickerFooter;

  /// ロック中のステッカーをタップした時の処理。
  final VoidCallback? onLockedStickerTap;

  /// ロック中の項目へ付与する読み上げ文。
  final String? lockedStickerSemanticLabel;

  /// 現在選択中のステッカー。
  final Sticker? selectedSticker;

  /// ステッカー選択時のコールバック。
  final ValueChanged<Sticker> onStickerSelected;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  var _showLeadingWidgets = true;

  // ステッカーからテキストに切り替えたときにテキストフィールドにフォーカスを当てるために使用する。
  final focusNode = FocusNode();

  TextEditingController? _controller;
  TextEditingController get _effectiveController =>
      widget.textEditingController ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.textEditingController == null) {
      _controller = TextEditingController();
    }
    focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    focusNode.removeListener(_handleFocusChange);
    _controller?.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (focusNode.hasFocus && _showLeadingWidgets) {
      setState(() {
        _showLeadingWidgets = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final leadingWidgets = widget.leadingWidgets;
    final replyToMessageBar = widget.replyToMessageBar;
    final textFieldSuffixBuilder = widget.textFieldSuffixBuilder;
    final messageTypeNotifier = widget.messageTypeNotifier;
    final sendButtonWidget = widget.sendButtonWidget;
    final shouldShowSendButton =
        _effectiveController.text.isNotEmpty || widget.selectedSticker != null;
    final stickerInputEnabled = widget.stickerPackages.isNotEmpty;

    final sendButton = IconButton(
      icon: sendButtonWidget ?? const Icon(Icons.send),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: sendButtonWidget == null
          ? const BoxConstraints(minWidth: 32, minHeight: 32)
          : null,
      onPressed: () {
        widget.onSendIconPressed.call((
          text: _effectiveController.text,
          sticker: widget.selectedSticker,
        ));
        setState(() {
          _effectiveController.clear();
        });
      },
    );

    return ValueListenableBuilder<MessageInputType>(
      valueListenable: messageTypeNotifier,
      builder: (context, messageType, child) {
        final suffixWidgets = [
          if (textFieldSuffixBuilder != null)
            GestureDetector(
              onTap: stickerInputEnabled
                  ? () {
                      setState(() {
                        switch (messageType) {
                          case MessageInputType.text:
                            messageTypeNotifier.value =
                                MessageInputType.sticker;
                            FocusScope.of(context).unfocus();
                          case MessageInputType.sticker:
                            messageTypeNotifier.value = MessageInputType.text;
                            FocusScope.of(context).requestFocus(focusNode);
                        }
                      });
                    }
                  : null,
              child: textFieldSuffixBuilder(messageType),
            ),
          if (widget.showSendButtonInTextField && shouldShowSendButton)
            sendButton,
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?replyToMessageBar,
            Container(
              color:
                  altiveChatRoomTheme.inputBackgroundColor ??
                  theme.colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  /// 先頭に表示するWidgetを表示する場合
                  if (leadingWidgets != null && _showLeadingWidgets)
                    ...leadingWidgets,

                  /// 先頭に表示するWidgetを非表示にする場合
                  if (leadingWidgets != null && !_showLeadingWidgets)
                    IconButton(
                      icon:
                          widget.expandButtonIcon ??
                          const Icon(Icons.arrow_forward_ios_outlined),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        focusNode.unfocus();
                        setState(() {
                          _showLeadingWidgets = true;
                        });
                      },
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _effectiveController,
                      focusNode: focusNode,
                      minLines: 1,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        suffixIcon: suffixWidgets.isEmpty
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: suffixWidgets,
                              ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                      onTap: () {
                        setState(() {
                          messageTypeNotifier.value = MessageInputType.text;
                        });
                      },
                    ),
                  ),
                  if (!widget.showSendButtonInTextField && shouldShowSendButton)
                    sendButton,
                  const SizedBox(width: 8),
                ],
              ),
            ),
            if (stickerInputEnabled && messageType == MessageInputType.sticker)
              // ステッカー選択View。
              _StickerSelectionView(
                stickerPackages: widget.stickerPackages,
                footer: widget.stickerPickerFooter,
                onLockedStickerTap: widget.onLockedStickerTap,
                lockedStickerSemanticLabel: widget.lockedStickerSemanticLabel,
                onStickerSelected: widget.onStickerSelected,
              ),
          ],
        );
      },
    );
  }
}

/// ステッカー選択View。
class _StickerSelectionView extends StatefulWidget {
  const _StickerSelectionView({
    required this.stickerPackages,
    required this.footer,
    required this.onLockedStickerTap,
    required this.lockedStickerSemanticLabel,
    required this.onStickerSelected,
  });

  final List<StickerPackage> stickerPackages;
  final Widget? footer;
  final VoidCallback? onLockedStickerTap;
  final String? lockedStickerSemanticLabel;
  final ValueChanged<Sticker> onStickerSelected;

  @override
  State<_StickerSelectionView> createState() => _StickerSelectionViewState();
}

class _StickerSelectionViewState extends State<_StickerSelectionView> {
  // 選択中のステッカーパッケージ。
  StickerPackage? _selectedStickerPackage;

  @override
  void initState() {
    super.initState();
    _selectedStickerPackage = widget.stickerPackages.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.heightOf(context) * 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // ステッカーパッケージ一覧。
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.stickerPackages.length,
              itemBuilder: (context, index) {
                final stickerPackage = widget.stickerPackages[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStickerPackage = stickerPackage;
                      });
                    },
                    child: ColoredBox(
                      color: _selectedStickerPackage == stickerPackage
                          ? colorScheme.primaryContainer
                          : colorScheme.surface.withValues(alpha: 0),
                      child: Semantics(
                        label: stickerPackage.isLocked
                            ? widget.lockedStickerSemanticLabel
                            : null,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Opacity(
                              opacity: stickerPackage.isLocked ? 0.55 : 1,
                              child: CommonCachedNetworkImage(
                                imageUrl: stickerPackage.tabStickerImageUrl,
                                width: 32,
                                height: 32,
                              ),
                            ),
                            if (stickerPackage.isLocked)
                              const _StickerLockBadge(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
          const SizedBox(height: 10),

          // 選択中のステッカーパッケージのステッカー一覧。
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    const minimumColumnCount = 4;
                    const preferredCellWidth = 73.0;
                    const crossAxisSpacing = 16.0;
                    final fittingColumnCount =
                        ((constraints.crossAxisExtent + crossAxisSpacing) /
                                (preferredCellWidth + crossAxisSpacing))
                            .floor();
                    final columnCount = fittingColumnCount < minimumColumnCount
                        ? minimumColumnCount
                        : fittingColumnCount;

                    return SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnCount,
                        childAspectRatio: 73 / 58,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: crossAxisSpacing,
                      ),
                      itemCount: _selectedStickerPackage?.stickers.length ?? 0,
                      itemBuilder: (context, index) {
                        final sticker =
                            _selectedStickerPackage?.stickers[index];
                        if (sticker == null) {
                          return const SizedBox.shrink();
                        }
                        final isLocked =
                            _selectedStickerPackage?.isLocked ?? false;
                        return GestureDetector(
                          onTap: () {
                            if (isLocked) {
                              widget.onLockedStickerTap?.call();
                            } else {
                              widget.onStickerSelected.call(sticker);
                            }
                          },
                          child: Semantics(
                            label: isLocked
                                ? widget.lockedStickerSemanticLabel
                                : null,
                            button: true,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Opacity(
                                  opacity: isLocked ? 0.55 : 1,
                                  child: CommonCachedNetworkImage(
                                    imageUrl: sticker.imageUrl,
                                  ),
                                ),
                                if (isLocked) const _StickerLockBadge(),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                if (widget.footer case final footer?)
                  SliverToBoxAdapter(child: footer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickerLockBadge extends StatelessWidget {
  const _StickerLockBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.inverseSurface.withValues(alpha: 0.82),
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(3),
        child: Icon(Icons.lock, size: 12, color: Colors.white),
      ),
    );
  }
}
