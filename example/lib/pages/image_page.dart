import 'package:flutter/material.dart';

class ImagePage extends StatefulWidget {
  static const routeName = '/ImagePage';
  @override
  IimagePageState createState() => IimagePageState();
}

class IimagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ImagePage'),
      ),
      body: Center(
        child: Image(
          image:
              NetworkImage('https://i.loli.net/2019/08/29/rsjvxKEl7TiPAQtt.jpg'),
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                    : null,
              ),
            );
          },
          errorBuilder:
              (BuildContext context, Object exception, StackTrace stackTrace) {
            // Appropriate logging or analytics, e.g.
            // myAnalytics.recordError(
            //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
            //   exception,
            //   stackTrace,
            // );
            return Text('😢');
          },
        ),
      ),
    );
  }
}
