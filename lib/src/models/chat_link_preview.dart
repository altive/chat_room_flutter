import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'sticker.dart';

/// Webリンクプレビューの画像参照。
@immutable
class ChatLinkPreviewImage extends Equatable {
  /// Webリンクプレビューの画像参照を作成する。
  const ChatLinkPreviewImage({
    required this.resource,
    required this.pixelWidth,
    required this.pixelHeight,
  }) : assert(pixelWidth > 0),
       assert(pixelHeight > 0);

  /// アプリ側の画像loaderへそのまま渡す不透明な参照値。
  final String resource;

  /// 画像のpixel幅。
  final int pixelWidth;

  /// 画像のpixel高さ。
  final int pixelHeight;

  /// 利用可能な縦横比。
  double get aspectRatio => pixelWidth / pixelHeight;

  /// 画像参照と寸法が表示可能かどうか。
  bool get isDisplayable =>
      resource.trim().isNotEmpty && pixelWidth > 0 && pixelHeight > 0;

  @override
  List<Object?> get props => [resource, pixelWidth, pixelHeight];
}

/// Webリンクプレビューの表示値。
@immutable
class ChatLinkPreview extends Equatable {
  /// Webリンクプレビューの表示値を作成する。
  const ChatLinkPreview({
    required this.sourceUrl,
    required this.title,
    this.description,
    this.siteName,
    this.image,
  });

  /// カードを操作した時に開くHTTP(S) URL。
  final Uri sourceUrl;

  /// 1〜200文字のタイトル。
  final String title;

  /// 最大500文字の説明。
  final String? description;

  /// 最大100文字のサイト名。
  final String? siteName;

  /// 任意の代表画像。
  final ChatLinkPreviewImage? image;

  /// 表示に必要な値が有効かどうか。
  bool get isDisplayable =>
      (sourceUrl.scheme == 'http' || sourceUrl.scheme == 'https') &&
      sourceUrl.host.isNotEmpty &&
      title.trim().isNotEmpty &&
      title.characters.length <= 200 &&
      (description == null || description!.characters.length <= 500) &&
      (siteName == null || siteName!.characters.length <= 100);

  @override
  List<Object?> get props => [sourceUrl, title, description, siteName, image];
}

/// 入力中の先頭Web URLを解決する処理。
typedef ChatLinkPreviewResolver =
    Future<ChatLinkPreview?> Function(Uri sourceUrl);

/// Webリンクプレビュー画像を構築する処理。
typedef ChatLinkPreviewImageBuilder =
    Widget Function(BuildContext context, ChatLinkPreviewImage image);

/// Webリンクを操作した時の処理。
typedef ChatWebLinkTapCallback = void Function(Uri sourceUrl);

/// Composerから送信する型付きの値。
@immutable
class ChatComposerSubmission extends Equatable {
  /// Composerから送信する型付きの値を作成する。
  const ChatComposerSubmission({
    required this.text,
    this.sticker,
    this.linkPreview,
  });

  /// 正規化済みの本文。
  final String text;

  /// 選択中のステッカー。
  final Sticker? sticker;

  /// 入力中に解決できた任意のリンクプレビュー。
  ///
  /// 楽観表示用であり、信頼済みの永続化値として扱わない。
  final ChatLinkPreview? linkPreview;

  @override
  List<Object?> get props => [text, sticker, linkPreview];
}
