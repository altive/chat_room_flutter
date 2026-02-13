import 'package:flutter/material.dart';

import 'chat_message.dart';

/// ポップアップメニュー周辺の付属Widgetを構築するビルダーの型定義。
/// [PreferredSizeWidget]を利用し、オーバーレイの幅・高さを安定して算出する。
typedef PopupMenuAccessoryBuilder =
    PreferredSizeWidget? Function(
      ChatUserMessage message, {

      /// ポップアップメニューを閉じたいときに呼び出すコールバック。
      required VoidCallback closePopupMenu,
    });
