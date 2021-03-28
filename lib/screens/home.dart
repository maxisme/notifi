import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double leadingWidth = 60.0;
    return Scaffold(
        backgroundColor: MyColour.offWhite,
        appBar: AppBar(
          shape: const Border(bottom: BorderSide(color: MyColour.offGrey)),
          elevation: 0.0,
          toolbarHeight: 80,
          title: Container(
            padding: const EdgeInsets.only(right: leadingWidth),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      alignment: const Alignment(0, 0),
                      child: SizedBox(
                          height: 50,
                          child: Image.asset('images/bell.png',
                              filterQuality: FilterQuality.high)),
                    ),
                    Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Consumer<Notifications>(builder:
                            (BuildContext context, Notifications notifi,
                                Widget child) {
                          final int unreadCnt = notifi.unreadCnt;
                          if (unreadCnt != 0) {
                            String numUnread = unreadCnt.toString();
                            if (unreadCnt > 99) {
                              numUnread = '99+';
                            }
                            // TODO animate
                            return Container(
                              alignment: const Alignment(0.1, 0),
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
                                  )),
                            );
                          }
                          return Container();
                        })),
                  ],
                ),
                Consumer<User>(
                    builder: (BuildContext context, User user, Widget child) {
                  if (user.hasError()) {
                    return const Text('Network Error!',
                        style: TextStyle(color: MyColour.grey, fontSize: 10));
                  }
                  return Container();
                })
              ],
            ),
          ),
          leadingWidth: leadingWidth,
          leading: IconButton(
              icon: const Icon(
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
        body: const NotificationTable(),
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
          // ignore: prefer_const_literals_to_create_immutables
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.done_all, color: MyColour.darkGrey),
              label: 'Mark All Read',
              tooltip: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.delete_outline, color: MyColour.darkGrey),
              label: 'Delete All',
              tooltip: '',
            ),
          ],
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          selectedItemColor: MyColour.grey,
          unselectedItemColor: MyColour.grey,
        ));
  }

  Future<void> _deleteAllNotificationsDialogue(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All'),
          content: const Text('All notifications will be irretrievable'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: MyColour.grey),
              ),
            ),
            TextButton(
                onPressed: () {
                  Provider.of<Notifications>(context, listen: false)
                      .deleteAll();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(color: MyColour.black),
                )),
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
