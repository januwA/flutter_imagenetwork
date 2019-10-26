import 'package:example/pages/alt_page.dart';
import 'package:example/pages/not_found_image_page.dart';
import 'package:example/pages/not_image_page.dart';
import 'package:flutter/material.dart';
import './pages/one_image_page.dart';

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
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RaisedButton(
                child: Text('one image'),
                onPressed: () => _goPage(OneImagePage()),
              ),
              RaisedButton(
                child: Text('404 image'),
                onPressed: () => _goPage(NotFoundImagePage()),
              ),
              RaisedButton(
                child: Text('not image'),
                onPressed: () => _goPage(NotImagePage()),
              ),
              RaisedButton(
                child: Text('alt'),
                onPressed: () => _goPage(AltPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goPage(Widget route) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => route),
    );
  }
}
