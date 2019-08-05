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
          // https://i.pinimg.com/originals/2f/60/3a/2f603a9e5948a27b9ad8de08306581db.gif
          // https://s2.ax1x.com/2019/05/22/V9fCKH.jpg
          // Image(
          //   image: NetworkImage(
          //       'https://i.pinimg.com/originals/2f/60/3a/2f603a9e5948a27b9ad8de08306581db.gif'),
          //   fit: BoxFit.fill,
          //   loadingBuilder: (
          //     BuildContext context,
          //     Widget child,
          //     ImageChunkEvent loadingProgress,
          //   ) {
          //     if (loadingProgress == null) return child;
          //     return Center(
          //       child: CircularProgressIndicator(
          //         value: loadingProgress.expectedTotalBytes != null
          //             ? loadingProgress.cumulativeBytesLoaded /
          //                 loadingProgress.expectedTotalBytes
          //             : null,
          //       ),
          //     );
          //   },
          // ),
          SizedBox(height: 10),
          MyImage(
            image: MyNetworkImage(
              // 'https://i.pinimg.com/originals/2f/60/3a/2f603a9e5948a27b9ad8de08306581db.gif',
              'http://example.com/logo.png',
            ),
            loadingBuilder: (
              BuildContext context,
              Widget child,
              ImageChunkEvent loadingProgress,
            ) {
              if (loadingProgress == null) return child;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).accentColor),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
