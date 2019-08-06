# flutter_imagenetwork

A widget that loads a network image in flutter can set loading, progress, error, alt.


## install
```
dependencies:
  flutter_imagenetwork:
```


## example
```dart
import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart'

AjanuwImage(
  image: AjanuwNetworkImage('https://s2.ax1x.com/2019/05/22/V9fCKH.jpg'),
  fit: BoxFit.cover,
  loadingWidget: AjanuwImage.defaultLoadingWidget,
  loadingBuilder: AjanuwImage.defaultLoadingBuilder,
  errorBuilder: AjanuwImage.defaultErrorBuilder,
),
```