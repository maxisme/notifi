import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';

class BaseLayout extends StatefulWidget {
  NotificationTable table;
  Widget child;

  BaseLayout(this.table, this.child, {Key key}) : super(key: key);

  @override
  _BaseLayoutState createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColour.offWhite,
        appBar: AppBar(
          shape: Border(bottom: BorderSide(color: MyColour.offGrey)),
          elevation: 0.0,
          toolbarHeight: 80,
          centerTitle: true,
          title: Image.asset('images/bell.png',
              height: 50, filterQuality: FilterQuality.high),
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
        body: CustomScrollView(
          slivers: <Widget>[
            widget.child,
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            if (index == 0) {
              // MARK ALL AS READ EVENT
              setState(() {
                widget.table.notificationDB.markAllRead();
              });
            } else if (index == 1) {
              // DELETE ALL EVENT
              _deleteAllDialogue();
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.check, color: MyColour.darkGrey),
              title: Text('Mark All Read',
                  style: TextStyle(color: MyColour.grey, fontSize: 12)),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.delete, color: MyColour.darkGrey),
                title: Text('Delete All',
                    style: TextStyle(color: MyColour.grey, fontSize: 12))),
          ],
        ));
  }

  Future<void> _deleteAllDialogue() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('All notifications will be deleted'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  widget.table.deleteAll();
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
