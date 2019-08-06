import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';

class SliverListImagesPage extends StatefulWidget {
  static const routeName = '/SliverListImagesPage';
  @override
  SsliverListImagesPageState createState() => SsliverListImagesPageState();
}

class SsliverListImagesPageState extends State<SliverListImagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(SliverListImagesPage.routeName),
            floating: true,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            for (var i = 0; i < 100; i++) _generatorImage(),
          ]))
        ],
      ),
    );
  }

  _generatorImage() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => _FullImage(
                  src: 'https://s2.ax1x.com/2019/07/02/ZJHWLt.th.jpg',
                )));
      },
      child: AjanuwImage(
        image:
            AjanuwNetworkImage('https://s2.ax1x.com/2019/07/02/ZJHWLt.th.jpg'),
        fit: BoxFit.contain,
        loadingWidget: AjanuwImage.defaultLoadingWidget,
        loadingBuilder: AjanuwImage.defaultLoadingBuilder,
        errorBuilder: AjanuwImage.defaultErrorBuilder,
      ),
    );
  }
}

class _FullImage extends StatefulWidget {
  final String src;

  const _FullImage({Key key, this.src})
      : assert(src != null),
        super(key: key);
  @override
  __FullImageState createState() => __FullImageState();
}

class __FullImageState extends State<_FullImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AjanuwImage(
        image: AjanuwNetworkImage(widget.src),
        fit: BoxFit.contain,
        loadingWidget: AjanuwImage.defaultLoadingWidget,
        loadingBuilder: AjanuwImage.defaultLoadingBuilder,
        errorBuilder: AjanuwImage.defaultErrorBuilder,
      ),
    );
  }
}
