# flutter_imagenetwork

A widget that loads a network image in flutter can set loading, progress, error, alt.


## install
```
dependencies:
  flutter_imagenetwork:
```


## example
```dart
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart'

AjanuwImage(
  image: AjanuwNetworkImage('https://i.loli.net/2019/10/01/CVBu2tNMqzOfXHr.png'),
  fit: BoxFit.cover,
  loadingWidget: AjanuwImage.defaultLoadingWidget,
  loadingBuilder: AjanuwImage.defaultLoadingBuilder,
  errorBuilder: AjanuwImage.defaultErrorBuilder,
)


AjanuwImage(
  image: AjanuwNetworkImage('https://i.loli.net/2019/10/01/CVBu2tNMqzOfXHr.png'),
  frameBuilder: AjanuwImage.defaultFrameBuilder,
)
```