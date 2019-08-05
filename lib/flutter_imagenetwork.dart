import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum ImageNetworkErrorType {
  NotImage,
  NotFound,
}

typedef ImageErrorBuilder = Widget Function(
  BuildContext context,
  ImageNetworkError error,
);

class ImageNetwork extends StatefulWidget {
  /// Usage:
  ///
  /// ```dart
  ///        // access
  ///        ImageNetwork(
  ///          'https://s2.ax1x.com/2019/05/22/V9fCKH.jpg',
  ///          fit: BoxFit.cover,
  ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
  ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  ///          errorBuilder: ImageNetwork.defaultErrorBuilder,
  ///        ),
  ///
  ///        // 404
  ///        ImageNetwork(
  ///          'http://example.com/logo.png',
  ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
  ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  ///          errorBuilder: ImageNetwork.defaultErrorBuilder,
  ///        ),
  ///
  ///       // alt
  ///        ImageNetwork(
  ///          'http://example.com/logo.png',
  ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
  ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  ///          alt: 'http://example.com/logo.png',
  ///        ),
  ///
  ///        // not image
  ///       ImageNetwork(
  ///          'http://www.example.com/',
  ///          loadingWidget: ImageNetwork.defaultLoadingWidget,
  ///          loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  ///          errorBuilder: ImageNetwork.defaultErrorBuilder,
  ///        ),
  ///```
  ///
  const ImageNetwork(
    this.src, {
    Key key,
    this.loadingBuilder,
    this.loadingWidget,
    this.fit,
    this.width,
    this.height,
    this.scale = 1.0,
    this.frameBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.headers,
    this.alt,
    this.errorBuilder,
  }) : super(key: key);

  final String src;
  final BoxFit fit;
  final double width;
  final double height;
  final double scale;
  final ImageFrameBuilder frameBuilder;
  final String semanticLabel;
  final bool excludeFromSemantics;
  final Color color;
  final BlendMode colorBlendMode;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;
  final Map<String, String> headers;
  final String alt;
  final ImageErrorBuilder errorBuilder;
  final ImageLoadingBuilder loadingBuilder;
  final Widget loadingWidget;
  @override
  _ImageNetworkState createState() => _ImageNetworkState();

  static final ImageLoadingBuilder defaultLoadingBuilder = (
    BuildContext context,
    Widget child,
    ImageChunkEvent loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes
              : null,
        ),
      ),
    );
  };

  static final Widget defaultLoadingWidget = Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(child: CircularProgressIndicator()),
  );

  static final ImageErrorBuilder defaultErrorBuilder = (context, error) {
    Color color = Theme.of(context).accentColor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.broken_image,
              color: color,
            ),
            Text(
              error.message,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  };
}

class _ImageNetworkState extends State<ImageNetwork> {
  Uint8List image;
  ImageChunkEvent loadingProgress;
  ImageNetworkError error;

  var _client = http.Client();
  Widget get child => image != null
      ? Image.memory(
          image,
          scale: widget.scale,
          frameBuilder: widget.frameBuilder,
          semanticLabel: widget.semanticLabel,
          excludeFromSemantics: widget.excludeFromSemantics,
          width: widget.width,
          height: widget.height,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,
          fit: widget.fit,
          alignment: widget.alignment,
          repeat: widget.repeat,
          centerSlice: widget.centerSlice,
          matchTextDirection: widget.matchTextDirection,
          gaplessPlayback: widget.gaplessPlayback,
          filterQuality: widget.filterQuality,
        )
      : SizedBox();

  /// request
  http.Request get _req {
    var req = http.Request(
      'get',
      Uri.parse(widget.src),
    );
    if (widget.headers != null) {
      for (MapEntry<String, String> m in widget.headers.entries) {
        req.headers[m.key] = m.value;
      }
    }
    return req;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    http.StreamedResponse r = await _client.send(_req);
    if (r.statusCode != HttpStatus.ok) {
      setState(() {
        error = ImageNetworkError(
          type: ImageNetworkErrorType.NotFound,
          headers: r.headers,
          isRedirect: r.isRedirect,
          persistentConnection: r.persistentConnection,
          statusCode: r.statusCode,
          message: r.reasonPhrase,
        );
      });
      return;
    }

    if (!_isImage(r.headers['content-type'])) {
      setState(() {
        error = ImageNetworkError(
          type: ImageNetworkErrorType.NotImage,
          headers: r.headers,
          isRedirect: r.isRedirect,
          persistentConnection: r.persistentConnection,
          statusCode: r.statusCode,
          message: 'Not Image',
        );
      });
      return;
    }
    List<int> ds = [];
    r.stream.listen(
      (List<int> d) {
        ds.addAll(d);
        setState(() {
          loadingProgress = ImageChunkEvent(
            cumulativeBytesLoaded: ds.length,
            expectedTotalBytes: r.contentLength,
          );
        });
      },
      onDone: () {
        setState(() {
          image = Uint8List.fromList(ds);
          loadingProgress = null;
        });
        _client?.close();
      },
    );
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }

  bool _isImage(String contentType) {
    return contentType.startsWith('image');
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder(context, error);
      } else if (widget.alt != null) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.broken_image),
            Text(widget.alt),
          ],
        );
      } else {
        return SizedBox();
      }
    }
    if (loadingProgress == null &&
        image == null &&
        widget.loadingWidget != null) {
      return widget.loadingWidget;
    }
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder(
        context,
        child,
        loadingProgress,
      );
    } else {
      return child;
    }
  }
}

class ImageNetworkError {
  /// 返回头信息
  final Map<String, String> headers;

  /// 是否被重定向
  final bool isRedirect;

  /// 服务器是否请求维护持久连接。
  final bool persistentConnection;

  /// 响应的状态代码。
  final int statusCode;

  /// message
  final dynamic message;

  final ImageNetworkErrorType type;

  ImageNetworkError({
    this.headers,
    this.isRedirect,
    this.persistentConnection,
    this.statusCode,
    this.message,
    this.type,
  });
}
