import 'package:flutter/material.dart';
import 'package:notifi/screens/utils/animated_circle.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:provider/provider.dart';

class MyAppBarTitle extends StatelessWidget {
  const MyAppBarTitle(this._leadingWidth);

  final double _leadingWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: _leadingWidth),
      child: IntrinsicHeight(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              alignment: const Alignment(0, 0),
              child: Image.asset('images/bell.png',
                  height: 60, filterQuality: FilterQuality.medium),
            ),
            Container(
                alignment: const Alignment(0.076, -0.62),
                child: const AnimatedCircle()),
            Positioned(
              top: 40,
              child: Consumer<User>(
                  builder: (BuildContext context, User user, Widget child) {
                if (user.hasError()) {
                  return Row(mainAxisAlignment: MainAxisAlignment.center,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <Widget>[
                        const Icon(
                          Akaricons.circleAlert,
                          color: MyColour.red,
                          size: 11,
                        ),
                        const Text(' Network Error!',
                            style: TextStyle(
                                color: MyColour.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600))
                      ]);
                }
                return Container();
              }),
            )
          ],
        ),
      ),
    );
  }
}
