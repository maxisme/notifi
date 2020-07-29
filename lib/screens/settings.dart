import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:launch_at_login/launch_at_login.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  NotificationTable table;

  SettingsScreen(this.table, {Key key}) : super(key: key);

  @override
  SettingsScreenState createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _stickyEnabled = false;

  @override
  Widget build(BuildContext context) {
    String credString = "";
    if (widget.table != null && widget.table.user != null) {
      credString = " - " + widget.table.user.credentials;
    }
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
      body: Column(children: [
        if (credString != "")
          SettingOption('How do I receive notifications?', onTapCallback: () {
            launch("https://notifi.it?c=" +
                widget.table.user.credentials +
                "#how-to");
          }),
        SettingOption('Copy Credentials' + credString, onTapCallback: () {
          if (credString != "") {
            Clipboard.setData(
                new ClipboardData(text: widget.table.user.credentials));
            showToast("Copied " + widget.table.user.credentials,
                gravity: Toast.CENTER);
          }
        }),
        SettingOption('Create New Credentials',
            onTapCallback: _newCredentialsDialogue),
        Container(
          padding: EdgeInsets.only(top: 15),
        ),
        if (!Platform.isAndroid && !Platform.isIOS)
          SettingOption('Sticky Notifications', switchValue: _stickyEnabled,
              switchCallback: (isEnabled) async {
            setState(() {
              _stickyEnabled = isEnabled;
            });
          }),
        if (!Platform.isAndroid && !Platform.isIOS)
          FutureBuilder(
              future: LaunchAtLogin.isEnabled,
              builder: (context, f) {
                if (f.connectionState == ConnectionState.none &&
                    f.hasData == null) {
                  return CircularProgressIndicator();
                }

                return SettingOption(
                  'Open notifi at Login',
                  switchValue: f.data,
                  switchCallback: (_) async {
                    var enabled = await LaunchAtLogin.isEnabled;
                    if (enabled) {
                      await LaunchAtLogin.disable;
                    } else {
                      await LaunchAtLogin.enable;
                    }
                    setState(() {});
                  },
                );
              }),
        if (!Platform.isAndroid && !Platform.isIOS)
          Container(
            padding: EdgeInsets.only(top: 15),
          ),
        SettingOption('About...', onTapCallback: () {
          print('Terms of Service');
        }),
        SettingOption('Open Logs...', onTapCallback: () {
          print('Terms of Service');
        }),
        if (!Platform.isIOS)
          Container(
            padding: EdgeInsets.only(top: 15),
          ),
        if (!Platform.isIOS)
          SettingOption(
            'Quit notifi',
            onTapCallback: () {
              SystemNavigator.pop();
            },
          ),
      ]),
    );
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
              child: Text(
                'No',
                style: TextStyle(color: MyColour.grey),
              ),
            ),
            FlatButton(
                child: Text(
                  'Yes',
                  style: TextStyle(color: MyColour.black),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    widget.table.user.RequestNewUser();
                  });
                })
          ],
        );
      },
    );
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}

class SettingOption extends StatefulWidget {
  final text;
  GestureTapCallback onTapCallback;
  ValueChanged<bool> switchCallback;
  bool switchValue;

  SettingOption(this.text,
      {Key key, this.onTapCallback, this.switchCallback, this.switchValue})
      : super(key: key);

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

    // switch or link
    var setting;
    if (widget.switchCallback == null) {
      setting = Container(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: RaisedButton(
              elevation: 0,
              color: MyColour.offWhite,
              onPressed: widget.onTapCallback,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(child: Text(widget.text, style: style)),
                    Container(
                        child: Icon(Icons.arrow_forward_ios,
                            size: 12, color: MyColour.grey)),
                  ])));
    } else {
      if (widget.switchValue == null) widget.switchValue = false;
      setting = Container(
          padding: EdgeInsets.only(left: 30, right: 7),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(child: Text(widget.text, style: style)),
                Container(
                  child: Switch(
                      value: widget.switchValue,
                      onChanged: widget.switchCallback),
                )
              ]));
    }
    return setting;
  }
}
