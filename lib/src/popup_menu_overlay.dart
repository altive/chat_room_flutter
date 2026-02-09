import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'inherited_altive_chat_room_theme.dart';
import 'model.dart';

/// グリッドで構成されるメニューをオーバーレイで表示する。
class PopupMenuOverlay {
  /// インスタンスを生成する。
  PopupMenuOverlay({
    required this.layout,
    required this.config,
    required this.userMessage,
    required this.widgetKey,
    required this.popupMenuAccessoryBuilder,
  });

  /// 画面端からメニューまでの水平余白。
  static const double horizontalScreenPadding = 10;

  /// メッセージリストの上下方向の安全領域。
  static const double messageListVerticalInset = 15;

  /// 表示するポップアップメニューのレイアウト定義。
  final PopupMenuLayout layout;

  /// ポップアップメニューの見た目設定。
  final PopupMenuConfig config;

  /// ポップアップメニューの対象メッセージ。
  final ChatUserMessage userMessage;

  /// メニュー表示位置の基準となるウィジェットキー。
  final GlobalKey widgetKey;

  /// メニュー付属領域の構築処理。
  final PopupMenuAccessoryBuilder? popupMenuAccessoryBuilder;

  OverlayEntry? _entry;

  /// ポップアップメニューを上下どちらかに表示する。
  ///
  /// [widgetKey] はメニューを表示する元の[Widget]に設定された[GlobalKey]。
  void show({required BuildContext context}) {
    // 行数。
    final row = _calculateRowCount(
      itemCount: layout.buttonItems.length,
      columnCount: layout.column,
    );
    // メニューの幅。
    final menuWidth = config.itemWidth * layout.column;
    // メニューの高さ（吹き出しの矢印を除く）。
    final menuHeight = config.itemHeight * row;

    final arrangement = _calculateArrangement(
      key: widgetKey,
      context: context,
      menuWidth: menuWidth,
      menuHeight: menuHeight,
    );

    Size? accessorySize;

    _entry = OverlayEntry(
      builder: (_) {
        // 正三角形の一辺の長さ。
        final triangleLength = config.arrowHeight / sqrt(3) * 2;

        final accessoryWidget = popupMenuAccessoryBuilder?.call(
          userMessage,
          closePopupMenu: dismiss,
        );
        final accessoryArrangement = accessoryWidget != null
            ? _calculateAccessoryArrangement(
                accessory: accessoryWidget,
                arrangement: arrangement,
                menuWidth: menuWidth,
                menuHeight: menuHeight,
                screenWidth: MediaQuery.widthOf(context),
                measuredSize: accessorySize,
              )
            : null;
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                // 画面がタップダウンされた際にポップアップメニューを閉じる。
                onTapDown: (_) => dismiss(),
                // 縦方向にドラッグされた際にポップアップメニューを閉じる。
                onVerticalDragStart: (_) {
                  dismiss();
                },
                // 横方向にドラッグされた際にポップアップメニューを閉じる。
                onHorizontalDragStart: (_) {
                  dismiss();
                },
              ),
            ),
            // 吹き出しの矢印を表示する。
            Positioned(
              left:
                  arrangement.attachRect.left +
                  arrangement.attachRect.width / 2.0 -
                  // 正三角形の一辺の長さの半分。
                  triangleLength / 2,
              top:
                  arrangement.offset.dy +
                  (arrangement.isArrowDown ? menuHeight : -config.arrowHeight),
              child: BubbleArrow(
                triangleLength: triangleLength,
                arrangement: arrangement,
                config: config,
              ),
            ),
            // メニューを表示する。
            Positioned(
              left: arrangement.offset.dx,
              top: arrangement.offset.dy,
              child: _PopupMenu(
                context: context,
                buttonItems: layout.buttonItems,
                config: config,
                userMessage: userMessage,
                row: row,
                column: layout.column,
                menuWidth: menuWidth,
                menuHeight: menuHeight,
                onDismiss: dismiss,
              ),
            ),
            if (accessoryWidget != null && accessoryArrangement != null)
              Positioned(
                left: accessoryArrangement.left,
                top: accessoryArrangement.top,
                child: _AccessorySizeReporter(
                  onSizeChange: (size) {
                    // アクセサリー領域のサイズが変化した場合に再描画する。
                    accessorySize = size;
                    _entry?.markNeedsBuild();
                  },
                  child: accessoryWidget,
                ),
              ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  /// dismiss を実行する。
  void dismiss() {
    _entry?.remove();
  }

  /// アクセサリー領域の配置情報を求め、メニューとの相対位置を計算する。
  _AccessoryArrangement _calculateAccessoryArrangement({
    required PreferredSizeWidget accessory,
    required _Arrangement arrangement,
    required double menuWidth,
    required double menuHeight,
    required double screenWidth,
    required Size? measuredSize,
  }) {
    // 計測値があればそれを優先し、未計測の場合は preferredSize を基準にする。
    final width = measuredSize != null
        ? measuredSize.width
        : accessory.preferredSize.width;
    final height = measuredSize != null
        ? measuredSize.height
        : accessory.preferredSize.height;

    // メニューの中央に配置するための左端位置候補。
    final leftCandidate = arrangement.offset.dx + (menuWidth - width) / 2;
    // 画面端に被らないように配置するための左端の上限。
    final maxLeft = screenWidth - width - horizontalScreenPadding;
    // 右端へのはみ出しを防ぎつつ候補値を調整する。
    final clampedLeftCandidate = min(leftCandidate, maxLeft);
    // 左端へはみ出しそうな場合には余白ぶんだけ右へ寄せる。
    // 中央寄せできる余裕があればそのまま候補値を採用する。
    final left = max(horizontalScreenPadding, clampedLeftCandidate);

    const verticalMenuAccessoryGap = 10.0;
    // メニューの上下どちらに配置するかで top を決定する。
    final top = arrangement.isArrowDown
        ? arrangement.offset.dy - height - verticalMenuAccessoryGap
        : arrangement.offset.dy + menuHeight + verticalMenuAccessoryGap;

    return (left: left, top: top, width: width);
  }

  // メニューアイテムの数と列数から行数を計算する。
  int _calculateRowCount({required int itemCount, required int columnCount}) {
    // e.g. 3 items & 3 columns => 1 rows
    //      4 items & 3 columns => 2 rows
    return (itemCount - 1) ~/ columnCount + 1;
  }

  /// レイアウト位置を計算する。
  _Arrangement _calculateArrangement({
    required GlobalKey key,
    required BuildContext context,
    required double menuWidth,
    required double menuHeight,
  }) {
    assert(key.currentContext != null, 'No widget in the widget tree.');

    final screenWidth = MediaQuery.widthOf(context);

    // メッセージリスト表示エリアの高さを取得する。
    final listViewKey = InheritedAltiveChatRoomTheme.of(
      context,
    ).messageListViewKey;
    assert(
      listViewKey.currentContext != null,
      'No message list view widget in the widget tree.',
    );
    // メッセージリストWidgetは表示済みなのでRenderBoxを取得可能。
    final messageListViewRenderBox =
        listViewKey.currentContext!.findRenderObject()! as RenderBox;
    final messageListViewHeight = messageListViewRenderBox.size.height;
    final messageListViewOffset = messageListViewRenderBox.localToGlobal(
      Offset.zero,
    );

    assert(
      screenWidth > menuWidth + horizontalScreenPadding * 2,
      'Popup menuWidth exceeds the screen width.',
    );
    assert(
      messageListViewHeight > menuHeight + messageListVerticalInset * 2,
      'Popup menuHeight exceeds the message list view height.',
    );

    // 吹き出しを載せたいWidgetの位置とサイズを取得する。
    // ポップアップメニューWidgetは表示済みなのでRenderBoxを取得可能。
    final renderBox = key.currentContext!.findRenderObject()! as RenderBox;
    // 吹き出しを載せたいWidgetの画面に対する絶対的な位置を取得する。
    final offset = renderBox.localToGlobal(Offset.zero);
    // 吹き出しを載せたいWidgetの位置とサイズを矩形表示で取得する。
    final attachRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );

    // 表示するメニューのx座標を計算する。
    var dx = attachRect.left + attachRect.width / 2 - menuWidth / 2;

    // メニューが画面左端を超えないようにする。
    if (dx < horizontalScreenPadding) {
      dx = horizontalScreenPadding;
    }
    // メニューが画面右端を超えないようにする。
    if (dx + menuWidth > screenWidth) {
      dx = screenWidth - menuWidth - horizontalScreenPadding;
    }

    // 画面上端・下端にメニューが被らないよう、メッセージリスト全体の有効領域を算出する。
    final viewTop = messageListViewOffset.dy + messageListVerticalInset;
    final viewBottom =
        messageListViewOffset.dy +
        messageListViewHeight -
        messageListVerticalInset;
    // 矢印とWidgetの間のスペース。
    const arrowToWidgetSpacing = 3.0;
    // 吹き出し全体を配置できるだけの余白が下側／上側に存在するかを判定する。
    // メニューを表示可能な上側の余白量。
    final availableTopSpace = attachRect.top - viewTop;
    // メニューを表示可能な下側の余白量。
    final availableBottomSpace = viewBottom - attachRect.bottom;
    final requiredSpaceWithArrow =
        menuHeight + config.arrowHeight + arrowToWidgetSpacing;
    final hasSpaceBelow = availableBottomSpace >= requiredSpaceWithArrow;
    final hasSpaceAbove = availableTopSpace >= requiredSpaceWithArrow;

    // 上下の余白の有無に応じてメニューの配置を決定する。
    switch ((hasSpaceBelow, hasSpaceAbove)) {
      // 下側だけ余白があるケース。メッセージ直下に配置して矢印を上向きに出す。
      case (true, false):
        final dy =
            attachRect.bottom + arrowToWidgetSpacing + config.arrowHeight;
        return _Arrangement(
          attachRect: attachRect,
          offset: Offset(dx, dy),
          isArrowDown: false,
        );

      // 上側だけ余白があるケース。メッセージ直上に配置して矢印を下向きに出す。
      case (false, true):
        final dy =
            attachRect.top -
            arrowToWidgetSpacing -
            config.arrowHeight -
            menuHeight;
        return _Arrangement(
          attachRect: attachRect,
          offset: Offset(dx, dy),
          isArrowDown: true,
        );

      // 上下どちらにも余白があるケース。画面中央よりどちら側にメッセージが位置しているかで配置を決める。
      case (true, true):
        final availableHeightCenter =
            messageListViewHeight / 2 + kToolbarHeight;
        final attachRectHeightCenter = (attachRect.top + attachRect.bottom) / 2;
        final isBelowCenter = attachRectHeightCenter > availableHeightCenter;
        final dy = isBelowCenter
            // Widgetの上にメニューを表示する。
            ? attachRect.top -
                  arrowToWidgetSpacing -
                  config.arrowHeight -
                  menuHeight
            // Widgetの下にメニューを表示する。
            : attachRect.bottom + arrowToWidgetSpacing + config.arrowHeight;
        return _Arrangement(
          attachRect: attachRect,
          offset: Offset(dx, dy),
          // メニューが画面中央より下に表示される場合は矢印を下に表示する。
          isArrowDown: isBelowCenter,
        );

      // 上下とも余白が足りない場合は、メニュー本体を画面中央へ寄せて全体が見切れないようにする。
      case (false, false):
        dx = (screenWidth - menuWidth) / 2;
        final dy =
            messageListViewOffset.dy + (messageListViewHeight - menuHeight) / 2;
        // 矢印はタップ元のメッセージを指し示す必要があるため、基準矩形は元のメッセージ位置を保持する。
        final isArrowDown = availableTopSpace < availableBottomSpace;
        return _Arrangement(
          attachRect: attachRect,
          offset: Offset(dx, dy),
          isArrowDown: isArrowDown,
        );
    }
  }
}

/// アクセサリー配置と幅をまとめたレコード型。
typedef _AccessoryArrangement = ({double left, double top, double width});

/// アクセサリーWidgetのサイズを測り、変化した場合のみ親へ通知するためのWidget。
class _AccessorySizeReporter extends SingleChildRenderObjectWidget {
  const _AccessorySizeReporter({required this.onSizeChange, super.child});

