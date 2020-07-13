import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:launch_at_login/launch_at_login.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/screens/base.dart';
import 'package:url_launcher/url_launcher.dart';

const howToURL = "https://notifi.it#how-to";

class SettingsScreen extends StatefulWidget {
  NotificationTable table;

  SettingsScreen(this.table, {Key key}) : super(key: key);

  @override
  SettingsScreenState createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        widget.table,
        SliverFillRemaining(
          fillOverscroll: false,
          child: Column(children: [
            SettingOption('Copy My Credentials', () {
              Clipboard.setData(
                  new ClipboardData(text: widget.table.user.credentials));
            }),
            SettingOption('Reset Credentials', _newCredentialsDialogue),
            Container(
              padding: EdgeInsets.only(top: 15),
            ),
            if (!Platform.isAndroid && !Platform.isIOS)
              SettingOption('Sticky Notifications', () {
                print('Terms of Service');
              }),
            if (!Platform.isAndroid && !Platform.isIOS)
              SettingOption('Open notifi at Login', () async {
                await LaunchAtLogin.enable;
              }),
            if (!Platform.isAndroid && !Platform.isIOS)
              Container(
                padding: EdgeInsets.only(top: 15),
              ),
            SettingOption('How do I receive notifications?', () {
              launch(howToURL);
            }),
            SettingOption('About...', () {
              print('Terms of Service');
            }),
            SettingOption('Open Logs...', () {
              print('Terms of Service');
            }),
            if (!Platform.isIOS)
              Container(
                padding: EdgeInsets.only(top: 15),
              ),
            if (!Platform.isIOS)
              SettingOption('Quit notifi', () {
                SystemNavigator.pop();
              }),
          ]),
        ));
  }

  Future<void> _newCredentialsDialogue() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Credentials'),
          content: Text(
              'Are you sure? You will never be able to use your current credentials again!'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}

class SettingOption extends StatefulWidget {
  final text;
  GestureTapCallback onTap;

  SettingOption(this.text, this.onTap, {Key key}) : super(key: key);

  @override
  SettingOptionState createState() => new SettingOptionState();
}

class SettingOptionState extends State<SettingOption> {
  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
        fontFamily: "Inconsolata",
        fontSize: 15,
        color: MyColour.black,
        fontWeight: FontWeight.w600);

    return Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: RaisedButton(
            elevation: 0,
            color: MyColour.offWhite,
            onPressed: widget.onTap,
            child: Row(children: <Widget>[
              Flexible(
                  fit: FlexFit.tight,
                  flex: 70,
                  child: Container(child: Text(widget.text, style: style))),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child:
                          Icon(Icons.arrow_forward_ios, color: MyColour.grey))),
            ])));
  }

  Future<void> _newCredentialsDialogue() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Credentials'),
          content: Text(
              'Are you sure? You will never be able to use your current credentials again!'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
