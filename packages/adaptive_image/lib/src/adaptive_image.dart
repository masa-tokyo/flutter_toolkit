import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// assetsフォルダに格納された画像をフォーマットに応じて表示するウィジェット
class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({super.key, required this.imagePath});

  /// assetsフォルダに格納されたsvg or ビットマップの画像パス
  ///
  /// ビットマップ画像の場合、ほとんどの環境に対応出来る3倍で書き出しておく。
  /// ref. https://twitter.com/_mono/status/1135377826008272896
  final String imagePath;

  /// 画像パスがsvgかどうかを判断するフラグ
  bool get isSvgImage => imagePath.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return isSvgImage
        ? SvgPicture.asset(imagePath)
        : Image.asset(imagePath, scale: 3);
  }
}
