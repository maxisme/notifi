import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/screens/utils/alert.dart';
import 'package:notifi/screens/utils/appbar_title.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/icons.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatelessWidget {
  final RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          shape: Border(
              bottom: BorderSide(color: Theme.of(context).indicatorColor)),
          title: const MyAppBarTitle(),
          leading: IconButton(
              icon: const Icon(Akaricons.gear),
              onPressed: () async {
                Navigator.pushNamed(context, '/settings');
              }),
        ),
        body: SmartRefresher(
            header: CustomHeader(
              builder: (_, RefreshStatus mode) {
                // if (mode == RefreshStatus.completed) {
                //   _refreshController.refreshToIdle();
                // }
                return const SizedBox(
                  height: 40.0,
                  width: 40.0,
                  child: Center(
                    child: SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        )),
                  ),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: () async {
              _refreshController.refreshCompleted();
              await Provider.of<User>(context, listen: false).initWSS();
            },
            child: const NotificationTable()),
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
                          child: Icon(
                            Akaricons.doubleCheck,
                            size: 40,
                            color: Theme.of(context).primaryColor,
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
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30)),
                  )
                ]),
          ),
        ));
  }
}