  final ValueChanged<Size> onSizeChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _AccessorySizeRenderObject(onSizeChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _AccessorySizeRenderObject renderObject,
  ) {
    renderObject.onSizeChange = onSizeChange;
  }
}

class _AccessorySizeRenderObject extends RenderProxyBox {
  _AccessorySizeRenderObject(this.onSizeChange);

  ValueChanged<Size> onSizeChange;
  Size? _lastSize;

  @override
  void performLayout() {
    super.performLayout();
    // サイズが変化した場合にのみ通知する。
    if (_lastSize != size) {
      _lastSize = size;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (attached) {
          onSizeChange(size);
        }
      });
    }
  }
}

/// BubbleArrow を表すクラス。
class BubbleArrow extends StatelessWidget {
  /// インスタンスを生成する。
  const BubbleArrow({
    super.key,
    required this.triangleLength,
    required this.arrangement,
    required this.config,
  });

  /// 描画する三角形の一辺の長さ。
  final double triangleLength;

  /// 吹き出し配置情報。
  final _Arrangement arrangement;

  /// 矢印描画時に参照するポップアップメニュー設定。
  final PopupMenuConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size.square(triangleLength),
      painter: _EquilateralTrianglePainter(
        isDown: arrangement.isArrowDown,
        color: config.backgroundColor ?? theme.colorScheme.secondary,
      ),
    );
  }
}

