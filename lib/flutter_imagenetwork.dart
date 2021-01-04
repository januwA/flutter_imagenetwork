import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

export 'image_provider.dart';

bool kValidateStatus(int statusCode) {
  var rcode = statusCode ~/ 100;
  return rcode == 2 || rcode == 3;
}

/// error Status
enum AjanuwImageNetworkErrorType {
  NotImage,
  NotFound,
  EmptyFile,
  HandshakeException,
  HttpException,
  SocketException,
  TimeoutException
}

class AjanuwImageNetworkError {
  final int statusCode;
  final dynamic message;
  final AjanuwImageNetworkErrorType type;
  final Uri uri;

  const AjanuwImageNetworkError({
    this.statusCode,
    this.message,
    this.type,
    this.uri,
  });

  @override
  String toString() =>
      'HTTP request failed, statusCode: $statusCode, $uri, $type, $message';
}

/// error builder
typedef AjanuwImageErrorBuilder = Widget Function(
  BuildContext context,
  AjanuwImageNetworkError error,
  StackTrace stackTrace,
);

class AjanuwImage extends StatefulWidget {
  /// Usage:
  /// ```dart
  ///  AjanuwImage(
  ///   image: AjanuwNetworkImage('https://example.com/logo.jpg'),
  ///   fit: BoxFit.cover,
  ///   loadingWidget: AjanuwImage.defaultLoadingWidget,
  ///   loadingBuilder: AjanuwImage.defaultLoadingBuilder,
  ///   errorBuilder: AjanuwImage.defaultErrorBuilder,
  /// );
  ///
  /// AjanuwImage(
  ///   image: AjanuwNetworkImage('https://i.loli.net/2019/10/01/CVBu2tNMqzOfXHr.png'),
  ///   frameBuilder: AjanuwImage.defaultFrameBuilder,
  /// );
  /// ```
  const AjanuwImage({
    Key key,
    @required this.image,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
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
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.alt,
    this.loadingWidget,
  })  : assert(image != null),
        assert(alignment != null),
        assert(repeat != null),
        assert(filterQuality != null),
        assert(matchTextDirection != null),
        assert(isAntiAlias != null),
        super(key: key);
  final ImageProvider image;
  final ImageFrameBuilder frameBuilder;
  final ImageLoadingBuilder loadingBuilder;
  final Widget loadingWidget;
  final AjanuwImageErrorBuilder errorBuilder;
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
  final bool isAntiAlias;

  /// This text will be displayed if the image is not loaded correctly
  final String alt;

  /// default loadingBuilder
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

  static final ImageFrameBuilder defaultFrameBuilder = (
    BuildContext context,
    Widget child,
    int frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) {
      return child;
    }
    return AnimatedOpacity(
      child: child,
      opacity: frame == null ? 0 : 1,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  };

  /// default loadingWidget
  static final Widget defaultLoadingWidget = Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(child: CircularProgressIndicator()),
  );

  /// default errorBuilder
  static final AjanuwImageErrorBuilder defaultErrorBuilder =
      (BuildContext context, error, stackTrace) {
    print('[AjanuwImageErrorBuilder] ' + error.toString());
    Color color = Theme.of(context).accentColor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
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
    );
  };

  @override
  _AjanuwImageState createState() => _AjanuwImageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ImageProvider>('image', image));
    properties.add(DiagnosticsProperty<Function>('frameBuilder', frameBuilder));
    properties
        .add(DiagnosticsProperty<Function>('loadingBuilder', loadingBuilder));

    /// ===== add props
    properties.add(DiagnosticsProperty<Function>('errorBuilder', errorBuilder));
    properties.add(DiagnosticsProperty<Widget>('loadingWidget', loadingWidget));
    properties.add(StringProperty('alt', alt, defaultValue: null));

    /// =====
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

class _AjanuwImageState extends State<AjanuwImage> with WidgetsBindingObserver {
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  ImageChunkEvent _loadingProgress;
  bool _isListeningToStream = false;
  bool _invertColors;
  int _frameNumber;
  bool _wasSynchronouslyLoaded;
  DisposableBuildContext<State<AjanuwImage>> _scrollAwareContext;
  AjanuwImageNetworkError _lastException;
  StackTrace _lastStack;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollAwareContext = DisposableBuildContext<State<AjanuwImage>>(this);
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    WidgetsBinding.instance.removeObserver(this);
    _stopListeningToStream();
    _scrollAwareContext.dispose();
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
  void didUpdateWidget(AjanuwImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isListeningToStream &&
        (widget.loadingBuilder == null) != (oldWidget.loadingBuilder == null)) {
      _imageStream.removeListener(_getListener());
      _imageStream.addListener(_getListener(recreateListener: true));
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
    _invertColors = MediaQuery.of(context)?.invertColors ??
        SemanticsBinding.instance.accessibilityFeatures.invertColors;
  }

  void _resolveImage() {
    final ScrollAwareImageProvider provider = ScrollAwareImageProvider<dynamic>(
      context: _scrollAwareContext,
      imageProvider: widget.image,
    );
    final ImageStream newStream =
        provider.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null
          ? Size(widget.width, widget.height)
          : null,
    ));
    assert(newStream != null);
    _updateSourceStream(newStream);
  }

  ImageStreamListener _imageStreamListener;
  ImageStreamListener _getListener({bool recreateListener = false}) {
    if (_imageStreamListener == null || recreateListener) {
      _lastException = null;
      _lastStack = null;
      _imageStreamListener = ImageStreamListener(
        _handleImageFrame,
        onChunk: widget.loadingBuilder == null ? null : _handleImageChunk,

        /* 需要判断用户是否监听的错误，否者不对错误进行处理 */
        onError: widget.errorBuilder != null || widget.alt != null
            ? (dynamic error, StackTrace stackTrace) {
                if (error is AjanuwImageNetworkError) {
                  setState(() {
                    _lastException = error;
                    _lastStack = stackTrace;
                  });
                }
                // print('[flutter_imagenetwork] error: ' + error.message);
                // print('[flutter_imagenetwork] stackTrace: ' + stackTrace.toString());
              }
            : null,
      );
    }
    return _imageStreamListener;
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
      _loadingProgress = null;
      _frameNumber = _frameNumber == null ? 0 : _frameNumber + 1;
      _wasSynchronouslyLoaded |= synchronousCall;
    });
  }

  void _handleImageChunk(ImageChunkEvent event) {
    assert(widget.loadingBuilder != null);
    setState(() {
      _loadingProgress = event;
    });
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
    /// 用户如果设置了errorBuilder
    /// 没有设置将不会对错误的图像作出反应
    if (_lastException != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder(context, _lastException, _lastStack);
      }
      if (widget.alt != null) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.broken_image),
            Text(widget.alt),
          ],
        );
      }
      return SizedBox();
    }

    /// 在图像未加载，并且没有获取到进度的时候
    if (widget.loadingWidget != null &&
        _imageInfo == null &&
        _loadingProgress == null) {
      return widget.loadingWidget;
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
