import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

enum ImageNetworkErrorType {
  NotImage,
  NotFound,
}

class ImageNetworkError {
  final HttpHeaders headers;
  final int statusCode;
  final dynamic message;
  final ImageNetworkErrorType type;

  ImageNetworkError({
    this.headers,
    this.statusCode,
    this.message,
    this.type,
  });
}

typedef ImageErrorBuilder = Widget Function(
  ImageNetworkError error,
);

abstract class MyNetworkImage extends ImageProvider<MyNetworkImage> {
  ///创建一个在给定URL处获取图像的对象。
  ///
  ///参数[url]和[scale]不能为空。
  const factory MyNetworkImage(
    String url, {
    double scale,
    Map<String, String> headers,
  }) = NetworkImageTest;

  String get url;
  double get scale;

  /// 将与[HttpClient.get]一起使用以从网络获取图像的HTTP标头。
  ///
  /// 在Web上运行flutter时，不使用标题
  Map<String, String> get headers;

  @override
  ImageStreamCompleter load(MyNetworkImage key);
}

class NetworkImageTest extends ImageProvider<MyNetworkImage>
    implements MyNetworkImage {
  /// 创建一个在给定URL处获取图像的对象。
  ///
  /// 参数[url]和[scale]不能为空。
  const NetworkImageTest(
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
  Future<NetworkImageTest> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageTest>(this);
  }

  @override
  ImageStreamCompleter load(MyNetworkImage key) {
    // 将此控制器的所有权移交给[_loadAsync]; 就是它
    // 方法负责在图像时关闭控制器的流
    // 已加载或抛出错误。
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    /// 创建图像流完成者。
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents),

      /// chunkEvents参数是关于图像加载进度的可选通知流,
      ///  如果提供了此流，则流生成的事件将传递到已注册的[ImageChunkListener]（请参阅[addListener]）。
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<MyNetworkImage>('Image key', key),
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
    NetworkImageTest key,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    try {
      assert(key == this);

      /// key 其实就是 MyNetworkImage
      final Uri resolved = Uri.base.resolve(key.url);

      /// 发送请求
      final HttpClientRequest request = await _httpClient.getUrl(resolved);

      /// add headers
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse r =
          await request.close(); /*.timeout(Duration(seconds: 1));*/

      // 处理获取非image资源错误
      // TODO: 处理非image错误
      // if (!_isImage(response.headers.contentType.toString())) {
      //   return null;
      // }

      /// 是否获取成功
      // TODO: 处理非200错误
      if (r.statusCode != HttpStatus.ok) {
        throw FormatException('Not Found'
            // headers: r.headers,
            // statusCode: r.statusCode,
            // message: 'Not Found',
            // type: ImageNetworkErrorType.NotFound,
            );
        // throw NetworkImageLoadException(
        //     statusCode: r.statusCode, uri: resolved);
      }

      /// 把response转成bytes
      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        r,

        /// progress
        onBytesReceived: (int cumulative, int total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );

      /// 没有数据时
      // TODO: 可以让用户操作这个事件
      if (bytes.lengthInBytes == 0)
        throw Exception('NetworkImage is an empty file: $resolved');

      /// 使用[ImageCache]中的[decodingCacheRatioCap]调用[dart：ui]
      return PaintingBinding.instance.instantiateImageCodec(bytes);
    } catch (e) {
      if (e.runtimeType == ImageNetworkError) {
        print(e);
        return null;
      }
      return null;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkImageTest typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}

class MyImage extends StatefulWidget {
  const MyImage({
    Key key,
    @required this.image,
    this.frameBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
  })  : assert(image != null),
        assert(alignment != null),
        assert(repeat != null),
        assert(filterQuality != null),
        assert(matchTextDirection != null),
        super(key: key);
  final ImageProvider image;
  final ImageFrameBuilder frameBuilder;
  final ImageLoadingBuilder loadingBuilder;
  final ImageErrorBuilder errorBuilder;
  final double width;
  final double height;
  final Color color;
  final FilterQuality filterQuality;
  final BlendMode colorBlendMode;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final String semanticLabel;
  final bool excludeFromSemantics;

  @override
  _MyImageState createState() => _MyImageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageProvider>('image', image));
    properties.add(DiagnosticsProperty<Function>('frameBuilder', frameBuilder));
    properties
        .add(DiagnosticsProperty<Function>('loadingBuilder', loadingBuilder));
    properties.add(DiagnosticsProperty<Function>('errorBuilder', errorBuilder));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(EnumProperty<BlendMode>('colorBlendMode', colorBlendMode,
        defaultValue: null));
    properties.add(EnumProperty<BoxFit>('fit', fit, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
        'alignment', alignment,
        defaultValue: null));
    properties.add(EnumProperty<ImageRepeat>('repeat', repeat,
        defaultValue: ImageRepeat.noRepeat));
    properties.add(DiagnosticsProperty<Rect>('centerSlice', centerSlice,
        defaultValue: null));
    properties.add(FlagProperty('matchTextDirection',
        value: matchTextDirection, ifTrue: 'match text direction'));
    properties.add(
        StringProperty('semanticLabel', semanticLabel, defaultValue: null));
    properties.add(DiagnosticsProperty<bool>(
        'this.excludeFromSemantics', excludeFromSemantics));
    properties.add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
  }
}

