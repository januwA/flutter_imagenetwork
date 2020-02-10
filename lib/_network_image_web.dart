import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'image_provider.dart' as image_provider;

/// 网络上的网络映像不支持解码到指定大小
class AjanuwNetworkImage
    extends ImageProvider<image_provider.AjanuwNetworkImage>
    implements image_provider.AjanuwNetworkImage {
  const AjanuwNetworkImage(
    this.url, {
    this.scale = 1.0,
    this.headers,
  })  : assert(url != null),
        assert(scale != null);

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String> headers;

  @override
  Future<AjanuwNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AjanuwNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(
      image_provider.AjanuwNetworkImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<AjanuwNetworkImage>(
              'Image key', key as AjanuwNetworkImage),
        ];
      },
    );
  }

  Future<ui.Codec> _loadAsync(AjanuwNetworkImage key, DecoderCallback decode) {
    assert(key == this);

    final Uri resolved = Uri.base.resolve(key.url);
    // This API only exists in the web engine implementation and is not
    // contained in the analyzer summary for Flutter.
    return ui.webOnlyInstantiateImageCodecFromUrl(resolved) as Future<ui.Codec>; // ignore: undefined_function
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AjanuwNetworkImage &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImage')}("$url", scale: $scale)';
}
