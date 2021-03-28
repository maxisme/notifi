import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:launch_at_login/launch_at_login.dart';
import 'package:notifi/notifications/notifications-table.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  SettingsScreenState createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  ValueNotifier<String> _version;
  ValueNotifier<String> _remoteVersion;

  @override
  void initState() {
    _version = ValueNotifier<String>("");
    _remoteVersion = ValueNotifier<String>("");
    super.initState();
  }

  @override
  void dispose() {
    _version.dispose();
    _remoteVersion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!isTest()) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        _version.value = packageInfo.buildNumber;
      });
    }

    http.get("https://notifi.it/version").then((value) {
      if (value.statusCode == 200) {
        _remoteVersion.value = value.body;
      } else {
        print("problem getting /version");
      }
    });

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
                Icons.arrow_back,
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
        body: Column(children: [
          Consumer<User>(builder: (context, user, child) {
            return Column(children: [
              Container(padding: EdgeInsets.only(top: 20.0)),
              if (!user.isNull())
                SettingOption('How do I receive notifications?',
                    onTapCallback: () async {
                  await openUrl(
                      "https://notifi.it?c=" + user.credentials + "#how-to");
                }),
              SettingOption('Copy Credentials ' + user.credentials,
                  onTapCallback: () {
                Clipboard.setData(new ClipboardData(text: user.credentials));
                showToast("Copied " + user.credentials, gravity: Toast.CENTER);
              })
            ]);
          }),
          SettingOption('Create New Credentials',
              onTapCallback: _newCredentialsDialogue),
          Container(
            padding: EdgeInsets.only(top: 15),
          ),
          // if (!Platform.isAndroid && !Platform.isIOS)
          //   SettingOption('Sticky Notifications',
          //       switchValue: false, switchCallback: (isEnabled) {}),
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
            launch("https://notifi.it");
          }),
          // SettingOption('Open Logs...', onTapCallback: () {
          //   print('Terms of Service');
          // }),
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
          Container(
            padding: EdgeInsets.only(top: 10),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Made by \n',
                    style: TextStyle(
                        color: MyColour.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: 'Inconsolata'),
                  ),
                  MouseRegionSpan(
                      mouseCursor: SystemMouseCursors.click,
                      inlineSpan: TextSpan(
                        text: 'Maximilian Mitchell',
                        style: TextStyle(
                            color: MyColour.darkGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            fontFamily: 'Inconsolata'),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launch("https://max.me.uk");
                          },
                      )),
                  // TextSpan(
                  //   text: '\n\nCopyright © ${now.year}',
                  //   style: TextStyle(
                  //       color: MyColour.grey,
                  //       fontWeight: FontWeight.w500,
                  //       fontSize: 10,
                  //       fontFamily: 'Inconsolata'),
                  // ),
                ])),
          ),
          ValueListenableBuilder(
              valueListenable: _version,
              builder: (context, version, child) {
                return Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("version: " + version,
                          style: TextStyle(color: MyColour.grey, fontSize: 12)),
                      ValueListenableBuilder(
                          valueListenable: _remoteVersion,
                          builder: (context, remoteVersion, child) {
                            if (version != remoteVersion) {
                              return FlatButton(
                                  minWidth: 0,
                                  onPressed: () {
                                    launch("https://notifi.it/download");
                                  },
                                  child: Icon(
                                    Icons.arrow_circle_down,
                                    color: MyColour.red,
                                    size: 18,
                                  ));
                            }
                            return Container(width: 0, height: 0);
                          })
                    ],
                  ),
                );
              }),
        ]));
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
                  var gotUser = await Provider.of<User>(context, listen: false)
                      .RequestNewUser();
                  if (!gotUser) {
                    // TODO show error
                    print("Unable to fetch new user!");
                  }
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
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(MyColour.offWhite),
                  shadowColor: MaterialStateProperty.all(MyColour.offWhite),
                  overlayColor: MaterialStateProperty.all(MyColour.offWhite),
                  elevation: MaterialStateProperty.all(0)),
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
          padding: EdgeInsets.only(left: 23, right: 7),
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
