import 'package:flutter/material.dart';

import 'models/altive_chat_room_theme.dart';

/// メッセージカードの意味的な外観。
enum ChatMessageCardStyle {
  /// 誕生日や記念日などのお祝いに使う外観。
  celebration,
}

/// アプリが構築した内容を表示する汎用メッセージカード。
class ChatMessageCard extends StatelessWidget {
  /// 汎用メッセージカードを作成する。
  const ChatMessageCard({
    super.key,
    required this.style,
    required this.isOwnMessage,
    required this.accessibilityLabel,
    required this.header,
    required this.content,
    this.footer,
    this.theme = const AltiveChatRoomTheme(),
  });

  /// カードの意味的な外観。
  final ChatMessageCardStyle style;

  /// ログインユーザーが送信したメッセージかどうか。
  final bool isOwnMessage;

  /// カード用途を説明するローカライズ済み読み上げラベル。
  final String accessibilityLabel;

  /// 見出しや宛名を表示するWidget。
  final Widget header;

  /// 本文を表示するWidget。
  final Widget content;

  /// 補足表示を置く任意のWidget。
  final Widget? footer;

  /// カードへ適用するチャットテーマ。
  final AltiveChatRoomTheme theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadiusDirectional.only(
      topStart: const Radius.circular(20),
      topEnd: const Radius.circular(20),
      bottomStart: Radius.circular(isOwnMessage ? 20 : 8),
      bottomEnd: Radius.circular(isOwnMessage ? 8 : 20),
    ).resolve(Directionality.of(context));
    final backgroundStart =
        theme.celebrationCardBackgroundStart ??
        colorScheme.tertiaryContainer.withValues(alpha: .62);
    final backgroundEnd =
        theme.celebrationCardBackgroundEnd ??
        colorScheme.secondaryContainer.withValues(alpha: .5);
    final border =
        theme.celebrationCardBorder ??
        colorScheme.tertiary.withValues(alpha: .42);
    final foreground =
        theme.celebrationCardForeground ?? colorScheme.onTertiaryContainer;
    final accent = theme.celebrationCardAccent ?? colorScheme.tertiary;

    return Semantics(
      container: true,
      label: accessibilityLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: switch (style) {
            ChatMessageCardStyle.celebration => LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [backgroundStart, backgroundEnd],
            ),
          },
          border: Border.all(color: border),
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _CelebrationCardDecorationPainter(accent),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: IconTheme.merge(
                  data: IconThemeData(color: foreground),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: foreground),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        header,
                        const SizedBox(height: 8),
                        content,
                        if (footer != null) ...[
                          const SizedBox(height: 12),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebrationCardDecorationPainter extends CustomPainter {
  const _CelebrationCardDecorationPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawCircle(
        Offset(size.width * .12, size.height * .18),
        5,
        Paint()..color = accent.withValues(alpha: .2),
      )
      ..drawCircle(
        Offset(size.width * .88, size.height * .3),
        3.5,
        Paint()..color = accent.withValues(alpha: .16),
      )
      ..save()
      ..translate(size.width * .78, size.height * .82)
      ..rotate(38 * 3.141592653589793 / 180)
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-7, -2, 14, 4),
          const Radius.circular(2),
        ),
        Paint()..color = accent.withValues(alpha: .18),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_CelebrationCardDecorationPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
