import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
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
          // access
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
        ],
      ),
    );
  }
}
