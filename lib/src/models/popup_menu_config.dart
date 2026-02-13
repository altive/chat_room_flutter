import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'popup_menu_button_item.dart';

/// {@template altive_chat_room.PopupMenuConfig}
/// ポップアップメニューの設定。
/// {@endtemplate}
@immutable
class PopupMenuConfig extends Equatable {
  /// {@macro altive_chat_room.PopupMenuConfig}
  const PopupMenuConfig({
    this.itemWidth = 72,
    this.itemHeight = 65,
    this.arrowHeight = 12,
    this.buttonItemTextStyle,
    this.backgroundColor,
    this.highlightColor,
    this.dividerColor,
  });

  /// メニューアイテムの幅。
  final double itemWidth;

  /// メニューアイテムの高さ。
  final double itemHeight;

  /// 矢印の高さ。
  final double arrowHeight;

  /// [PopupMenuButtonItem.title]のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し
  /// 配色を[ColorScheme.onSecondary]で上書きしたものが使用される。
  final TextStyle? buttonItemTextStyle;

  /// 背景色。
  ///
  /// `null`の場合は、[ColorScheme.secondary]が使用される。
  final Color? backgroundColor;

  /// タップした際のハイライト色。
  ///
  /// `null`の場合は、`Colors.grey[400]`が使用される。
  final Color? highlightColor;

  /// 仕切りの色。
  ///
  /// `null`の場合は、[ColorScheme.onPrimary]が使用される。
  final Color? dividerColor;

  @override
  List<Object?> get props => [
    itemWidth,
    itemHeight,
    arrowHeight,
    buttonItemTextStyle,
    backgroundColor,
    highlightColor,
    dividerColor,
  ];
}
