import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notifi/notifications/notification.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/utils.dart';
import 'package:provider/provider.dart';
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
    return Consumer<ReloadTable>(
        builder: (BuildContext context, ReloadTable reloadTable, Widget child) {
      final Notifications notifications =
          Provider.of<Notifications>(context, listen: false);
      if (notifications.notifications.isNotEmpty) {
        return AnimatedList(
            key: notifications.tableKey,
            controller: notifications.tableController,
            itemBuilder: _buildNotification,
            initialItemCount: notifications.length);
      } else {
        // NO NOTIFICATIONS VIEW
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(padding: const EdgeInsets.only(top: 20.0)),
              Image.asset('images/sad.png',
                  height: 150, filterQuality: FilterQuality.high),
              Container(padding: const EdgeInsets.only(top: 20.0)),
              const SelectableText('No Notifications!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: MyColour.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 35)),
              Container(padding: const EdgeInsets.only(top: 20.0)),
              Consumer<User>(
                  builder: (BuildContext context, User user, Widget child) {
                String credentials = user.getCredentials();
                credentials ??= '...';
                return Column(children: <Widget>[
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(
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
                              style: const TextStyle(
                                  color: MyColour.red,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inconsolata'),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  openUrl(
                                      'https://notifi.it?c=$credentials#how-to');
                                },
                            )),
                        const TextSpan(
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
                    Clipboard.setData(ClipboardData(text: credentials));
                    Toast.show('Copied $credentials', context,
                        gravity: Toast.BOTTOM);
                  },
                      style: const TextStyle(
                          color: MyColour.red, fontWeight: FontWeight.w900))
                ]);
              })
            ]);
      }
    });
  }

  void toggleExpand(int index) {
    final NotificationUI notification =
        Provider.of<Notifications>(context, listen: false).get(index);

    notification.isExpanded = !notification.isExpanded;
    Scrollable.ensureVisible(context);

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

    return SlideTransition(
      position: _offsetAnimation,
      child: AnimatedSize(
          // to animate expand
          vsync: this,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Slidable(
              key: Key(notification.id.toString()),
              actionPane: const SlidableDrawerActionPane(),
              actionExtentRatio: 0.2,
              actions: <Widget>[
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Akaricons.copy,
                  caption: 'Title',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: notification.title));
                  },
                ),
                IconSlideAction(
                  color: MyColour.offWhite,
                  icon: Akaricons.copy,
                  caption: 'Message',
                  onTap: () async {
                    Clipboard.setData(
                        ClipboardData(text: notification.message));
                  },
                ),
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  color: MyColour.offWhite,
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
