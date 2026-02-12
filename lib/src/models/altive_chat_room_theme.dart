import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../altive_chat_room.dart';
import 'chat_message.dart';
import 'popup_menu_config.dart';

/// {@template altive_chat_room.AltiveChatRoomTheme}
/// [AltiveChatRoom]のテーマ。
///
/// [ThemeData.light]をベースに上書きして使用する。
/// {@endtemplate}
@immutable
class AltiveChatRoomTheme extends Equatable {
  /// {@macro altive_chat_room.AltiveChatRoomTheme}
  const AltiveChatRoomTheme({
    this.primaryColor,
    this.backgroundColor,
    this.messageInsetsHorizontal = 16,
    this.messageInsetsVertical = 10,
    this.voiceCallMessageInsetsHorizontal = 12,
    this.voiceCallMessageInsetsVertical = 14,
    this.myMessageBoxDecoration,
    this.myMessageHighlightBoxDecoration,
    this.otherUserMessageBoxDecoration,
    this.otherUserMessageHighlightBoxDecoration,
    this.myMessageTextStyle,
    this.myMessageHighlightTextStyle,
    this.myEmojiMessageTextStyle,
    this.mySpecialMessageTextStyle,
    this.otherUserMessageTextStyle,
    this.otherUserHighlightMessageTextStyle,
    this.otherUserEmojiMessageTextStyle,
    this.otherUserSpecialMessageTextStyle,
    this.myReplyToMessageTextStyle,
    this.myReplyToUserNameTextStyle,
    this.myReplyToDividerColor,
    this.otherUserReplyToMessageTextStyle,
    this.otherUserReplyToUserNameTextStyle,
    this.otherUserReplyToDividerColor,
    this.myOgpTitleTextStyle,
    this.myOgpDescriptionTextStyle,
    this.myOgpDividerColor,
    this.otherUserOgpTitleTextStyle,
    this.otherUserOgpDescriptionTextStyle,
    this.otherUserOgpDividerColor,
    this.timeTextStyle,
    this.messageActionButtonStyle,
    this.inputDecorationTheme,
    this.inputBackgroundColor,
    this.popupMenuConfig = const PopupMenuConfig(),
  });

  /// プライマリカラー。
  ///
  /// メッセージバブルの背景色などに使用する。
  final Color? primaryColor;

  /// 背景色。
  final Color? backgroundColor;

  /// メッセージバブルの水平方向の余白。
  final double messageInsetsHorizontal;

  /// メッセージバブルの垂直方向の余白。
  final double messageInsetsVertical;

  /// 音声通話メッセージバブルの水平方向の余白。
  final double voiceCallMessageInsetsHorizontal;

  /// 音声通話メッセージバブルの垂直方向の余白。
  final double voiceCallMessageInsetsVertical;

  /// 自分が送信したメッセージバブルの装飾。
  ///
  /// `null`の場合は、背景色に[ThemeData.primaryColor]が使用される。
  final BoxDecoration? myMessageBoxDecoration;

  /// 自分が送信したメッセージバブルのハイライトされた場合の装飾。
  ///
  /// `null`の場合は、背景色に[ThemeData.highlightColor]を使用し
  /// 枠線に[ColorScheme.outline]が使用される。
  final BoxDecoration? myMessageHighlightBoxDecoration;

  /// 自分以外が送信したメッセージバブルの装飾。
  ///
  /// `null`の場合は、背景色に[ColorScheme.surfaceContainerHighest]が使用される。
  final BoxDecoration? otherUserMessageBoxDecoration;

  /// 自分以外が送信したメッセージバブルのハイライトされた場合の装飾。
  ///
  /// `null`の場合は、背景色に[ThemeData.highlightColor]を使用し
  /// 枠線に[ColorScheme.outline]が使用される。
  final BoxDecoration? otherUserMessageHighlightBoxDecoration;

  /// 自分が送信したテキストメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を[ColorScheme.onPrimary]で上書きしたものが使用される。
  final TextStyle? myMessageTextStyle;

  /// 自分が送信したテキストメッセージのハイライトされた場合のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[700]`で上書きしたものが使用される。
  final TextStyle? myMessageHighlightTextStyle;

  /// 自分が送信した絵文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[myMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? myEmojiMessageTextStyle;

  /// 自分が送信した英数字日本語以外の特殊文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[myMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? mySpecialMessageTextStyle;

  /// 自分以外が送信したテキストメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[600]`で上書きしたものが使用される。
  final TextStyle? otherUserMessageTextStyle;

  /// 自分以外が送信したテキストメッセージのハイライトされた場合のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[700]`で上書きしたものが使用される。
  final TextStyle? otherUserHighlightMessageTextStyle;

  /// 自分以外が送信した絵文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[otherUserMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserEmojiMessageTextStyle;

  /// 自分以外が送信した英数字日本語以外の特殊文字メッセージのテキストスタイル。
  ///
  /// `null`の場合は、[otherUserMessageTextStyle]を使用する。
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserSpecialMessageTextStyle;

