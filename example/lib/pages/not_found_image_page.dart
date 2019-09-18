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
          errorBuilder: (context, error) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('${error.message}: ${error.uri}'),
                Text('statusCode: ${error.statusCode}'),
                // Text('contentType: ${error.headers['contentType']}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
