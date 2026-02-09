import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

/// OGP 情報のキャッシュを利用するためのインスタンス。
/// Widget がリビルドされてもインスタンスが破棄されないように、グローバル変数として定義する。
final cachedOgpData = CachedOgpData();

/// OGP 情報のキャッシュを管理するクラス。
/// 同じURLに対して複数回リクエストを送信しないようにするために利用する。
/// どこからでも同じインスタンスを参照できるように、シングルトンパターンを利用している。
class CachedOgpData {
  /// シングルトンのインスタンスを返す。
  factory CachedOgpData() => _instance;

  CachedOgpData._internal();

  static final _instance = CachedOgpData._internal();

  /// URL ごとの OGP 取得処理を保持するキャッシュ。
  final Map<String, Future<OgpData>> cache = {};

  /// URL に対応する OGP 情報を返す。
  Future<OgpData> get(String url) {
    if (!cache.containsKey(url)) {
      cache[url] = OgpData.fromUrl(url);
    }
    return cache[url]!;
  }
}

/// OGP 情報を表すクラス。
class OgpData {
  /// インスタンスを生成する。
  OgpData({
    this.title,
    this.description,
    this.imageUrl,
  });

  /// OGP タイトル。
  final String? title;

  /// OGP 説明文。
  final String? description;

  /// OGP 画像 URL。
  final String? imageUrl;

  /// OGP 情報が利用可能かどうか。
  /// タイトルと説明文、またはタイトルと画像URLが揃っている場合にtrueを返す。
  late final bool isAvailable =
      title != null && (description != null || imageUrl != null);

  /// 指定されたURLからOGP情報を取得する。
  static Future<OgpData> fromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // レスポンスヘッダーから文字エンコーディングを取得する。
      var charset = 'utf-8';
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('charset=')) {
        charset = contentType.split('charset=')[1];
      }

      // 指定されたエンコーディングで生のバイトデータをデコードする。
      final codec = Encoding.getByName(charset);
      final decodedBody =
          codec?.decode(response.bodyBytes) ?? utf8.decode(response.bodyBytes);

      final document = html.parse(decodedBody);

      final title =
          document
              .querySelector('meta[property="og:title"]')
              ?.attributes['content'] ??
          document.querySelector('title')?.text;

      final description =
          document
              .querySelector('meta[property="og:description"]')
              ?.attributes['content'] ??
          document
              .querySelector('meta[name="description"]')
              ?.attributes['content'];

      String? imageUrl;
      imageUrl = document
          .querySelector('meta[property="og:image"]')
          ?.attributes['content'];
      if (imageUrl == null) {
        final imgSrc = document.querySelector('img')?.attributes['src'];
        if (imgSrc != null) {
          // img 要素の src 属性が相対パスの場合、絶対パスに変換する。
          imageUrl = Uri.parse(url).resolve(imgSrc).toString();
        }
      }

      return OgpData(
        title: title,
        description: description,
        imageUrl: imageUrl,
      );
    } else {
      throw Exception('Failed to fetch OGP data');
    }
  }
}
