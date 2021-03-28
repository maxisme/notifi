import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/user.dart';
import 'package:provider/provider.dart';

import '../pallete.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double leadingWidth = 60.0;
    return Scaffold(
        backgroundColor: MyColour.offWhite,
        appBar: AppBar(
          shape: Border(bottom: BorderSide(color: MyColour.offGrey)),
          elevation: 0.0,
          toolbarHeight: 80,
          title: Container(
            padding: const EdgeInsets.only(right: leadingWidth),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      alignment: Alignment(0, 0),
                      child: SizedBox(
                          height: 50,
                          child: Image.asset('images/bell.png',
                              filterQuality: FilterQuality.high)),
                    ),
                    Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Consumer<Notifications>(
                            builder: (context, notifi, child) {
                          int unreadCnt = notifi.unreadCnt;
                          if (unreadCnt != 0) {
                            var numUnread = unreadCnt.toString();
                            if (unreadCnt > 99) {
                              numUnread = "99+";
                            }
                            // TODO animate
                            return Container(
                              alignment: Alignment(0.1, 0),
                              child: CircleAvatar(
                                  backgroundColor: MyColour.red,
                                  radius: 10,
                                  child: Text(
                                    numUnread,
                                    style: TextStyle(
                                      color: MyColour.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )),
                            );
                          }
                          return Container();
                        })),
                  ],
                ),
                Consumer<User>(builder: (context, user, child) {
                  if (user.hasError()) {
                    return Text("Network Error!",
                        style: TextStyle(color: MyColour.grey, fontSize: 10));
                  }
                  return Container();
                })
              ],
            ),
          ),
          leadingWidth: leadingWidth,
          leading: IconButton(
              icon: Icon(
                Icons.settings,
                color: MyColour.grey,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(context, '/settings');
                }
              }),
        ),
        body: NotificationTable(),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            if (index == 0) {
              // MARK ALL AS READ EVENT
              Provider.of<Notifications>(context, listen: false).readAll();
            } else if (index == 1) {
              // DELETE ALL EVENT
              _deleteAllNotificationsDialogue(context);
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.done_all, color: MyColour.darkGrey),
              title: Text('Mark All Read',
                  style: TextStyle(
                      color: MyColour.grey,
                      fontSize:
                          14)), // no idea why this needs to be 14 to match the other button
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.delete_outline, color: MyColour.darkGrey),
                title: Text('Delete All',
                    style: TextStyle(color: MyColour.grey, fontSize: 12))),
          ],
          currentIndex: 1,
        ));
  }

  Future<void> _deleteAllNotificationsDialogue(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete All'),
          content: Text('All notifications will be irretrievable'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: MyColour.grey),
              ),
            ),
            TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(color: MyColour.black),
                ),
                onPressed: () {
                  Provider.of<Notifications>(context, listen: false).deleteAll();
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

// var waitErr;
// setError(bool err) {
//   this.waitErr = err;
//   Future.delayed(const Duration(seconds: 1), (){
//     if(this.waitErr == err) {
//       if (err){
//         invokeMethod("error_icon");
//       }
//       this._networkError.value = err;
//     }
//   });
// }
}
