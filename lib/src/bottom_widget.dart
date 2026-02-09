import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'common_cached_network_image.dart';
import 'inherited_altive_chat_room_theme.dart';
import 'model.dart';

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
    required this.sendButtonIcon,
    required this.expandButtonIcon,
    required this.textFieldSuffixBuilder,
    required this.messageTypeNotifier,
    required this.leadingWidgets,
    required this.replyToMessageBar,
    required this.stickerPackages,
    required this.selectedSticker,
    required this.onStickerSelected,
  });

  /// 外部から渡す入力欄のコントローラー。
  final TextEditingController? textEditingController;

  /// 送信ボタン押下時のコールバック。
  final ValueChanged<({String text, Sticker? sticker})> onSendIconPressed;

  /// 送信ボタンのアイコン。
  final Icon? sendButtonIcon;

  /// 先頭ウィジェットを再表示するボタンのアイコン。
  final Icon? expandButtonIcon;

  /// 入力欄サフィックスの構築処理。
  final Widget Function(MessageInputType type)? textFieldSuffixBuilder;

  /// 入力種別（テキスト/スタンプ）を管理する Notifier。
  final ValueNotifier<MessageInputType> messageTypeNotifier;

  /// 入力欄先頭に表示するウィジェット一覧。
  final List<Widget>? leadingWidgets;

  /// 返信先メッセージ表示バー。
  final Widget? replyToMessageBar;

  /// 利用可能なスタンプパッケージ一覧。
  final List<StickerPackage> stickerPackages;

  /// 現在選択中のスタンプ。
  final Sticker? selectedSticker;

  /// スタンプ選択時のコールバック。
  final ValueChanged<Sticker> onStickerSelected;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  var _showLeadingWidgets = true;

  // スタンプからテキストに切り替えたときにテキストフィールドにフォーカスを当てるために使用する。
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
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final altiveChatRoomTheme = InheritedAltiveChatRoomTheme.of(context).theme;
    final leadingWidgets = widget.leadingWidgets;
    final replyToMessageBar = widget.replyToMessageBar;
    final textFieldSuffixBuilder = widget.textFieldSuffixBuilder;
    final messageTypeNotifier = widget.messageTypeNotifier;
    return ValueListenableBuilder<MessageInputType>(
      valueListenable: messageTypeNotifier,
      builder: (context, messageType, child) {
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
                        hintText: 'Message',
                        suffixIcon: textFieldSuffixBuilder != null
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    switch (messageType) {
                                      case MessageInputType.text:
                                        messageTypeNotifier.value =
                                            MessageInputType.sticker;
                                        FocusScope.of(context).unfocus();
                                      case MessageInputType.sticker:
                                        messageTypeNotifier.value =
                                            MessageInputType.text;
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(focusNode);
                                    }
                                  });
                                },
                                child: Center(
                                  widthFactor: 1,
                                  heightFactor: 1,
                                  child: textFieldSuffixBuilder(messageType),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _showLeadingWidgets = false;
                        });
                      },
                      onTap: () {
                        setState(() {
                          _showLeadingWidgets = false;
                          messageTypeNotifier.value = MessageInputType.text;
                        });
                      },
                    ),
                  ),
                  if (_effectiveController.text.isNotEmpty ||
                      widget.selectedSticker != null)
                    IconButton(
                      icon: widget.sendButtonIcon ?? const Icon(Icons.send),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () {
                        widget.onSendIconPressed.call((
                          text: _effectiveController.text,
                          sticker: widget.selectedSticker,
                        ));
                        _effectiveController.text = '';
                      },
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            if (messageType == MessageInputType.sticker)
              // スタンプ選択View。
              _StickerSelectionView(
                stickerPackages: widget.stickerPackages,
                onStickerSelected: widget.onStickerSelected,
              ),
          ],
        );
      },
    );
  }
}

/// スタンプ選択View。
class _StickerSelectionView extends StatefulWidget {
  const _StickerSelectionView({
    required this.stickerPackages,
    required this.onStickerSelected,
  });

  final List<StickerPackage> stickerPackages;
  final ValueChanged<Sticker> onStickerSelected;

  @override
  State<_StickerSelectionView> createState() => _StickerSelectionViewState();
}

class _StickerSelectionViewState extends State<_StickerSelectionView> {
  // 選択中のスタンプパッケージ。
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
          // スタンプパッケージ一覧。
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
                      child: CommonCachedNetworkImage(
                        imageUrl: stickerPackage.tabStickerImageUrl,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
          const SizedBox(height: 10),

          // 選択中のスタンプパッケージのスタンプ一覧。
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 73 / 58,
                mainAxisSpacing: 8,
                crossAxisSpacing: 16,
              ),
              itemCount: _selectedStickerPackage?.stickers.length ?? 0,
              itemBuilder: (context, index) {
                final sticker = _selectedStickerPackage?.stickers[index];
                if (sticker == null) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () {
                    widget.onStickerSelected.call(sticker);
                  },
                  child: CommonCachedNetworkImage(imageUrl: sticker.imageUrl),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
