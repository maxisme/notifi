import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils.dart';
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
                    return Row(mainAxisAlignment: MainAxisAlignment.center,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: <Widget>[
                          const Icon(
                            Akaricons.circleAlert,
                            color: MyColour.red,
                            size: 13,
                          ),
                          const Text(' Network Error!',
                              style: TextStyle(
                                  color: MyColour.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600))
                        ]);
                  }
                  return Container();
                })
              ],
            ),
          ),
          leadingWidth: leadingWidth,
          leading: IconButton(
              icon: const Icon(
                Akaricons.gear,
                color: MyColour.grey,
                size: 22,
              ),
              onPressed: () async {
                Navigator.pushNamed(context, '/settings');
              }),
        ),
        body: const NotificationTable(),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: MyColour.grey,
          unselectedItemColor: MyColour.grey,
          // ignore: prefer_const_literals_to_create_immutables
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Akaricons.doubleCheck,
                  color: MyColour.darkGrey, size: 30),
              label: '',
              tooltip: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Akaricons.trash, color: MyColour.red, size: 30),
              label: '',
              tooltip: '',
            ),
          ],
          onTap: (int index) {
            if (index == 0) {
              // MARK ALL AS READ EVENT
              Provider.of<Notifications>(context, listen: false).readAll();
            } else if (index == 1) {
              // DELETE ALL EVENT
              showAlert(context, 'Delete All Notifications?',
                  'All notifications will be irretrievable.', onOkPressed: () {
                Provider.of<Notifications>(context, listen: false).deleteAll();
                Navigator.pop(context);
              });
            }
          },
        ));
  }
}
