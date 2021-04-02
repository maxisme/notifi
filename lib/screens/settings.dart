import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:launch_at_login/launch_at_login.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/screens/logs.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  ValueNotifier<String> _version;
  ValueNotifier<String> _remoteVersion;

  @override
  void initState() {
    _version = ValueNotifier<String>('');
    _remoteVersion = ValueNotifier<String>('');
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
    if (!isTest()) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        _version.value = packageInfo.buildNumber;
      });
    }

    http.get('https://notifi.it/version').then((http.Response value) {
      if (value.statusCode == 200) {
        _remoteVersion.value = value.body;
      } else {
        L.e('Problem getting /version from notifi.it');
      }
    });

    return Scaffold(
        backgroundColor: MyColour.offWhite,
        appBar: AppBar(
          shape: const Border(bottom: BorderSide(color: MyColour.offGrey)),
          elevation: 0.0,
          toolbarHeight: 80,
          centerTitle: true,
          title: SizedBox(
              height: 50,
              child: Image.asset('images/bell.png',
                  filterQuality: FilterQuality.high)),
          leading: IconButton(
              icon: const Icon(
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
        body: Column(children: <Widget>[
          Consumer<User>(
              builder: (BuildContext context, User user, Widget child) {
            return Column(children: <Widget>[
              Container(padding: const EdgeInsets.only(top: 20.0)),
              if (!user.isNull())
                SettingOption('How Do I Receive Notifications?',
                    onTapCallback: () async {
                  await openUrl(
                      'https://notifi.it?c=${user.credentials}#how-to');
                }),
              SettingOption('Copy Credentials ${user.credentials}',
                  onTapCallback: () {
                Clipboard.setData(ClipboardData(text: user.credentials));
                showToast('Copied ${user.credentials}', context,
                    gravity: Toast.CENTER);
              })
            ]);
          }),
          SettingOption('Create New Credentials',
              onTapCallback: _newCredentialsDialogue),
          Container(
            padding: const EdgeInsets.only(top: 15),
          ),
          // if (!Platform.isAndroid && !Platform.isIOS)
          //   SettingOption('Sticky Notifications',
          //       switchValue: false, switchCallback: (isEnabled) {}),
          if (!Platform.isAndroid && !Platform.isIOS)
            // ignore: always_specify_types
            FutureBuilder(
                future: LaunchAtLogin.isEnabled,
                // ignore: always_specify_types
                builder: (BuildContext context, AsyncSnapshot f) {
                  if (f.connectionState == ConnectionState.none &&
                      f.hasData == null) {
                    return const CircularProgressIndicator();
                  }
                  return SettingOption(
                    'Open notifi at Login',
                    switchValue: f.data as bool,
                    switchCallback: (_) async {
                      final bool enabled = await LaunchAtLogin.isEnabled;
                      if (enabled) {
                        await LaunchAtLogin.disable;
                      } else {
                        await LaunchAtLogin.enable;
                      }
                      setState(() {});
                    },
                  );
                }),
          SettingOption('About...', onTapCallback: () {
            launch('https://notifi.it');
          }),
          SettingOption('Logs...', onTapCallback: () {
            Navigator.push(
              context,
              MaterialPageRoute<StatelessWidget>(
                  builder: (BuildContext context) => LogsScreen()),
            );
          }),
          if (Platform.isMacOS)
            SettingOption(
              'Quit notifi',
              onTapCallback: () {
                SystemNavigator.pop();
              },
            ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: RichText(
                textAlign: TextAlign.center,
                // ignore: always_specify_types
                text: TextSpan(children: [
                  const TextSpan(
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
                        style: const TextStyle(
                            color: MyColour.darkGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            fontFamily: 'Inconsolata'),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://max.me.uk');
                          },
                      )),
                ])),
          ),
          // ignore: always_specify_types
          ValueListenableBuilder(
              valueListenable: _version,
              // ignore: always_specify_types
              builder: (BuildContext context, String version, Widget child) {
                return Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('version: $version',
                          style: const TextStyle(
                              color: MyColour.grey, fontSize: 12)),
                      // ignore: always_specify_types
                      ValueListenableBuilder(
                          valueListenable: _remoteVersion,
                          builder: (BuildContext context, String remoteVersion,
                              Widget child) {
                            if (version != remoteVersion) {
                              return TextButton(
                                  onPressed: () {
                                    launch('https://notifi.it/download');
                                  },
                                  child: const Icon(
                                    Icons.arrow_circle_down,
                                    color: MyColour.red,
                                    size: 18,
                                  ));
                            }
                            return const SizedBox();
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
          title: const Text('New Credentials'),
          content:
              const Text('Are you sure? You will never be able to use your '
                  'current credentials again!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No',
                style: TextStyle(color: MyColour.grey),
              ),
            ),
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final bool gotUser =
                      await Provider.of<User>(context, listen: false)
                          .requestNewUser();
                  if (!gotUser) {
                    // TODO show error
                    L.i('Unable to fetch new user!');
                  }
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: MyColour.black),
                )),
          ],
        );
      },
    );
  }
}

// ignore: must_be_immutable
class SettingOption extends StatelessWidget {
  SettingOption(this.text,
      {Key key, this.onTapCallback, this.switchCallback, this.switchValue})
      : super(key: key);

  final String text;
  GestureTapCallback onTapCallback;
  ValueChanged<bool> switchCallback;
  bool switchValue;

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
        fontFamily: 'Inconsolata',
        fontSize: 15,
        color: MyColour.black,
        fontWeight: FontWeight.w600);

    // switch or link
    Widget setting;
    if (switchCallback == null) {
      setting = Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(MyColour.offWhite),
                  shadowColor: MaterialStateProperty.all(MyColour.offWhite),
                  overlayColor: MaterialStateProperty.all(MyColour.offWhite),
                  elevation: MaterialStateProperty.all(0)),
              onPressed: onTapCallback,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(text, style: style),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: MyColour.grey),
                  ])));
    } else {
      switchValue ??= false;
      setting = Container(
          padding: const EdgeInsets.only(left: 23, right: 7),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(text, style: style),
                Switch(value: switchValue, onChanged: switchCallback)
              ]));
    }
    return setting;
  }
}
