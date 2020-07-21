import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';

class BaseLayout extends StatefulWidget {
  NotificationTable table;
  Widget child;
  void newUserCallback;

  BaseLayout(this.table, this.child, {Key key, this.newUserCallback})
      : super(key: key);

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
          title: SizedBox(
              height: 50,
              child: Image.asset('images/bell.png',
                  filterQuality: FilterQuality.high)),
          leading: IconButton(
              icon: Icon(
                Navigator.canPop(context) ? Icons.arrow_back : Icons.settings,
                color: MyColour.grey,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(context, '/settings');
                }
              }),
          actions: [
            widget.table == null || widget.table.user == null
                ? RefreshProgressIndicator()
                : Container()
          ],
        ),
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            if (index == 0) {
              // MARK ALL AS READ EVENT
              widget.table.notificationDB.markAllRead();
              setState(() {});
            } else if (index == 1) {
              // DELETE ALL EVENT
              _deleteAllDialogue();
              setState(() {});
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.done_all, color: MyColour.darkGrey),
              title: Text('Mark All Read',
                  style: TextStyle(color: MyColour.grey, fontSize: 12)),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.delete_outline, color: MyColour.darkGrey),
                title: Text('Delete All',
                    style: TextStyle(color: MyColour.grey, fontSize: 12))),
          ],
          currentIndex: 1,
        ));
  }

  Future<void> _deleteAllDialogue() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete All'),
          content: Text('All notifications will be irretrievable'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: MyColour.grey),
              ),
            ),
            FlatButton(
                child: Text(
                  'Ok',
                  style: TextStyle(color: MyColour.black),
                ),
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
