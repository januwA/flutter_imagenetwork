import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

class NotFoundImagePage extends StatefulWidget {
  static const routeName = '/NotFoundImagePage';
  @override
  _NotFoundImagePageState createState() => _NotFoundImagePageState();
}

class _NotFoundImagePageState extends State<NotFoundImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(NotFoundImagePage.routeName),
      ),
      body: Center(
        child: AjanuwImage(
          image: AjanuwNetworkImage('http://example.com/logo.png'),
          fit: BoxFit.cover,
          loadingWidget: AjanuwImage.defaultLoadingWidget,
          loadingBuilder: AjanuwImage.defaultLoadingBuilder,
          errorBuilder: AjanuwImage.defaultErrorBuilder,
        ),
      ),
    );
  }
}
