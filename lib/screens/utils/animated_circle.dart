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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Notifications notifications =
        Provider.of<Notifications>(context, listen: false);
    return ValueListenableBuilder<int>(
        valueListenable: notifications.notificationCnt,
        builder: (BuildContext context, int notificationCnt, Widget child) {
          if (notificationCnt != 0) {
            String numUnread = notificationCnt.toString();
            if (notificationCnt > 99) {
              numUnread = '99+';
            }

            _controller = AnimationController(
              duration: const Duration(milliseconds: 700),
              vsync: this,
            )..forward();

            return ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.bounceOut,
                ),
                child: CircleAvatar(
                    backgroundColor: MyColour.transparent,
                    radius: 8,
                    child: Text(
                      numUnread,
                      style: const TextStyle(
                        color: MyColour.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    )));
          }

          return Container();
        });
  }
}