class _MyImageState extends State<MyImage> with WidgetsBindingObserver {
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  ImageChunkEvent _loadingProgress;
  bool _isListeningToStream = false;
  bool _invertColors;
  int _frameNumber;
  bool _wasSynchronouslyLoaded;
  ImageNetworkError _exception;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    WidgetsBinding.instance.removeObserver(this);
    _stopListeningToStream();
    super.dispose();
  }

  // 在此State对象的依赖项更改时调用
  @override
  void didChangeDependencies() {
    _updateInvertColors();
    _resolveImage();

    if (TickerMode.of(context))
      _listenToStream();
    else
      _stopListeningToStream();

    super.didChangeDependencies();
  }

  // 每当窗口小部件配置更改时调用
  @override
  void didUpdateWidget(MyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isListeningToStream &&
        (widget.loadingBuilder == null) != (oldWidget.loadingBuilder == null)) {
      _imageStream.removeListener(_getListener(oldWidget.loadingBuilder));
      _imageStream.addListener(_getListener());
    }
    if (widget.image != oldWidget.image) _resolveImage();
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    setState(() {
      _updateInvertColors();
    });
  }

  @override
  void reassemble() {
    /// 在用户测试的时候
    /// 以防刷新图像缓存
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _updateInvertColors() {
    _invertColors = MediaQuery.of(context, nullOk: true)?.invertColors ??
        SemanticsBinding.instance.accessibilityFeatures.invertColors;
  }

  void _resolveImage() {
    final ImageStream newStream =
        widget.image.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null
          ? Size(widget.width, widget.height)
          : null,
    ));
    assert(newStream != null);
    _updateSourceStream(newStream);
  }

  ImageStreamListener _getListener([ImageLoadingBuilder loadingBuilder]) {
    loadingBuilder ??= widget.loadingBuilder;

    /// 创建一个新的[ImageStreamListener]
    return ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        /// 在这里图像加载完成了
        /// 进度设置为null
        setState(() {
          _imageInfo = imageInfo;
          _exception = null;
          _loadingProgress = null;
          _frameNumber = _frameNumber == null ? 0 : _frameNumber + 1;
          _wasSynchronouslyLoaded |= synchronousCall;
        });
      },

      /// loadingBuilder
      onChunk: loadingBuilder == null
          ? null
          : (ImageChunkEvent event) {
              /// 加载图片的进度，在这里被设置
              setState(() {
                _loadingProgress = event;
              });
            },

      // 加载图像时发生错误时收到通知的回调。
      // 如果在加载过程中发生错误，将调用[onError]而不是[onImage]。
      onError: (dynamic exception, StackTrace stackTrace) {
        print('onError');
        // 暂时只处理，我抛出的错误
        if (exception.runtimeType is ImageNetworkError) {
          setState(() {
            _exception = exception;
          });
        }
      },
    );
  }

  // 将_imageStream更新为newStream，并移动流侦听器
  // 从旧流注册到新流（如果是监听器的话）
  // 已注册）.
  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream?.key) return;

    if (_isListeningToStream) _imageStream.removeListener(_getListener());

    if (!widget.gaplessPlayback)
      setState(() {
        _imageInfo = null;
      });

    setState(() {
      _loadingProgress = null;
      _frameNumber = null;
      _wasSynchronouslyLoaded = false;
    });

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream.addListener(_getListener());
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream.addListener(_getListener());
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) return;
    _imageStream.removeListener(_getListener());
    _isListeningToStream = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_exception != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(_exception.message)),
      );
    }

    /// 在图像未加载，并且没有获取到进度的时候
    if (_imageInfo == null && _loadingProgress == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    Widget result = RawImage(
      image: _imageInfo?.image,
      width: widget.width,
      height: widget.height,
      scale: _imageInfo?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      invertColors: _invertColors,
      filterQuality: widget.filterQuality,
    );

    if (!widget.excludeFromSemantics) {
      result = Semantics(
        container: widget.semanticLabel != null,
        image: true,
        label: widget.semanticLabel ?? '',
        child: result,
      );
    }

    if (widget.frameBuilder != null)
      result = widget.frameBuilder(
          context, result, _frameNumber, _wasSynchronouslyLoaded);

    if (widget.loadingBuilder != null)
      result = widget.loadingBuilder(context, result, _loadingProgress);

    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ImageStream>('stream', _imageStream));
    description.add(DiagnosticsProperty<ImageInfo>('pixels', _imageInfo));
    description.add(DiagnosticsProperty<ImageChunkEvent>(
        'loadingProgress', _loadingProgress));
    description.add(DiagnosticsProperty<int>('frameNumber', _frameNumber));
    description.add(DiagnosticsProperty<bool>(
        'wasSynchronouslyLoaded', _wasSynchronouslyLoaded));
  }
}