  /// 自分が送信したメッセージに対するリプライ先のメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を[ColorScheme.onPrimary]で上書きしたものが使用される。
  final TextStyle? myReplyToMessageTextStyle;

  /// 自分が送信したメッセージに対するリプライ先のユーザー名のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を[ColorScheme.onPrimary]で上書きしたものが使用される。
  final TextStyle? myReplyToUserNameTextStyle;

  /// 自分が送信したメッセージに対するリプライ先の仕切り線の色。
  ///
  /// リプライ先に対してテキストメッセージを送信する場合のみ使用される。
  final Color? myReplyToDividerColor;

  /// 自分以外が送信したメッセージに対するリプライ先のメッセージのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[600]`で上書きしたものが使用される。
  final TextStyle? otherUserReplyToMessageTextStyle;

  /// 自分以外が送信したメッセージに対するリプライ先のユーザー名のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodyMedium]のテキストテーマを使用し
  /// 配色を`Colors.grey[600]`で上書きしたものが使用される。
  final TextStyle? otherUserReplyToUserNameTextStyle;

  /// 自分以外が送信したメッセージに対するリプライ先の仕切り線の色。
  ///
  /// リプライ先に対してテキストメッセージを送信する場合のみ使用される。
  final Color? otherUserReplyToDividerColor;

  /// 自分が送信したメッセージの OGP タイトルのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodySmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? myOgpTitleTextStyle;

  /// 自分が送信したメッセージの OGP 説明のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[myMessageHighlightTextStyle]、
  /// ハイライトされていない場合は[myMessageTextStyle]の配色で上書きされる。
  final TextStyle? myOgpDescriptionTextStyle;

  /// 自分が送信したメッセージの OGP 情報の仕切り線の色。
  ///
  /// OGP 情報が表示される場合のみ使用される。
  final Color? myOgpDividerColor;

  /// 自分以外が送信したメッセージの OGP タイトルのテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.bodySmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserOgpTitleTextStyle;

  /// 自分以外が送信したメッセージの OGP 説明のテキストスタイル。
  ///
  /// `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し
  /// 配色はハイライトされた場合は[otherUserHighlightMessageTextStyle]、
  /// ハイライトされていない場合は[otherUserMessageTextStyle]の配色で上書きされる。
  final TextStyle? otherUserOgpDescriptionTextStyle;

  /// 自分以外が送信したメッセージの OGP 情報の仕切り線の色。
  ///
  /// OGP 情報が表示される場合のみ使用される。
  final Color? otherUserOgpDividerColor;

  /// 時間を表示するテキストのテキストスタイル。
  ///
  /// - [ChatUserMessage]の場合は左右どちらかに表示される。
  ///   - `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用する。
  /// - [ChatSystemMessage]の場合はメッセージバブル内の上部に表示される。
  ///   - `null`の場合は、[TextTheme.labelSmall]のテキストテーマを使用し、
  ///   - 配色は`Colors.white`で上書きしたものが使用される。
  final TextStyle? timeTextStyle;

  /// メッセージ下部に表示する[MessageActionButton]のボタンスタイル。
  ///
  /// [FilledButton]に適用するスタイル。
  final ButtonStyle? messageActionButtonStyle;

  /// テキストフィールドの装飾。
  final InputDecorationTheme? inputDecorationTheme;

  /// テキストフィールドを表示するボトムの背景色。
  final Color? inputBackgroundColor;

  /// ポップアップメニューの設定
  final PopupMenuConfig popupMenuConfig;

  @override
  List<Object?> get props => [
    primaryColor,
    backgroundColor,
    messageInsetsHorizontal,
    messageInsetsVertical,
    voiceCallMessageInsetsHorizontal,
    voiceCallMessageInsetsVertical,
    myMessageBoxDecoration,
    myMessageHighlightBoxDecoration,
    otherUserMessageBoxDecoration,
    otherUserMessageHighlightBoxDecoration,
    myMessageTextStyle,
    myMessageHighlightTextStyle,
    myEmojiMessageTextStyle,
    mySpecialMessageTextStyle,
    otherUserMessageTextStyle,
    otherUserHighlightMessageTextStyle,
    otherUserEmojiMessageTextStyle,
    otherUserSpecialMessageTextStyle,
    myReplyToMessageTextStyle,
    myReplyToUserNameTextStyle,
    myReplyToDividerColor,
    otherUserReplyToMessageTextStyle,
    otherUserReplyToUserNameTextStyle,
    otherUserReplyToDividerColor,
    myOgpTitleTextStyle,
    myOgpDescriptionTextStyle,
    myOgpDividerColor,
    otherUserOgpTitleTextStyle,
    otherUserOgpDescriptionTextStyle,
    otherUserOgpDividerColor,
    timeTextStyle,
    messageActionButtonStyle,
    inputDecorationTheme,
    inputBackgroundColor,
    popupMenuConfig,
  ];
}
