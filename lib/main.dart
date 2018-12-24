import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:lottie_flutter/lottie_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const List<String> assetNames = const <String>[
  'packages/lottie_flutter/assets/Indicators2.json',
  'packages/lottie_flutter/assets/happy_gift.json',
  'packages/lottie_flutter/assets/empty_box.json',
  'packages/lottie_flutter/assets/muzli.json',
  'packages/lottie_flutter/assets/hamburger_arrow.json',
  'packages/lottie_flutter/assets/motorcycle.json',
  'packages/lottie_flutter/assets/emoji_shock.json',
  'packages/lottie_flutter/assets/checked_done_.json',
  'packages/lottie_flutter/assets/favourite_app_icon.json',
  'packages/lottie_flutter/assets/preloader.json',
  'packages/lottie_flutter/assets/walkthrough.json',
  'packages/lottie_flutter/assets/rrect.json',
];

void main() {
  runApp(new DemoApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Lottie Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LottieDemo(),
    );
  }
}

class LottieDemo extends StatefulWidget {
  const LottieDemo({Key key}) : super(key: key);

  @override
  _LottieDemoState createState() => new _LottieDemoState();
}

class _LottieDemoState extends State<LottieDemo>
    with SingleTickerProviderStateMixin {
  LottieComposition _composition;
  String _assetName;
  AnimationController _controller;
  bool _repeat;

  @override
  void initState() {
    super.initState();

    _repeat = false;
    _loadButtonPressed(assetNames.last);
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadButtonPressed(String assetName) {
    loadAsset(assetName).then((LottieComposition composition) {
      setState(() {
        _assetName = assetName;
        _composition = composition;
        _controller.reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Lottie Demo'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FittedBox(
              child: new DropdownButton<String>(
                items: assetNames
                    .map(
                      (String assetName) => new DropdownMenuItem<String>(
                            child: new Text(
                              assetName,
                              overflow: TextOverflow.clip,
                            ),
                            value: assetName,
                          ),
                    )
                    .toList(),
                hint: const Text('Choose an asset'),
                value: _assetName,
                onChanged: (String val) => _loadButtonPressed(val),
              ),
            ),
            new Text(_composition?.bounds?.size?.toString() ?? ''),
            new Lottie(
              composition: _composition,
              size: const Size(300.0, 300.0),
              controller: _controller,
            ),
            new Slider(
              value: _controller.value,
              onChanged: _composition != null
                  ? (double val) => setState(() => _controller.value = val)
                  : null,
            ),
            new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                    icon: const Icon(Icons.repeat),
                    color: _repeat ? Colors.black : Colors.black45,
                    onPressed: () => setState(() {
                          _repeat = !_repeat;
                          if (_controller.isAnimating) {
                            if (_repeat) {
                              _controller
                                  .forward()
                                  .then<Null>((_) => _controller.repeat());
                            } else {
                              _controller.forward();
                            }
                          }
                        }),
                  ),
                  new IconButton(
                    icon: const Icon(Icons.fast_rewind),
                    onPressed: _controller.value > 0 && _composition != null
                        ? () => setState(() => _controller.reset())
                        : null,
                  ),
                  new IconButton(
                    icon: _controller.isAnimating
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                    onPressed: _controller.isCompleted || _composition == null
                        ? null
                        : () {
                            setState(() {
                              if (_controller.isAnimating) {
                                _controller.stop();
                              } else {
                                if (_repeat) {
                                  _controller.repeat();
                                } else {
                                  _controller.forward();
                                }
                              }
                            });
                          },
                  ),
                  new IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: _controller.isAnimating && _composition != null
                        ? () {
                            _controller.reset();
                          }
                        : null,
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}

Future<LottieComposition> loadAsset(String assetName) async {
  return await rootBundle
      .loadString(assetName)
      .then<Map<String, dynamic>>((String data) => json.decode(data))
      .then((Map<String, dynamic> map) => new LottieComposition.fromMap(map));
}
