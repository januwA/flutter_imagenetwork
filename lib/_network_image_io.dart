import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'flutter_imagenetwork.dart';
import 'image_provider.dart' as image_provider;

class AjanuwNetworkImage
    extends ImageProvider<image_provider.AjanuwNetworkImage>
    implements image_provider.AjanuwNetworkImage {
  /// 创建一个在给定URL处获取图像的对象。
  ///
  /// 参数[url]和[scale]不能为空。
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
    // 将此控制器的所有权移交给[_loadAsync]; 就是它
    // 方法负责在图像时关闭控制器的流
    // 已加载或抛出错误。
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    /// 创建图像流完成者。
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),

      /// chunkEvents参数是关于图像加载进度的可选通知流,
      /// 如果提供了此流，则流生成的事件将传递到已注册的[ImageChunkListener]（请参阅[addListener]）。
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<AjanuwNetworkImage>('Image key', key),
        ];
      },
    );
  }

  // 不要直接访问此字段; 请改用[_httpClient]。
  // 我们将`autoUncompress`设置为false以确保我们可以信任它的值
  // “Content-Length”HTTP标头。 我们会自动解压缩内容
  // 在我们对[consolidateHttpClientResponseBytes]的调用中
  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null)
        client = debugNetworkImageHttpClientProvider();
      return true;
    }());
    return client;
  }

  Future<ui.Codec> _loadAsync(
    AjanuwNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse r =
          await request.close(); /*.timeout(Duration(seconds: 1));*/

      /// 是否获取成功
      if (r.statusCode != HttpStatus.ok) {
        /// 也能收到错误
        /// 程序不会进入调试状态
        return Future.error(
          AjanuwImageNetworkError(
            statusCode: r.statusCode,
            message: 'Not Found',
            uri: resolved,
            type: AjanuwImageNetworkErrorType.NotFound,
          ),
        );

        /// 抛出错误能够收到
        /// 但是程序也会进入调试状态
        // throw NetworkImageLoadException(
        //   statusCode: r.statusCode,
        //   uri: resolved,
        // );
      }
      // 处理获取非image资源错误
      if (!_isImage(r.headers.contentType.toString())) {
        return Future.error(
          AjanuwImageNetworkError(
            // headers: r.headers,
            statusCode: r.statusCode,
            message: 'Not Image',
            uri: resolved,
            type: AjanuwImageNetworkErrorType.NotImage,
          ),
        );
      }

      /// 把response转成bytes
      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        r,
        onBytesReceived: (int cumulative, int total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );

      /// 没有数据时
      if (bytes.lengthInBytes == 0) {
        return Future.error(
          AjanuwImageNetworkError(
            // headers: r.headers,
            statusCode: r.statusCode,
            message: 'NetworkImage is an empty file',
            uri: resolved,
            type: AjanuwImageNetworkErrorType.EmptyFile,
          ),
        );
        // throw Exception('NetworkImage is an empty file: $resolved');
      }

      /// 使用[ImageCache]中的[decodingCacheRatioCap]调用[dart：ui]
      return decode(bytes);
    } finally {
      chunkEvents.close();
    }
  }

  bool _isImage(String contentType) {
    return contentType.startsWith('image');
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final AjanuwNetworkImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
