import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

class AltPage extends StatefulWidget {
  static const routeName = '/AltPage';
  @override
  _AltPageState createState() => _AltPageState();
}

class _AltPageState extends State<AltPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AltPage.routeName),
      ),
      body: Center(
        child: AjanuwImage(
          image: AjanuwNetworkImage('http://example.com/logo.png'),
          // errorBuilder: AjanuwImage.defaultErrorBuilder,
          alt: 'http://example.com/logo.png',
        ),
      ),
    );
  }
}
