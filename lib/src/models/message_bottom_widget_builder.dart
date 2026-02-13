import 'package:flutter/material.dart';

import 'chat_message.dart';

/// メッセージバブル直下に表示するWidgetを構築するビルダーの型定義。
typedef MessageBottomWidgetBuilder =
    Widget? Function(
      ChatUserMessage message, {
      required bool isOutgoing,
    });
