import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// CachedLocalImage を表すクラス。
class CachedLocalImage extends StatelessWidget {
  /// インスタンスを生成する。
  const CachedLocalImage({
    super.key,
    required this.dataUri,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.filterQuality = FilterQuality.medium,
    required this.errorWidget,
  });

  /// 表示対象の data URI 形式画像文字列。
  final String dataUri;

  /// 画像のフィット方法。
  final BoxFit fit;

  /// 画像の表示幅。
  final double? width;

  /// 画像の表示高さ。
  final double? height;

  /// 描画時のフィルター品質。
  final FilterQuality filterQuality;

  /// 画像デコード失敗時に表示するウィジェット。
  final Widget errorWidget;

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeDataUri(dataUri);
    if (bytes == null) {
      return errorWidget;
    }

    return Image.memory(
      bytes,
      fit: fit,
      width: width,
      height: height,
      filterQuality: filterQuality,
      errorBuilder: (_, _, _) => errorWidget,
    );
  }

  Uint8List? _decodeDataUri(String value) {
    final dataIndex = value.indexOf(',');
    if (dataIndex == -1) {
      return null;
    }
    final body = value.substring(dataIndex + 1);
    try {
      return base64Decode(body);
    } on FormatException {
      return null;
    }
  }
}
