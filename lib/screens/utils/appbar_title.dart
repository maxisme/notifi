import 'package:flutter/material.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/utils/animated_cnt.dart';
import 'package:provider/provider.dart';

class MyAppBarTitle extends StatelessWidget {
  const MyAppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 56),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            alignment: const Alignment(0, 0),
            child: GestureDetector(
              onTap: () {
                Provider.of<Notifications>(context, listen: false)
                    .scrollToTop();
              },
              child: Image.asset('images/bell.png',
                  height: 60, filterQuality: FilterQuality.medium),
            ),
          ),
          Positioned(
            top: 7,
            child: Container(
                padding: const EdgeInsets.only(left: 17.0),
                child: const AnimatedCnt()),
          ),
        ],
      ),
    );
  }
}
