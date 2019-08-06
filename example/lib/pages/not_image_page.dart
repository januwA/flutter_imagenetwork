import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

class NotImagePage extends StatefulWidget {
  static const routeName = '/NotImagePage';
  @override
  _NotImagePageState createState() => _NotImagePageState();
}

class _NotImagePageState extends State<NotImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(NotImagePage.routeName),
      ),
      body: Center(
        child: AjanuwImage(
          image: AjanuwNetworkImage('http://example.com'),
          errorBuilder: (context, error) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('${error.message}: ${error.uri}'),
                Text('statusCode: ${error.statusCode}'),
                Text('contentType: ${error.headers.contentType}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
