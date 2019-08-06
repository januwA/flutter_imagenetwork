import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          AjanuwImage(
            image: AjanuwNetworkImage(
                'https://i.pinimg.com/originals/2f/60/3a/2f603a9e5948a27b9ad8de08306581db.gif'),
            loadingWidget: AjanuwImage.defaultLoadingWidget,
            loadingBuilder: AjanuwImage.defaultLoadingBuilder,
            errorBuilder: AjanuwImage.defaultErrorBuilder,
          ),

          AjanuwImage(
            image:
                AjanuwNetworkImage('https://s2.ax1x.com/2019/05/22/V9fCKH.jpg'),
            fit: BoxFit.cover,
          ),

          AjanuwImage(
            image:
                AjanuwNetworkImage('https://s2.ax1x.com/2019/05/22/V9fCKH.jpg'),
            fit: BoxFit.cover,
            loadingWidget: AjanuwImage.defaultLoadingWidget,
            loadingBuilder: AjanuwImage.defaultLoadingBuilder,
            errorBuilder: AjanuwImage.defaultErrorBuilder,
          ),

          /// 404
          AjanuwImage(
            image: AjanuwNetworkImage('http://example.com/logo.png'),
            loadingWidget: AjanuwImage.defaultLoadingWidget,
            loadingBuilder: AjanuwImage.defaultLoadingBuilder,
            errorBuilder: AjanuwImage.defaultErrorBuilder,
          ),
        ],
      ),
    );
  }
}
