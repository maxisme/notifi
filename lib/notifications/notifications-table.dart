import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationTable extends StatefulWidget {
  NotificationTable({Key key}) : super(key: key);

  @override
  NotificationTableState createState() => NotificationTableState();
}

class NotificationTableState extends State<NotificationTable>
    with TickerProviderStateMixin {
  Widget _buildNotification(
      BuildContext context, int index, Animation<double> animation) {
    final NotificationUI notification =
      Provider.of<Notifications>(context, listen: false).get(index);
    notification.createState();
    notification.index = index;
    notification.toggleExpand = toggleExpand;

    return AnimatedSize(
        // to animate expand
        vsync: this,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        child: Slidable(
            key: Key(notification.id.toString()),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.2,
            dismissal: SlidableDismissal(
              dismissThresholds: <SlideActionType, double>{
                SlideActionType.primary: 1.0
              },
              child: SlidableDrawerDismissal(),
              onDismissed: (_) {
                Provider.of<Notifications>(context, listen: false)
                    .delete(index);
              },
            ),
            actions: <Widget>[
              IconSlideAction(
                color: MyColour.offWhite,
                icon: Icons.copy,
                caption: "Title",
                onTap: () {
                  Clipboard.setData(
                      new ClipboardData(text: notification.title));
                },
              ),
              IconSlideAction(
                color: MyColour.offWhite,
                icon: Icons.copy,
                caption: "Message",
                onTap: () async {
                  Clipboard.setData(
                      new ClipboardData(text: notification.message));
                },
              ),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                color: MyColour.offWhite,
                icon: Icons.delete,
                onTap: () {
                  Provider.of<Notifications>(context, listen: false)
                      .delete(index);
                },
              ),
            ],
            child: notification));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReloadTable>(builder: (context, reloadTable, child) {
      final Notifications notifications =
          Provider.of<Notifications>(context, listen: false);
      if (notifications.notifications.isNotEmpty) {
        return AnimatedList(
            key: notifications.tableKey,
            itemBuilder: _buildNotification,
            initialItemCount: notifications.length);
      } else {
        // NO NOTIFICATIONS VIEW
        return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.only(top: 20.0)),
                Image.asset('images/sad.png',
                    height: 150, filterQuality: FilterQuality.high),
                Container(padding: const EdgeInsets.only(top: 20.0)),
                SelectableText("No notifications!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: MyColour.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 35)),
                Container(padding: const EdgeInsets.only(top: 20.0)),
                Consumer<User>(builder: (context, user, child) {
                  var credentials = "...";
                  if (!user.isNull()) {
                    credentials = user.credentials;
                  }
                  return Column(children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'To receive notifications use ',
                            style: TextStyle(
                                color: MyColour.grey,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inconsolata'),
                          ),
                          MouseRegionSpan(
                              mouseCursor: SystemMouseCursors.click,
                              inlineSpan: TextSpan(
                                text: 'HTTP Requests',
                                style: TextStyle(
                                    color: MyColour.red,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inconsolata'),
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {
                                    launch("https://notifi.it?c=" +
                                        credentials +
                                        "#how-to");
                                  },
                              )),
                          TextSpan(
                            text: ' with your credentials...',
                            style: TextStyle(
                                color: MyColour.grey,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inconsolata'),
                          ),
                        ],
                      ),
                    ),
                    Container(padding: const EdgeInsets.only(top: 20.0)),
                    SelectableText(credentials, textAlign: TextAlign.center,
                        onTap: () {
                      Clipboard.setData(new ClipboardData(text: credentials));
                      Toast.show("Copied " + credentials, context,
                          gravity: Toast.BOTTOM);
                    },
                        style: TextStyle(
                            color: MyColour.red, fontWeight: FontWeight.w900))
                  ]);
                })
              ]),
        );
      }
    });
  }

  toggleExpand(int index) {
    final NotificationUI notification =
        Provider.of<Notifications>(context, listen: false).get(index);

    notification.isExpanded = !notification.isExpanded;
    Scrollable.ensureVisible(this.context);

    // mark read
    Provider.of<Notifications>(context, listen: false).markRead(index, true);
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
