import 'package:flutter/widgets.dart';

import '_network_image_io.dart' if (dart.library.html) '_network_image_web.dart'
    as network_image;

abstract class AjanuwNetworkImage extends ImageProvider<AjanuwNetworkImage> {
  ///创建一个在给定URL处获取图像的对象。
  ///
  ///参数[url]和[scale]不能为空。
  const factory AjanuwNetworkImage(
    String url, {
    double scale,
    Map<String, String> headers,
    Duration timeout,
  }) = network_image.AjanuwNetworkImage;

  String get url;
  double get scale;
  Duration get timeout;

  /// 将与[HttpClient.get]一起使用以从网络获取图像的HTTP标头。
  ///
  /// 在Web上运行flutter时，不使用标题
  Map<String, String> get headers;

  @override
  ImageStreamCompleter load(AjanuwNetworkImage key, DecoderCallback decode);
}
