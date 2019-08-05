# flutter_imagenetwork

> A widget that loads a network image in flutter can set loading, progress, error, alt.


## install
```
dependencies:
  flutter_imagenetwork: 0.12.0+
```


## example
```dart
ImageNetwork(
  'https://s2.ax1x.com/2019/05/22/V9fCKH.jpg',
  fit: BoxFit.cover,
  loadingWidget: ImageNetwork.defaultLoadingWidget,
  loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  errorBuilder: ImageNetwork.defaultErrorBuilder,
),

// 404
ImageNetwork(
  'http://example.com/logo.png',
  loadingWidget: ImageNetwork.defaultLoadingWidget,
  loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  errorBuilder: ImageNetwork.defaultErrorBuilder,
),

// alt
ImageNetwork(
  'http://example.com/logo.png',
  loadingWidget: ImageNetwork.defaultLoadingWidget,
  loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  alt: 'http://example.com/logo.png',
),

// not image
ImageNetwork(
  'http://www.example.com/',
  loadingWidget: ImageNetwork.defaultLoadingWidget,
  loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  errorBuilder: ImageNetwork.defaultErrorBuilder,
),

// gif
ImageNetwork(
  'https://i.pinimg.com/originals/95/d0/ee/95d0ee08c718bdcd86a65e14251fa91a.gif',
  loadingWidget: ImageNetwork.defaultLoadingWidget,
  loadingBuilder: ImageNetwork.defaultLoadingBuilder,
  errorBuilder: ImageNetwork.defaultErrorBuilder,
  ),
```