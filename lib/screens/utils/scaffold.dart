import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/utils/animated_cnt.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:provider/provider.dart';


class MyScaffold extends StatelessWidget {
  const MyScaffold({this.body, this.bottomNavigationBar});

  final Widget body;
  final Widget bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    double paddingTop = 0;
    if(MediaQuery.of(context).padding.top > 0){
      paddingTop = MediaQuery.of(context).padding.top - 20.0;
    }
    return MediaQuery.removePadding(
        removeTop: MediaQuery.of(context).padding.top > 0,
        removeBottom: true,
        context: context,
        child: Container(
          color: MyColour.white,
            padding:
                EdgeInsets.only(top: paddingTop),
            child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  shape: Border(
                      bottom:
                          BorderSide(color: Theme.of(context).indicatorColor)),
                  title: Padding(
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
                  ),
                  leading: IconButton(
                      icon: const Icon(Akaricons.gear),
                      onPressed: () async {
                        Navigator.pushNamed(context, '/settings');
                      }),
                ),
                body: body,
                bottomNavigationBar: bottomNavigationBar)));
  }
}
