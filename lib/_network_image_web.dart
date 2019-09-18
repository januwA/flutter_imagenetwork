import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'image_provider.dart' as image_provider;

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
  ImageStreamCompleter load(image_provider.AjanuwNetworkImage key) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<AjanuwNetworkImage>('Image key', key),
        ];
      },
    );
  }

  Future<ui.Codec> _loadAsync(AjanuwNetworkImage key) async {
    assert(key == this);

    final Uri resolved = Uri.base.resolve(key.url);
    // This API only exists in the web engine implementation and is not
    // contained in the analyzer summary for Flutter.
    return ui.webOnlyInstantiateImageCodecFromUrl(resolved); // ignore: undefined_function
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final AjanuwNetworkImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
