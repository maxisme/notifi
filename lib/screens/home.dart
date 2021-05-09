import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/utils/alert.dart';
import 'package:notifi/screens/utils/appbar_title.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
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
          title: const MyAppBarTitle(leadingWidth),
          leadingWidth: leadingWidth,
          leading: IconButton(
              icon: const Icon(
                Akaricons.gear,
                color: MyColour.darkGrey,
                size: 22,
              ),
              onPressed: () async {
                Navigator.pushNamed(context, '/settings');
              }),
        ),
        body: const NotificationTable(),
        bottomNavigationBar: BottomAppBar(
          // ignore: prefer_const_literals_to_create_immutables
          child: SizedBox(
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                      child: TextButton(
                          onPressed: () {
                            Provider.of<Notifications>(context, listen: false)
                                .readAll();
                          },
                          child: const Icon(Akaricons.doubleCheck,
                              color: MyColour.darkGrey, size: 40))),
                  SizedBox(
                      height: 30,
                      child: Container(color: MyColour.offGrey, width: 1)),
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          showAlert(context, 'Delete All Notifications?',
                              'All notifications will be irretrievable.',
                              onOkPressed: () {
                            Provider.of<Notifications>(context, listen: false)
                                .deleteAll();
                            Navigator.pop(context);
                          });
                        },
                        child: const Icon(Akaricons.trash,
                            color: MyColour.red, size: 30)),
                  )
                ]),
          ),
        ));
  }
}
