import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/utils/alert.dart';
import 'package:notifi/screens/utils/scaffold.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/icons.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.of<User>(context, listen: false).setSnackContext(context);
    double doubleCheckOffset = -7;
    if (Platform.isMacOS || Platform.isLinux) {
      doubleCheckOffset = 0;
    }
    return MyScaffold(
        leading: IconButton(
            icon: const Icon(Akaricons.gear, key: Key('cog')),
            onPressed: () async {
              Navigator.pushNamed(context, '/settings');
            }),
        body: const NotificationTable(),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          // ignore: prefer_const_literals_to_create_immutables
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context)
                          .indicatorColor) // red as border color
                  ),
            ),
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
                          child: Stack(
                            alignment: AlignmentDirectional.topCenter,
                            children: <Widget>[
                              Positioned(
                                top: doubleCheckOffset,
                                child: Icon(
                                  Akaricons.doubleCheck,
                                  size: 47,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ))),
                  SizedBox(
                      height: 30,
                      child: Container(
                          color: Theme.of(context).indicatorColor, width: 1)),
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
                        child: Icon(Akaricons.trash,
                            key: Key('delete-all'),
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30)),
                  )
                ]),
          ),
        ));
  }
}
