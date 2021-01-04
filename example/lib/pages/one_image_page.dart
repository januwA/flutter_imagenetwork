import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

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
        child: ListView(
          children: [
            //  AjanuwImage(
            //   image: AjanuwNetworkImage(oneImageUrl),
            //   frameBuilder: AjanuwImage.defaultFrameBuilder,
            // ),

            // Image.network('https://i.loli.net/2019/08/29/rsjvxKEl7TiPAQt.jpg'),

            AjanuwImage(
              image: AjanuwNetworkImage(
                'https://i.loli.net/2019/08/29/rsjvxKEl7TiPAQt.jpg',
                timeout: const Duration(seconds: 5),
              ),
              fit: BoxFit.cover,
              loadingWidget: AjanuwImage.defaultLoadingWidget,
              loadingBuilder: AjanuwImage.defaultLoadingBuilder,
              errorBuilder: AjanuwImage.defaultErrorBuilder,
            ),
          ],
        ),
      ),
    );
  }
}
