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
    return Scaffold(
      appBar: AppBar(
        title: Text(OneImagePage.routeName),
      ),
      body: Center(
        child: AjanuwImage(
          image:
              AjanuwNetworkImage('https://s2.ax1x.com/2019/07/02/ZJHWLt.jpg'),
          loadingWidget: AjanuwImage.defaultLoadingWidget,
        ),
      ),
    );
  }
}
