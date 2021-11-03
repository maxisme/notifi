import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/utils/loading_gif.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:notifi/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toast/toast.dart';

class NotificationTable extends StatefulWidget {
  const NotificationTable({Key key}) : super(key: key);

  @override
  NotificationTableState createState() => NotificationTableState();
}

class NotificationTableState extends State<NotificationTable>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<TableNotifier>(builder:
        (BuildContext context, TableNotifier reloadTable, Widget child) {
      final Notifications notifications =
          Provider.of<Notifications>(context, listen: false);
      if (notifications.notifications.isNotEmpty) {
        return AnimatedList(
            padding: const EdgeInsets.only(bottom: 10),
            shrinkWrap: true,
            key: notifications.tableKey,
            controller: notifications.tableController,
            itemBuilder: _buildNotification,
            initialItemCount: notifications.length);
      } else {
        // NO NOTIFICATIONS VIEW
        double imageWidth = 150;
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('images/sad.png',
                    width: imageWidth, filterQuality: FilterQuality.high),
                Container(padding: const EdgeInsets.only(top: 30.0)),
                Consumer<User>(
                    builder: (BuildContext context, User user, Widget child) {
                  final String credentials = user.getCredentials();
                  String howToLink = '$httpEndpoint#how-to';
                  Color howToColour = Theme.of(context).colorScheme.primary;
                  Widget credentialsWidget;
                  if (credentials != null) {
                    howToLink = '$httpEndpoint?c=$credentials#how-to';
                    howToColour = Theme.of(context).colorScheme.secondary;
                    credentialsWidget = InkWell(
                        child: Text(credentials,
                            key: Key('credentials'),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 17),
                            textAlign: TextAlign.center),
                        onTap: () {
                          if (Platform.isIOS) {
                            Share.share(credentials);
                          } else {
                            copyText(credentials, context);
                          }
                        });
                  } else {
                    credentialsWidget = LoadingGif();
                  }

                  TextStyle textStyle = TextStyle(
                      color: MyColour.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontFamily: 'Inconsolata');
                  return Column(children: <Widget>[
                    RichText(
                      key: Key('no-notifications'),
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'To receive notifications send ',
                            style: textStyle,
                          ),
                          MouseRegionSpan(
                              mouseCursor: SystemMouseCursors.click,
                              inlineSpan: TextSpan(
                                text: 'HTTP requests',
                                style: textStyle.copyWith(color: howToColour),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    openUrl(howToLink);
                                  },
                              )),
                          TextSpan(
                            text: ' with your unique credentials...',
                            style: textStyle,
                          ),
                        ],
                      ),
                    ),
                    Container(padding: const EdgeInsets.only(top: 10.0)),
                    credentialsWidget
                  ]);
                })
              ]),
        );
      }
    });
  }

  void toggleExpand(BuildContext context, int index) {
    final NotificationUI notification =
        Provider.of<Notifications>(context, listen: false).get(index);

    notification.isExpanded = !notification.isExpanded;

    // mark read
    Provider.of<Notifications>(context, listen: false)
        .markRead(index, isRead: true);
  }

  Widget _buildNotification(
      BuildContext context, int index, Animation<double> animation) {
    final NotificationUI notification =
        Provider.of<Notifications>(context, listen: false).get(index);
    notification.index = index;
    notification.toggleExpand = toggleExpand;

    final Animation<Offset> _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    // slide actions
    List<Widget> actions = <Widget>[
      IconSlideAction(
        caption: 'Title',
        color: MyColour.transparent,
        foregroundColor: MyColour.darkGrey,
        icon: Akaricons.copy,
        onTap: () {
          copyText(notification.title, context);
        },
      ),
      IconSlideAction(
        caption: 'Message',
        color: MyColour.transparent,
        foregroundColor: MyColour.darkGrey,
        icon: Akaricons.copy,
        onTap: () async {
          copyText(notification.message, context);
        },
      ),
    ];

    if (Platform.isIOS || Platform.isAndroid) {
      actions = <Widget>[
        IconSlideAction(
          caption: 'Read',
          color: MyColour.transparent,
          foregroundColor: MyColour.grey,
          icon: Akaricons.check,
          onTap: () {
            Provider.of<Notifications>(context, listen: false)
                .toggleRead(index);
          },
        ),
      ];

      if (notification.link != '') {
        actions.add(IconSlideAction(
          caption: 'Link',
          color: MyColour.transparent,
          foregroundColor: MyColour.grey,
          iconWidget: InkWell(
              onTap: () async {
                await openUrl(notification.link);
                setState(() {
                  Provider.of<Notifications>(context, listen: false)
                      .markRead(notification.index, isRead: true);
                });
              },
              onLongPress: () {
                Toast.show(notification.link, context, gravity: Toast.CENTER);
              },
              child: Icon(
                Akaricons.link,
                color: MyColour.grey,
              )),
        ));
      }
    }

    return SlideTransition(
      position: _offsetAnimation,
      child: AnimatedSize(
          // to animate expand
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          child: Slidable(
              key: Key(notification.id.toString()),
              movementDuration: const Duration(milliseconds: 250),
              actionPane: const SlidableDrawerActionPane(),
              actionExtentRatio: 0.15,
              actions: actions,
              secondaryActions: <Widget>[
                IconSlideAction(
                  color: MyColour.transparent,
                  foregroundColor: MyColour.grey,
                  icon: Akaricons.cross,
                  onTap: () {
                    Provider.of<Notifications>(context, listen: false)
                        .delete(index);
                  },
                ),
              ],
              child: notification)),
    );
  }
}

class MouseRegionSpan extends WidgetSpan {
  MouseRegionSpan({
    @required MouseCursor mouseCursor,
    @required InlineSpan inlineSpan,
  }) : super(
          child: MouseRegion(
            cursor: mouseCursor,
            child: Text.rich(
              inlineSpan,
            ),
          ),
        );
}