// enum ImageNetworkErrorType {
//   NotImage,
//   NotFound,
// }

// typedef ImageErrorBuilder = Widget Function(
//   BuildContext context,
//   ImageNetworkError error,
// );

// class ImageNetwork extends StatefulWidget {
//   /// Usage:
//   ///
//   /// ```dart
//   ///        // access
//   ///        ImageNetwork(
//   ///          'https://s2.ax1x.com/2019/05/22/V9fCKH.jpg',
//   ///          fit: BoxFit.cover,
//   ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
//   ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
//   ///          errorBuilder: ImageNetwork.defaultErrorBuilder,
//   ///        ),
//   ///
//   ///        // 404
//   ///        ImageNetwork(
//   ///          'http://example.com/logo.png',
//   ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
//   ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
//   ///          errorBuilder: ImageNetwork.defaultErrorBuilder,
//   ///        ),
//   ///
//   ///       // alt
//   ///        ImageNetwork(
//   ///          'http://example.com/logo.png',
//   ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
//   ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
//   ///          alt: 'http://example.com/logo.png',
//   ///        ),
//   ///
//   ///        // not image
//   ///       ImageNetwork(
//   ///          'http://www.example.com/',
//   ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
//   ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
//   ///          errorBuilder: ImageNetwork.defaultErrorBuilder,
//   ///        ),
//   ///```
//   ///
//   const ImageNetwork(
//     this.src, {
//     Key key,
//     this.loadingBuilder,
//     this.loadingWidget,
//     this.fit,
//     this.width,
//     this.height,
//     this.scale = 1.0,
//     this.frameBuilder,
//     this.semanticLabel,
//     this.excludeFromSemantics = false,
//     this.color,
//     this.colorBlendMode,
//     this.alignment = Alignment.center,
//     this.repeat = ImageRepeat.noRepeat,
//     this.centerSlice,
//     this.matchTextDirection = false,
//     this.gaplessPlayback = false,
//     this.filterQuality = FilterQuality.low,
//     this.headers,
//     this.alt,
//     this.errorBuilder,
//   }) : super(key: key);

//   final String src;
//   final BoxFit fit;
//   final double width;
//   final double height;
//   final double scale;
//   final ImageFrameBuilder frameBuilder;
//   final String semanticLabel;
//   final bool excludeFromSemantics;
//   final Color color;
//   final BlendMode colorBlendMode;
//   final AlignmentGeometry alignment;
//   final ImageRepeat repeat;
//   final Rect centerSlice;
//   final bool matchTextDirection;
//   final bool gaplessPlayback;
//   final FilterQuality filterQuality;
//   final Map<String, String> headers;
//   final String alt;
//   final ImageErrorBuilder errorBuilder;
//   final ImageLoadingBuilder loadingBuilder;
//   final Widget loadingWidget;
//   @override
//   _ImageNetworkState createState() => _ImageNetworkState();

//   static final ImageLoadingBuilder defaultLoadingBuilder = (
//     BuildContext context,
//     Widget child,
//     ImageChunkEvent loadingProgress,
//   ) {
//     if (loadingProgress == null) return child;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
//           value: loadingProgress.expectedTotalBytes != null
//               ? loadingProgress.cumulativeBytesLoaded /
//                   loadingProgress.expectedTotalBytes
//               : null,
//         ),
//       ),
//     );
//   };

//   static final Widget defaultLoadingWidget = Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: Center(child: CircularProgressIndicator()),
//   );

