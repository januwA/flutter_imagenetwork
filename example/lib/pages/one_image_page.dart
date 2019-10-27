import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

import '../global.dart';

class OneImagePage extends StatefulWidget {
  static const routeName = '/OneImagePage';
  @override
  _OneImagePageState createState() => _OneImagePageState();
}

class _OneImagePageState extends State<OneImagePage> {
  @override
  Widget build(BuildContext context) {
    // Image()
    return Scaffold(
      appBar: AppBar(
        title: Text(OneImagePage.routeName),
      ),
      body: Center(
        child: AjanuwImage(
          image: AjanuwNetworkImage(oneImageUrl),
          frameBuilder: AjanuwImage.defaultFrameBuilder,
        ),
      ),
    );
  }
}
