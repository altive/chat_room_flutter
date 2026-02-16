// NOTE: example は利用例を優先し、可読性のため簡潔な記述を採用する。
// ignore_for_file: altive_lints/avoid_hardcoded_color, altive_lints/prefer_clock_now

import 'dart:async';

import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  runApp(
    const MaterialApp(
      home: _HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
      ],
    ),
  );
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  late final List<ChatMessage> _directMessagesState;
  var _localMessageId = 100000;

  @override
  void initState() {
    super.initState();
    _directMessagesState = List<ChatMessage>.of(_directMessages);
  }

  void _handleSendDirect(({String text, Sticker? sticker}) value) {
    if (value.text.isEmpty && value.sticker == null) {
      return;
    }

    final localMessage = value.sticker != null
        ? ChatStickerMessage(
            id: 'local_${_localMessageId++}',
            createdAt: DateTime.now(),
            sender: _user1,
            sticker: value.sticker!,
          )
        : ChatTextMessage(
            id: 'local_${_localMessageId++}',
            createdAt: DateTime.now(),
            sender: _user1,
            text: value.text,
          );

    setState(() {
      _directMessagesState.insert(0, localMessage);
    });

    if (value.text.isNotEmpty) {
      _showSnackBar(context: context, text: '${value.text} is sent');
    }
    if (value.sticker != null) {
      _showSnackBar(context: context, text: 'Sticker is sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    const theme = AltiveChatRoomTheme(
      outgoingMessageBoxDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCA8DA3),
            Color(0xFF996A7F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      incomingMessageBoxDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A646B),
            Color(0xFF555055),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      outgoingMessageTextStyle: TextStyle(
        color: Color(0xFFEDE6EA),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      incomingMessageTextStyle: TextStyle(
        color: Color(0xFFF0ECEF),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(20),
            child: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.group),
                  text: 'Direct',
                ),
                Tab(
                  icon: Icon(Icons.group_add),
                  text: 'Group',
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            AltiveChatRoom(
              theme: theme,
              currentUserId: '1',
              messages: _directMessagesState,
              pendingMessageIds: _directMessagesState.isEmpty
                  ? const []
                  : ['1'],
              onSendIconPressed: _handleSendDirect,
              onRefresh: () async {
                _showSnackBar(context: context, text: 'onRefresh is called');
              },
              onScrollToTop: () {
                _showSnackBar(
                  context: context,
                  text: 'onScrollToTop is called',
                );
              },
              dateTextBuilder: ({required String dateText}) => Text(
                dateText,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              onAvatarTap: (user) {
                _showSnackBar(context: context, text: '${user.name} is tapped');
              },
              onImageMessageTap:
                  ({
                    required imageUrls,
                    required index,
                  }) {
                    _showSnackBar(
                      context: context,
                      text:
                          '''Image message is tapped (index: $index, urls: ${imageUrls.length})''',
                    );
                  },
              onStickerMessageTap: (message) {
                _showSnackBar(
                  context: context,
                  text: 'Sticker message is tapped',
                );
              },
              onActionButtonTap: (value) {
                _showSnackBar(
                  context: context,
                  text: 'Button is tapped: $value',
                );
              },
              showOutgoingMessageAppearAnimation: true,
              outgoingMessageAnimationDuration: const Duration(
                milliseconds: 400,
              ),
              outgoingMessageAnimationCurve: Curves.easeOut,
              outgoingMessageAnimationOffset: 14,
              messageBottomWidgetBuilder:
                  (message, {required bool isOutgoing}) =>
                      _MessageBottomWidgets(
                        message: message,
                        isOutgoing: isOutgoing,
                        showReactions: message.id == '1',
                      ),
              popupMenuAccessoryBuilder:
                  (
                    message, {
                    required closePopupMenu,
                  }) {
                    return _ReactionBar(
                      emojis: const ['👍', '🎉', '👏', '❤️', '😂'],
                      closePopupMenu: closePopupMenu,
                    );
                  },
              sendButtonIcon: const Icon(Icons.send_sharp),
              expandButtonIcon: const Icon(Icons.arrow_forward_ios_sharp),
              textFieldSuffixBuilder: (type) {
                return switch (type) {
                  MessageInputType.text => const Icon(Icons.emoji_emotions),
                  MessageInputType.sticker => const Icon(Icons.text_fields),
                };
              },
              bottomLeadingWidgets: [
                IconButton(
                  icon: const Icon(Icons.add),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _showSnackBar(
                      context: context,
                      text: 'Add icon is pressed',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _showSnackBar(
                      context: context,
                      text: 'Camera icon is pressed',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.photo_outlined),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _showSnackBar(
                      context: context,
                      text: 'Photo icon is pressed',
                    );
                  },
                ),
              ],
              stickerPackages: _stickerPackages,
              outgoingTextMessagePopupMenuLayout: PopupMenuLayout(
                // 2 * 2のレイアウトで表示する。
                column: 2,
                // 4つのボタンを表示する。
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Keep',
                    iconWidget: const Icon(
                      Icons.bookmarks_outlined,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Keep button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Reply',
                    iconWidget: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Reply button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Copy',
                    iconWidget: const Icon(
                      Icons.copy_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Copy button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Cancel',
                    iconWidget: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Cancel button is tapped',
                      );
                    },
                  ),
                ],
              ),
              outgoingImageMessagePopupMenuLayout: PopupMenuLayout(
                // 1 * 3のレイアウトで表示する。
                column: 3,
                // 3つのボタンを表示する。
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Keep',
                    iconWidget: const Icon(
                      Icons.bookmarks_outlined,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Keep button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Reply',
                    iconWidget: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Reply button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Cancel',
                    iconWidget: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Cancel button is tapped',
                      );
                    },
                  ),
                ],
              ),
              outgoingStickerMessagePopupMenuLayout: PopupMenuLayout(
                // 1 * 2のレイアウトで表示する。
                column: 2,
                // 2つのボタンを表示する。
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Keep',
                    iconWidget: const Icon(
                      Icons.bookmarks_outlined,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Keep button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Cancel',
                    iconWidget: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Cancel button is tapped',
                      );
                    },
                  ),
                ],
              ),
              outgoingVoiceCallMessagePopupMenuLayout: PopupMenuLayout(
                column: 1,
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Reply',
                    iconWidget: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Reply button is tapped',
                      );
                    },
                  ),
                ],
              ),
              incomingTextMessagePopupMenuLayout: PopupMenuLayout(
                // 1 * 3のレイアウトで表示する。
                column: 3,
                // 3つのボタンを表示する。
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Keep',
                    iconWidget: const Icon(
                      Icons.bookmarks_outlined,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Keep button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Reply',
                    iconWidget: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Reply button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Copy',
                    iconWidget: const Icon(
                      Icons.copy_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Copy button is tapped',
                      );
                    },
                  ),
                ],
              ),
              incomingImageMessagePopupMenuLayout: PopupMenuLayout(
                // 1 * 2のレイアウトで表示する。
                column: 2,
                // 2つのボタンを表示する。
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Keep',
                    iconWidget: const Icon(
                      Icons.bookmarks_outlined,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Keep button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Reply',
                    iconWidget: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Reply button is tapped',
                      );
                    },
                  ),
                ],
              ),
              incomingStickerMessagePopupMenuLayout: PopupMenuLayout(
                // 1 * 2のレイアウトで表示する。
                column: 2,
                // 2つのボタンを表示する。
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Keep',
                    iconWidget: const Icon(
                      Icons.bookmarks_outlined,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Keep button is tapped',
                      );
                    },
                  ),
                  PopupMenuButtonItem(
                    title: 'Reply',
                    iconWidget: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Reply button is tapped',
                      );
                    },
                  ),
                ],
              ),
              incomingVoiceCallMessagePopupMenuLayout: PopupMenuLayout(
                column: 1,
                buttonItems: [
                  PopupMenuButtonItem(
                    title: 'Reply',
                    iconWidget: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),
                    onTap: (userMessage) {
                      _showSnackBar(
                        context: context,
                        text: 'Reply button is tapped',
                      );
                    },
                  ),
                ],
              ),
            ),
            AltiveChatRoom(
              isGroupChat: true,
              theme: theme,
              currentUserId: '1',
              messages: _groupMessages,
              onSendIconPressed: (value) {
                if (value.text.isNotEmpty) {
                  _showSnackBar(
                    context: context,
                    text: '${value.text} is sent',
                  );
                }
                if (value.sticker != null) {
                  _showSnackBar(
                    context: context,
                    text: 'Sticker is sent',
                  );
                }
              },
              messageBottomWidgetBuilder:
                  (message, {required bool isOutgoing}) =>
                      _MessageBottomWidgets(
                        message: message,
                        isOutgoing: isOutgoing,
                        showReactions: message.id == '1',
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

const _user1 = ChatUser(
  id: '1',
  name: 'Andrew',
  avatarImageUrl: 'https://i.pravatar.cc/150?img=11',
);

const _user2 = ChatUser(
  id: '2',
  name: 'Ben',
  avatarImageUrl: 'https://i.pravatar.cc/150?img=12',
);

const _user3 = ChatUser(
  id: '3',
  name: 'Charlie',
  defaultAvatarImageAssetPath: 'assets/avatar.png',
);

final List<ChatMessage> _directMessages = [
  // 文章が短いテキストメッセージ。
  ChatTextMessage(
    id: '1',
    createdAt: DateTime.now(),
    sender: _user1,
    text: 'Hello',
  ),
  // 文章が長いテキストメッセージ。
  ChatTextMessage(
    id: '2',
    createdAt: DateTime.now(),
    sender: _user2,
    text:
        'Hi. My name is Ben. I’m 20 years old. '
        'I’m from Tokyo. I work at a restaurant. '
        'And I like playing TV games. That’s all. Nice to meet you.',
  ),
  // リンク付きのテキストメッセージ。
  ChatTextMessage(
    id: '3',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    sender: _user2,
    text: 'This is my X account. https://x.com/elonmusk',
  ),
  // ハイライトされたテキストメッセージ。
  ChatTextMessage(
    id: '4',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    sender: _user1,
    text: 'Invitation accepted.',
    highlight: true,
    isRead: true,
  ),
  // ハイライトされたテキストメッセージ。
  ChatTextMessage(
    id: '5',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    sender: _user2,
    text: 'Invited to group chat.',
    highlight: true,
  ),
  // 縦に長い画像
  ChatImagesMessage(
    id: '6',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    sender: _user2,
    imageUrls: const ['https://picsum.photos/100/300'],
  ),
  // 横に長い画像
  ChatImagesMessage(
    id: '7',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    sender: _user1,
    imageUrls: const ['https://picsum.photos/300/100'],
    isRead: true,
  ),
  // 大きい画像
  ChatImagesMessage(
    id: '8',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    sender: _user2,
    imageUrls: const ['https://picsum.photos/1000/1000'],
  ),
  // 複数画像（2枚）
  ChatImagesMessage(
    id: '8a',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    sender: _user1,
    imageUrls: const [
      'https://picsum.photos/400/400',
      'https://picsum.photos/401/400',
    ],
    isRead: true,
  ),
  // 複数画像（3枚）
  ChatImagesMessage(
    id: '8b',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    sender: _user2,
    imageUrls: const [
      'https://picsum.photos/402/400',
      'https://picsum.photos/403/400',
      'https://picsum.photos/404/400',
    ],
  ),
  // 複数画像（5枚）
  ChatImagesMessage(
    id: '8c',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    sender: _user1,
    imageUrls: const [
      'https://picsum.photos/405/400',
      'https://picsum.photos/406/400',
      'https://picsum.photos/407/400',
      'https://picsum.photos/408/400',
      'https://picsum.photos/409/400',
    ],
    isRead: true,
  ),
  // ステッカーメッセージ。
  ChatStickerMessage(
    id: '9',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    sender: _user1,
    sticker: const Sticker(
      id: 11,
      imageUrl: 'https://img.skin/200x200/transparent?text=1_1',
    ),
    isRead: true,
  ),
  // ステッカーメッセージ。
  ChatStickerMessage(
    id: '10',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    sender: _user2,
    sticker: const Sticker(
      id: 21,
      imageUrl: 'https://img.skin/200x200/transparent?text=2_1',
    ),
  ),
  // ボタン付きのテキストメッセージ。
  ChatTextMessage(
    id: '11',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    sender: _user2,
    text: 'Please press the button.',
    button: const MessageActionButton(
      text: 'Button',
      value: 'button_value',
    ),
  ),
  // システムメッセージ。
  ChatSystemMessage(
    id: '12',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    text: 'Ben exited this room.',
  ),
  // リプライメッセージ。
  // テキストメッセージに対してテキストメッセージを返信。
  ChatTextMessage(
    id: '13',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    sender: _user1,
    text: 'Hello',
    replyTo: ChatTextMessage(
      id: '1',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      sender: _user2,
      text: 'Hi',
    ),
  ),
  // リプライメッセージ。
  // 画像メッセージに対してテキストメッセージを返信。
  ChatTextMessage(
    id: '14',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    sender: _user2,
    text: 'Hello',
    replyTo: ChatImagesMessage(
      id: '6',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      sender: _user1,
      imageUrls: const ['https://picsum.photos/100/300'],
    ),
  ),
  // リプライメッセージ。
  // ステッカーメッセージに対してテキストメッセージを返信。
  ChatTextMessage(
    id: '15',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    sender: _user1,
    text: 'Hello',
    isRead: true,
    replyTo: ChatStickerMessage(
      id: '9',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      sender: _user2,
      sticker: const Sticker(
        id: 11,
        imageUrl: 'https://img.skin/200x200/transparent/ffffff?text=1_1',
      ),
    ),
  ),
  // OGP データ付きのテキストメッセージ。
  ChatTextMessage(
    id: '16',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    sender: _user2,
    text: 'Look at this link! https://www.google.com/',
  ),
  ChatTextMessage(
    id: '17',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    sender: _user1,
    text: 'Look at this link! https://www.yahoo.co.jp/',
    isRead: true,
  ),
  // 音声通話メッセージ（通話成立）。
  ChatVoiceCallMessage(
    id: '18',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    sender: _user1,
    voiceCallType: VoiceCallType.connected,
    durationSeconds: 210,
  ),
  // 音声通話メッセージ（不在着信）。
  ChatVoiceCallMessage(
    id: '19',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    sender: _user2,
    voiceCallType: VoiceCallType.unanswered,
  ),
];

class _MessageBottomWidgets extends StatelessWidget {
  const _MessageBottomWidgets({
    required this.message,
    required this.isOutgoing,
    required this.showReactions,
  });

  final ChatUserMessage message;
  final bool isOutgoing;
  final bool showReactions;

  static const _reactions = [
    ('👍', 3, true),
    ('🥹', 2, false),
  ];

  @override
  Widget build(BuildContext context) {
    if (!showReactions) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Wrap(
        alignment: isOutgoing ? WrapAlignment.end : WrapAlignment.start,
        children: [
          for (final (emoji, count, reactedByMe) in _reactions)
            InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () {
                _showSnackBar(
                  context: context,
                  text: 'Reaction button is tapped: $emoji',
                );
              },
              // タップ範囲を広げるためにPaddingを追加
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: reactedByMe ? Colors.orange : Colors.grey[300]!,
                    ),
                    color: Colors.white,
                  ),
                  child: Text('$emoji$count'),
                ),
              ),
            ),
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () {
              _showSnackBar(
                context: context,
                text: 'Reaction add button is tapped',
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.add_reaction_outlined,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionBar extends StatelessWidget implements PreferredSizeWidget {
  const _ReactionBar({
    required this.emojis,
    required this.closePopupMenu,
  });

  final List<String> emojis;
  final VoidCallback closePopupMenu;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Wrap(
        spacing: 4,
        children: [
          for (final emoji in emojis)
            _ReactionChip(
              emoji: emoji,
              closePopupMenu: closePopupMenu,
            ),
          _AddReactionButton(
            closePopupMenu: closePopupMenu,
          ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.emoji,
    required this.closePopupMenu,
  });

  final String emoji;
  final VoidCallback closePopupMenu;

  @override
  Widget build(BuildContext context) {
    return _ReactionTile(
      onTap: () {
        _showSnackBar(
          context: context,
          text: 'Reaction bar tapped: $emoji',
        );
        closePopupMenu();
      },
      child: Padding(
        // 絵文字の位置を調整する。
        padding: const EdgeInsets.only(left: 3, bottom: 1),
        child: Text(emoji),
      ),
    );
  }
}

class _AddReactionButton extends StatelessWidget {
  const _AddReactionButton({
    required this.closePopupMenu,
  });

  final VoidCallback closePopupMenu;

  @override
  Widget build(BuildContext context) {
    return _ReactionTile(
      onTap: () {
        _showSnackBar(
          context: context,
          text: 'Reaction added: 👍',
        );
        closePopupMenu();
      },
      child: const Icon(
        Icons.add_reaction_outlined,
        size: 16,
        color: Colors.black54,
      ),
    );
  }
}

/// リアクション用タイル。
/// `Ink` を使いリップルが装飾上に描かれるように調整する。
class _ReactionTile extends StatelessWidget {
  const _ReactionTile({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(
      Radius.circular(4),
    );

    return SizedBox.square(
      dimension: 32,
      child: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: borderRadius,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

final _groupMessages = [
  ChatTextMessage(
    id: '1',
    createdAt: DateTime.now(),
    sender: _user1,
    text: 'Hello',
  ),
  ChatTextMessage(
    id: '2',
    createdAt: DateTime.now(),
    sender: _user2,
    text: 'This is my X account. https://x.com/elonmusk',
  ),
  ChatTextMessage(
    id: '3',
    createdAt: DateTime.now(),
    sender: _user3,
    text: 'Hello',
  ),
];

void _showSnackBar({
  required BuildContext context,
  required String text,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 1),
    ),
  );
}

final _stickerPackages = [
  const StickerPackage(
    id: 1,
    tabStickerImageUrl: 'https://img.skin/200x200/transparent?text=1_1',
    stickers: [
      Sticker(
        id: 11,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_1',
      ),
      Sticker(
        id: 12,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_2',
      ),
      Sticker(
        id: 13,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_3',
      ),
      Sticker(
        id: 14,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_4',
      ),
      Sticker(
        id: 15,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_5',
      ),
      Sticker(
        id: 16,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_6',
      ),
      Sticker(
        id: 17,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_7',
      ),
      Sticker(
        id: 18,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_8',
      ),
      Sticker(
        id: 19,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_9',
      ),
      Sticker(
        id: 20,
        imageUrl: 'https://img.skin/200x200/transparent?text=1_10',
      ),
    ],
  ),
  const StickerPackage(
    id: 2,
    tabStickerImageUrl: 'https://img.skin/200x200/transparent?text=2_1',
    stickers: [
      Sticker(
        id: 21,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_1',
      ),
      Sticker(
        id: 22,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_2',
      ),
      Sticker(
        id: 23,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_3',
      ),
      Sticker(
        id: 24,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_4',
      ),
      Sticker(
        id: 25,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_5',
      ),
      Sticker(
        id: 26,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_6',
      ),
      Sticker(
        id: 27,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_7',
      ),
      Sticker(
        id: 28,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_8',
      ),
      Sticker(
        id: 29,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_9',
      ),
      Sticker(
        id: 30,
        imageUrl: 'https://img.skin/200x200/transparent?text=2_10',
      ),
    ],
  ),
];
