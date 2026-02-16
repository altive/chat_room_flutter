// NOTE: example は利用例を優先し、可読性のため簡潔な記述を採用する。
// ignore_for_file: altive_lints/avoid_hardcoded_color, altive_lints/avoid_hardcoded_japanese, altive_lints/prefer_clock_now

import 'package:altive_chat_room/altive_chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
      ],
      home: const _ChatPreviewPage(),
    );
  }
}

class _ChatPreviewPage extends StatefulWidget {
  const _ChatPreviewPage();

  @override
  State<_ChatPreviewPage> createState() => _ChatPreviewPageState();
}

class _ChatPreviewPageState extends State<_ChatPreviewPage> {
  late final List<ChatMessage> _messagesState;
  var _localMessageId = 1000;

  @override
  void initState() {
    super.initState();
    _messagesState = List<ChatMessage>.of(_messages);
  }

  void _handleSend(({String text, Sticker? sticker}) value) {
    if (value.text.isEmpty && value.sticker == null) {
      return;
    }

    final message = value.sticker != null
        ? ChatStickerMessage(
            id: 'local_${_localMessageId++}',
            createdAt: DateTime.now(),
            sender: _currentUser,
            sticker: value.sticker!,
          )
        : ChatTextMessage(
            id: 'local_${_localMessageId++}',
            createdAt: DateTime.now(),
            sender: _currentUser,
            text: value.text,
          );

    setState(() {
      _messagesState.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AltiveChatRoomTheme(
      messageInsetsHorizontal: 18,
      messageInsetsVertical: 5,
      backgroundColor: const Color(0xFF242428),
      inputBackgroundColor: const Color(0xFF242428),
      outgoingMessageBoxDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB97A93),
            Color(0xFF845468),
          ],
        ),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0x33FFFFFF)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x8A000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      incomingMessageBoxDecoration: const BoxDecoration(
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
      outgoingMessageTextStyle: const TextStyle(
        color: Color(0xFFF1E8ED),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      incomingMessageTextStyle: const TextStyle(
        color: Color(0xFFF1E8ED),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      timeTextStyle: const TextStyle(
        color: Color(0xFFD6D2D7),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.grey[300],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFF323238),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
          borderSide: BorderSide.none,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1F),
      body: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              AltiveChatRoom(
                theme: theme,
                currentUserId: _currentUser.id,
                messages: _messagesState,
                onSendIconPressed: _handleSend,
                incomingAvatarSizeDimension: 38,
                hintText: 'メッセージを入力...',
                readStatusWidget: const Text(
                  '既読',
                  style: TextStyle(
                    color: Color(0xFFE5DFE5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                showOutgoingMessageAppearAnimation: true,
                outgoingMessageAnimationDuration: const Duration(
                  seconds: 2,
                ),
                outgoingMessageAnimationCurve: Curves.easeOut,
                outgoingMessageAnimationOffset: 14,
                showSendButtonInTextField: true,
                sendButtonWidget: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB97A93),
                        Color(0xFF845468),
                      ],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Icon(
                      Icons.send,
                      color: Color(0xFFF3D7E2),
                      size: 30,
                    ),
                  ),
                ),
                textFieldSuffixBuilder: (_) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Color(0xFFF1E8EE),
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: Color(0xFFF1E8EE),
                          size: 30,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const _ChatHeader(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF3C3B40),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFFF0E8EE),
            size: 30,
          ),
          const SizedBox(width: 6),
          ClipOval(
            child: Image.network(
              _partnerUser.avatarImageUrl!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Yui',
            style: TextStyle(
              color: Color(0xFFF1ECEF),
              fontSize: 42 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Icon(Icons.call_outlined, color: Color(0xFFE9DDE5), size: 36),
          const SizedBox(width: 12),
          const Icon(
            Icons.videocam_outlined,
            color: Color(0xFFE9DDE5),
            size: 38,
          ),
        ],
      ),
    );
  }
}

const _currentUser = ChatUser(
  id: '1',
  name: 'Me',
  avatarImageUrl: 'https://i.pravatar.cc/150?img=32',
);

const _partnerUser = ChatUser(
  id: '2',
  name: 'Yui',
  avatarImageUrl: 'https://i.pravatar.cc/150?img=32',
);

final _messages = [
  ChatTextMessage(
    id: 'm2',
    createdAt: DateTime(2026, 2, 17, 22, 13),
    sender: _partnerUser,
    text: 'よろしくお願いします！',
  ),
  ChatTextMessage(
    id: 'm1',
    createdAt: DateTime(2026, 2, 17, 22, 12),
    sender: _currentUser,
    text: '初めまして！',
    isRead: true,
  ),
];
