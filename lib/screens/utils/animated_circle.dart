import 'package:flutter/material.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AnimatedCircle extends StatefulWidget {
  const AnimatedCircle({Key key}) : super(key: key);

  @override
  _AnimatedCircleState createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle>
    with TickerProviderStateMixin {
  AnimationController _controller;
  bool _isShowing;

  @override
  void initState() {
    _isShowing = false;
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Notifications>(
        builder: (BuildContext context, Notifications notifi, Widget child) {
      final int unreadCnt = notifi.unreadCnt;

      if (unreadCnt != 0) {
        String numUnread = unreadCnt.toString();
        if (unreadCnt > 99) {
          numUnread = '99+';
        }

        Duration duration = const Duration();
        if (!_isShowing) {
          duration = const Duration(milliseconds: 700);
        }

        _controller = AnimationController(
          duration: duration,
          vsync: this,
        )..forward();

        _isShowing = true;

        return Container(
            alignment: const Alignment(0.1, 0),
            child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.bounceOut,
                ),
                child: CircleAvatar(
                    backgroundColor: MyColour.red,
                    radius: 10,
                    child: Text(
                      numUnread,
                      style: const TextStyle(
                        color: MyColour.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ))));
      }

      _isShowing = false;
      return Container();
    });
  }
}
