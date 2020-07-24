import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: PianoFall(),
  ));
}

class PianoFall extends StatefulWidget {
  @override
  _PianoFallState createState() => _PianoFallState();
}

class _PianoFallState extends State<PianoFall> with TickerProviderStateMixin {
  List<AnimationController> _controller = [null, null, null, null];
  List<Animation<num>> _top = [null, null, null, null];

  int _score = 0;
  List<Color> _switchColor = [
    Colors.black87,
    Colors.black87,
    Colors.black87,
    Colors.black87
  ];
  num _height;
  num _switchWidth;
  bool _stop = false;
  List<List<int>> _randomChoose = [
    [0, 1, 1],
    [0, 1, 0],
    [0, 0, 1],
    [1, 0, 1]
  ];
  Random _random = Random();

  AnimationController _animationController() {
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller[0] = _animationController();
    _controller[1] = _animationController();
    _controller[2] = _animationController();
    _controller[3] = _animationController();
  }

  void _gameOver() {
    for (int i = 0; i < 4; i++) {
      _controller[i].stop();
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game is over"),
          content: Text("Your score = $_score"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                _stop = false;
                _score = 0;
                for (int i = 0; i < 4; i++) {
                  _controller[i].duration = Duration(milliseconds: 1200);
                }
                _startAnimation();
              },
              child: Text("Restart"),
            ),
            FlatButton(
              onPressed: () {
                exit(0);
              },
              child: Text("Exit"),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  void _startAnimation() async {
    for (int i = 0; i < 4; i++) _controller[i].reset();
    await Future.delayed(Duration(milliseconds: 1000));
    _controller[0].forward();
    await Future.delayed(Duration(milliseconds: 800));
    if (!_stop) _controller[1].forward();
    await Future.delayed(Duration(milliseconds: 700));
    if (!_stop) _controller[2].forward();
    await Future.delayed(Duration(milliseconds: 600));
    if (!_stop) _controller[3].forward();
  }

  Animation<double> _tween(num _height, int _index) {
    return Tween<double>(begin: -240, end: _height).animate(_controller[_index])
      ..addListener(() {
        if (_controller[_index].status == AnimationStatus.completed &&
            _stop == false) {
          if (_switchColor[_index] == Colors.black87) {
            _stop = true;
            _gameOver();
          } else {
            if (_randomChoose[_random.nextInt(4)][_random.nextInt(3)] == 1) {
              _switchColor[_index] = Colors.black87;
            } else {
              _switchColor[_index] = null;
            }
            _controller[_index].duration = Duration(
                milliseconds: (_controller[_index].duration.inMilliseconds - 15)
                    .clamp(480, 2000));
            _controller[_index]
              ..reset()
              ..forward();
          }
        }
      });
  }

  @override
  void didChangeDependencies() async {    
    super.didChangeDependencies();
    _height = MediaQuery.of(context).size.height - 230;
    _switchWidth = MediaQuery.of(context).size.width / 4 - 2;
    for (int i = 0; i < 4; i++) {
      _top[i] = _tween(_height, i);
    }
    _startAnimation();
  }

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      _controller[i].dispose();
    }
    super.dispose();
  }

  Positioned _transformSwitch(int _index) {
    return Positioned(
      top: _top[_index].value,
      left: _index * (_switchWidth + 2),
      child: Padding(
        padding: EdgeInsets.only(left: 1, right: 1),
        child: GestureDetector(
          onTap: _switchColor[_index] == Colors.black87
              ? () {
                  _score++;
                  _switchColor[_index] = null;
                }
              : null,
          child: Container(
            height: 240,
            width: _switchWidth,
            decoration: BoxDecoration(
              color: _switchColor[_index],
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
    );
  }

  AnimatedBuilder _animatedBuilder(int _index) {
    return AnimatedBuilder(
      animation: _controller[_index],
      builder: (_, __) {
        return _transformSwitch(_index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _animatedBuilder(0),
          _animatedBuilder(1),
          _animatedBuilder(2),
          _animatedBuilder(3),
        ],
      ),
    );
  }
}
