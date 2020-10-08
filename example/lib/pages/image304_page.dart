import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

class Image304Page extends StatefulWidget {
  static const routeName = '/Image304Page';
  @override
  _Image304PageState createState() => _Image304PageState();
}

class _Image304PageState extends State<Image304Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image304Page'),
      ),
      body: Center(
        child: AjanuwImage(
          image: AjanuwNetworkImage(
            'http://img.zkyimiao.com/Uploads/vod/2020-09-26/5f6ea79fb4edb.jpg',
            timeout: const Duration(seconds: 5),
          ),
          fit: BoxFit.cover,
          loadingWidget: AjanuwImage.defaultLoadingWidget,
          loadingBuilder: AjanuwImage.defaultLoadingBuilder,
          errorBuilder: AjanuwImage.defaultErrorBuilder,
        ),
      ),
    );
  }
}