class _Arrangement {
  _Arrangement({
    required this.offset,
    required this.attachRect,
    required this.isArrowDown,
  });

  /// メニューの位置。
  Offset offset;

  /// 吹き出しを載せたいWidgetの位置とサイズ。
  ///
  /// この矩形に吹き出しを表示する。
  Rect attachRect;

  /// 吹き出しの矢印を下に表示するかどうか。
  bool isArrowDown;
}

class _PopupMenu extends StatelessWidget {
  const _PopupMenu({
    required this.context,
    required this.buttonItems,
    required this.config,
    required this.userMessage,
    required this.row,
    required this.column,
    required this.menuWidth,
    required this.menuHeight,
    required this.onDismiss,
  });

  final BuildContext context;
  final List<PopupMenuButtonItem> buttonItems;
  final PopupMenuConfig config;
  final ChatUserMessage userMessage;
  final int row;
  final int column;
  final double menuWidth;
  final double menuHeight;
  final VoidCallback onDismiss;

  // 行を作成する。
  List<Widget> _createRowItems({
    required int row,
    required bool showBottomDivider,
  }) {
    // 現在作成しているメニュー欄の最初のインデックス。
    final firstItemIndex = row * column;
    final subItems = buttonItems.sublist(
      firstItemIndex,
      firstItemIndex + column,
    );

    return [
      for (var i = 0; i < subItems.length; i++)
        _MenuItemWidget(
          item: subItems[i],
          config: config,
          userMessage: userMessage,
          // 最終列ではない場合、右側の仕切り線を表示する。
          showRightDivider: i != (column - 1),
          // 最終行ではない場合、下側の仕切り線を表示する。
          showBottomDivider: showBottomDivider,
          onDismiss: onDismiss,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: menuWidth,
      height: menuHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // 1行ずつメニュー欄を作成する。
            for (var i = 0; i < row; i++)
              SizedBox(
                height: config.itemHeight,
                child: Row(
                  children: _createRowItems(
                    row: i,
                    // 最終行ではない場合、下側に仕切り線を表示する。
                    showBottomDivider: i != row - 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemWidget extends StatefulWidget {
  const _MenuItemWidget({
    required this.item,
    required this.config,
    required this.userMessage,
    required this.showRightDivider,
    required this.showBottomDivider,
    required this.onDismiss,
  });

  final PopupMenuButtonItem item;
  final PopupMenuConfig config;
  final ChatUserMessage userMessage;
  // 右側の仕切り線を表示するかどうか。
  final bool showRightDivider;
  // 下側の仕切り線を表示するかどうか。
  final bool showBottomDivider;
  final VoidCallback onDismiss;

  @override
  State<StatefulWidget> createState() {
    return _MenuItemWidgetState();
  }
}

class _MenuItemWidgetState extends State<_MenuItemWidget> {
  /// メニューアイテムの背景色。
  ///
  /// [defaultBackgroundColor]と[highlightColor]で切り替える。
  late Color backgroundColor;

  /// メニューアイテムがタップされていない時の背景色。
  late Color defaultBackgroundColor;

  /// メニューアイテムがタップされた時の背景色。
  late Color highlightColor;

  /// [BuildContext]が必要なので、
  /// [State.initState]ではなく[State.didChangeDependencies]を使用する。
  @override
  void didChangeDependencies() {
    final theme = Theme.of(context);
    defaultBackgroundColor =
        widget.config.backgroundColor ?? theme.colorScheme.secondary;
    highlightColor =
        widget.config.highlightColor ?? theme.colorScheme.surfaceContainerHigh;
    backgroundColor = defaultBackgroundColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;
    final dividerColor = config.dividerColor ?? theme.colorScheme.onPrimary;
    final itemTitle = widget.item.title;
    return GestureDetector(
      // タップ時に背景色をハイライトする。
      onTapDown: (_) {
        setState(() {
          backgroundColor = highlightColor;
        });
      },
      // タップが離れた時に背景色のハイライトをやめる。
      onTapUp: (_) {
        setState(() {
          backgroundColor = defaultBackgroundColor;
        });
      },
      // タップがキャンセルされた時に背景色のハイライトをやめる。
      onTapCancel: () {
        setState(() {
          backgroundColor = defaultBackgroundColor;
        });
      },
      onTap: () {
        widget.item.onTap.call(widget.userMessage);
        widget.onDismiss();
      },
      child: Container(
        width: config.itemWidth,
        height: config.itemHeight,
        decoration: BoxDecoration(color: backgroundColor),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.item.iconWidget,
                if (itemTitle != null) ...[
                  const SizedBox(height: 5),
                  Material(
                    color: theme.colorScheme.surface.withValues(alpha: 0),
                    child: Text(
                      itemTitle,
                      style:
                          config.buttonItemTextStyle ??
                          theme.textTheme.labelSmall!.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            // 右側の仕切り線を表示する。
            if (widget.showRightDivider)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: VerticalDivider(
                  width: 1,
                  indent: config.itemHeight * .1,
                  endIndent: config.itemHeight * .1,
                  color: dividerColor,
                ),
              ),
            // 下側の仕切り線を表示する。
            if (widget.showBottomDivider)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Divider(
                  height: 1,
                  indent: config.itemWidth * .1,
                  endIndent: config.itemWidth * .1,
                  color: dividerColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 正三角形を描画する[CustomPainter]。
///
/// ポップアップメニューの吹き出しで使用する。
class _EquilateralTrianglePainter extends CustomPainter {
  _EquilateralTrianglePainter({required this.color, required this.isDown});

  final Color color;

  /// 吹き出しの矢印を下に表示するかどうか。
  final bool isDown;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final right = size.width;
    // 正三角形の高さ。
    final height = size.width / 2 * sqrt(3);

    final path = Path();
    if (isDown) {
      path
        ..moveTo(right, 0)
        ..lineTo(right / 2, height)
        ..lineTo(0, 0);
    } else {
      path
        ..moveTo(right / 2, 0)
        ..lineTo(right, height)
        ..lineTo(0, height)
        ..lineTo(right / 2, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