//   static final ImageErrorBuilder defaultErrorBuilder = (context, error) {
//     Color color = Theme.of(context).accentColor;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Icon(
//               Icons.broken_image,
//               color: color,
//             ),
//             Text(
//               error.message,
//               style: TextStyle(color: color),
//             ),
//           ],
//         ),
//       ),
//     );
//   };
// }

// class _ImageNetworkState extends State<ImageNetwork> {
//   Uint8List image;
//   ImageChunkEvent loadingProgress;
//   ImageNetworkError error;

//   var _client = http.Client();
//   Widget get child => image != null
//       ? Image.memory(
//           image,
//           scale: widget.scale,
//           frameBuilder: widget.frameBuilder,
//           semanticLabel: widget.semanticLabel,
//           excludeFromSemantics: widget.excludeFromSemantics,
//           width: widget.width,
//           height: widget.height,
//           color: widget.color,
//           colorBlendMode: widget.colorBlendMode,
//           fit: widget.fit,
//           alignment: widget.alignment,
//           repeat: widget.repeat,
//           centerSlice: widget.centerSlice,
//           matchTextDirection: widget.matchTextDirection,
//           gaplessPlayback: widget.gaplessPlayback,
//           filterQuality: widget.filterQuality,
//         )
//       : SizedBox();

//   /// request
//   http.Request get _req {
//     var req = http.Request(
//       'get',
//       Uri.parse(widget.src),
//     );
//     if (widget.headers != null) {
//       for (MapEntry<String, String> m in widget.headers.entries) {
//         req.headers[m.key] = m.value;
//       }
//     }
//     return req;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }

//   Future<void> _init() async {
//     try {
//       http.StreamedResponse r = await _client.send(_req);
//       if (r.statusCode != HttpStatus.ok) {
//         setState(() {
//           error = ImageNetworkError(
//             type: ImageNetworkErrorType.NotFound,
//             headers: r.headers,
//             isRedirect: r.isRedirect,
//             persistentConnection: r.persistentConnection,
//             statusCode: r.statusCode,
//             message: r.reasonPhrase,
//           );
//         });
//         return;
//       }

//       if (!_isImage(r.headers['content-type'])) {
//         setState(() {
//           error = ImageNetworkError(
//             type: ImageNetworkErrorType.NotImage,
//             headers: r.headers,
//             isRedirect: r.isRedirect,
//             persistentConnection: r.persistentConnection,
//             statusCode: r.statusCode,
//             message: 'Not Image',
//           );
//         });
//         return;
//       }
//       List<int> ds = [];
//       r.stream.listen(
//         (List<int> d) {
//           ds.addAll(d);
//           if (mounted) {
//             setState(() {
//               loadingProgress = ImageChunkEvent(
//                 cumulativeBytesLoaded: ds.length,
//                 expectedTotalBytes: r.contentLength,
//               );
//             });
//           }
//         },
//         onDone: () {
//           if (mounted) {
//             setState(() {
//               image = Uint8List.fromList(ds);
//               loadingProgress = null;
//             });
//             PaintingBinding.instance.instantiateImageCodec(image);
//             _client?.close();
//           }
//         },
//       );
//     } on http.ClientException catch (_) {
//       /// 无视掉网络中断错误
//     }
//   }

//   @override
//   void dispose() {
//     _client?.close();
//     super.dispose();
//   }

//   bool _isImage(String contentType) {
//     return contentType.startsWith('image');
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (error != null) {
//       if (widget.errorBuilder != null) {
//         return widget.errorBuilder(context, error);
//       } else if (widget.alt != null) {
//         return Wrap(
//           crossAxisAlignment: WrapCrossAlignment.center,
//           children: [
//             Icon(Icons.broken_image),
//             Text(widget.alt),
//           ],
//         );
//       } else {
//         return SizedBox();
//       }
//     }
//     if (loadingProgress == null &&
//         image == null &&
//         widget.loadingWidget != null) {
//       return widget.loadingWidget;
//     }
//     if (widget.loadingBuilder != null) {
//       return widget.loadingBuilder(
//         context,
//         child,
//         loadingProgress,
//       );
//     } else {
//       return child;
//     }
//   }
// }

// class ImageNetworkError {
//   /// 返回头信息
//   final Map<String, String> headers;

//   /// 是否被重定向
//   final bool isRedirect;

//   /// 服务器是否请求维护持久连接。
//   final bool persistentConnection;

//   /// 响应的状态代码。
//   final int statusCode;

//   /// message
//   final dynamic message;

//   final ImageNetworkErrorType type;

//   ImageNetworkError({
//     this.headers,
//     this.isRedirect,
//     this.persistentConnection,
//     this.statusCode,
//     this.message,
//     this.type,
//   });
// }
