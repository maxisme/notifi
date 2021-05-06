import 'dart:io' show Platform;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:launch_at_login/launch_at_login.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/screens/logs.dart';
import 'package:notifi/screens/utils/alert.dart';
import 'package:notifi/screens/utils/appbar_title.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:notifi/utils/utils.dart';
import 'package:notifi/utils/version.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  ValueNotifier<String> _version;
  ValueNotifier<bool> _hasUpgrade;

  @override
  void initState() {
    _version = ValueNotifier<String>('');
    _hasUpgrade = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  void dispose() {
    _version.dispose();
    _hasUpgrade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double leadingWidth = 60.0;

    if (!isTest()) {
      getVersion().then((String version) {
        _version.value = version;
        hasUpgrade(version).then((bool hasUpgrade) {
          _hasUpgrade.value = hasUpgrade;
        });
      });
    }

    return Scaffold(
        backgroundColor: MyColour.offWhite,
        appBar: AppBar(
          shape: const Border(bottom: BorderSide(color: MyColour.offGrey)),
          elevation: 0.0,
          toolbarHeight: 80,
          leadingWidth: leadingWidth,
          leading: IconButton(
              icon: const Icon(
                Akaricons.chevronLeft,
                color: MyColour.darkGrey,
                size: 22,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: const MyAppBarTitle(leadingWidth),
        ),
        body: Column(children: <Widget>[
          Consumer<User>(
              builder: (BuildContext context, User user, Widget child) {
            final String credentials = user.getCredentials();

            SettingOption credentialsSettingWidget = SettingOption(
                'Copy Credentials $credentials', Akaricons.clipboard,
                onTapCallback: () {
              Clipboard.setData(ClipboardData(text: credentials));
              showToast('Copied $credentials', context, gravity: Toast.CENTER);
            });
            if (Platform.isIOS) {
              credentialsSettingWidget = SettingOption(
                  'Share Credentials $credentials', Akaricons.clipboard,
                  onTapCallback: () {
                Share.share('notifi credentials: $credentials');
              });
            }

            return Column(children: <Widget>[
              Container(padding: const EdgeInsets.only(top: 20.0)),
              SettingOption(
                  'How Do I Receive Notifications?', Akaricons.question,
                  onTapCallback: () async {
                await openUrl('https://notifi.it?c=$credentials#how-to');
              }),
              credentialsSettingWidget
            ]);
          }),
          SettingOption('Create New Credentials', Akaricons.arrowClockwise,
              onTapCallback: () {
            showAlert(
                context,
                'Replace Credentials?',
                'Are you sure? You will never be able to use your '
                    'current credentials again!', onOkPressed: () async {
              Navigator.pop(context);
              final bool gotUser =
                  await Provider.of<User>(context, listen: false).setNewUser();
              if (!gotUser) {
                // TODO show error
                L.i('Unable to fetch new user!');
              }
            });
          }),
          if (Platform.isIOS)
            SettingOption('iOS App Settings...', Akaricons.gear,
                onTapCallback: AppSettings.openNotificationSettings),
          SettingOption('About...', Akaricons.info, onTapCallback: () {
            openUrl('https://notifi.it');
          }),
          SettingOption('Logs...', Akaricons.file, onTapCallback: () {
            Navigator.push(
              context,
              MaterialPageRoute<StatelessWidget>(
                  builder: (BuildContext context) => const LogsScreen()),
            );
          }),
          if (Platform.isMacOS)
            SettingOption(
              'Quit notifi',
              Akaricons.signOut,
              onTapCallback: () {
                SystemNavigator.pop();
              },
            ),
          if (Platform.isMacOS)
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
                    Akaricons.person,
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
          Container(
            padding: const EdgeInsets.only(top: 30),
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
          if (!isTest())
            ValueListenableBuilder<String>(
                valueListenable: _version,
                // ignore: always_specify_types
                builder: (BuildContext context, String version, Widget child) {
                  return Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('version: $version',
                            style: const TextStyle(
                                color: MyColour.grey, fontSize: 12)),
                        if (Platform.isMacOS)
                          ValueListenableBuilder<bool>(
                              valueListenable: _hasUpgrade,
                              builder: (BuildContext context, bool hasUpgrade,
                                  Widget child) {
                                if (hasUpgrade) {
                                  return TextButton(
                                      onPressed: () {
                                        invokeMacMethod('update');
                                      },
                                      child: const Icon(
                                        Akaricons.cloudDownload,
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
}

// ignore: must_be_immutable
class SettingOption extends StatelessWidget {
  SettingOption(this.text, this.icon,
      {Key key, this.onTapCallback, this.switchCallback, this.switchValue})
      : super(key: key);

  final String text;
  final IconData icon;
  GestureTapCallback onTapCallback;
  ValueChanged<bool> switchCallback;
  bool switchValue;

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
        fontSize: 15, color: MyColour.black, fontWeight: FontWeight.w400);

    final Container iconWidget = Container(
        padding: const EdgeInsets.only(right: 10),
        child: Icon(icon, size: 20, color: MyColour.black));

    Widget setting;
    if (switchCallback == null) {
      setting = Container(
          padding: const EdgeInsets.only(top: 10),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(MyColour.offWhite),
                  overlayColor: MaterialStateProperty.all(MyColour.white),
                  elevation: MaterialStateProperty.all(0)),
              onPressed: onTapCallback,
              child: Row(children: <Widget>[
                iconWidget,
                Text(text, style: style),
              ])));
    } else {
      switchValue ??= false;
      setting = Container(
          padding: const EdgeInsets.only(left: 15, right: 7, top: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: <Widget>[iconWidget, Text(text, style: style)]),
                Switch(value: switchValue, onChanged: switchCallback)
              ]));
    }
    return setting;
  }
}
