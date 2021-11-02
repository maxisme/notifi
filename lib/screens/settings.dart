import 'dart:io' show File, Platform;

import 'package:launch_review/launch_review.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:launch_at_login/launch_at_login.dart';
import 'package:notifi/notifications/notifications_table.dart';
import 'package:notifi/screens/utils/alert.dart';
import 'package:notifi/screens/utils/scaffold.dart';
import 'package:notifi/user.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:notifi/utils/utils.dart';
import 'package:notifi/utils/version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  ValueNotifier<String> _versionString;
  ValueNotifier<bool> _hasUpgrade;

  @override
  void initState() {
    _versionString = ValueNotifier<String>('');
    _hasUpgrade = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTest) {
      PackageInfo.fromPlatform().then((PackageInfo package) {
        if (Platform.isMacOS || Platform.isLinux) {
          _versionString.value = package.version;
        } else {
          _versionString.value = '${package.version} (${package.buildNumber})';
        }
        hasUpgrade(package.version).then((bool hasUpgrade) {
          _hasUpgrade.value = hasUpgrade;
        });
      });
    }

    Widget bottomNavigationBar = SizedBox();
    if (Platform.isMacOS || Platform.isLinux) {
      bottomNavigationBar = Container(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Icon(
                  Akaricons.signOut,
                  color: MyColour.black,
                  size: 25,
                ),
              ),
            ],
          ));
    }

    IconData otherPlatformsIcon = Akaricons.laptop_device;
    if (Platform.isLinux || Platform.isMacOS) {
      otherPlatformsIcon = Akaricons.mobile_device;
    }

    return MyScaffold(
        leading: IconButton(
            key: Key('back-button'),
            icon: const Icon(Akaricons.chevronLeft),
            onPressed: () {
              Navigator.pop(context);
            }),
        body: Column(children: <Widget>[
          Consumer<User>(
              builder: (BuildContext context, User user, Widget child) {
            final String credentials = user.getCredentials();

            SettingOption credentialsSettingWidget = SettingOption(
                'Copy Credentials', Akaricons.clipboard, onTapCallback: () {
              copyText(credentials, context);
            });
            if (Platform.isIOS || Platform.isAndroid) {
              credentialsSettingWidget = SettingOption(
                  'Share Credentials', Akaricons.share, onTapCallback: () {
                Share.share(credentials);
              });
            }

            return Column(children: <Widget>[
              SettingOption(
                  'How Do I Receive Notifications?', Akaricons.question,
                  onTapCallback: () async {
                await openUrl('https://$httpEndpoint?c=$credentials#how-to');
              }),
              credentialsSettingWidget
            ]);
          }),
          SettingOption('Create New Credentials', Akaricons.arrowClockwise,
              key: Key('new-credentials'), onTapCallback: () {
            showAlert(
                context,
                'Replace Credentials?',
                'Are you sure? You will never be able to use your '
                    'current credentials again!', onOkPressed: () async {
              final bool gotUser =
                  await Provider.of<User>(context, listen: false).setNewUser();
              Navigator.pop(context);
              if (!gotUser) {
                Toast.show(
                    'Problem fetching new credentials. '
                    'Please try again later...',
                    context,
                    gravity: Toast.CENTER);
              }
            });
          }),
          if (Platform.isIOS)
            SettingOption('iOS App Settings...', Akaricons.gear,
                onTapCallback: AppSettings.openNotificationSettings),
          SettingOption('About...', Akaricons.info,
              onTapCallback: () => openUrl('https://notifi.it')),
          SettingOption('Other Platforms...', otherPlatformsIcon,
              onTapCallback: () => openUrl('$httpEndpoint#downloads')),
          if (Platform.isAndroid || Platform.isIOS)
            SettingOption('Review app...', Akaricons.star,
                onTapCallback: () => LaunchReview.launch(
                      androidAppId: 'it.notifi.notifi',
                      iOSAppId: '1563961135',
                    )),
          if (Platform.isMacOS)
            Container(
              padding: const EdgeInsets.only(top: 5),
              child: FutureBuilder<bool>(
                  future: LaunchAtLogin.isEnabled,
                  builder: (BuildContext context, AsyncSnapshot<bool> f) {
                    if (f.connectionState == ConnectionState.none &&
                        f.hasData == null) {
                      return const CircularProgressIndicator();
                    }
                    return SettingOption(
                      'Open notifi at Login',
                      Akaricons.person,
                      switchValue: f.data,
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
            ),
          if (Platform.isLinux)
            Container(
              padding: const EdgeInsets.only(top: 5),
              child: FutureBuilder<bool>(
                  future: linuxDoesAutoLogin(),
                  builder: (BuildContext context, AsyncSnapshot<bool> f) {
                    if (f.connectionState == ConnectionState.none &&
                        f.hasData == null) {
                      return const CircularProgressIndicator();
                    }
                    return SettingOption(
                      'Open notifi at Login',
                      Akaricons.person,
                      switchValue: f.data,
                      switchCallback: (_) async {
                        File desktopPath =
                            await getOpenOnLinuxLoginSnapDesktopFilePath();
                        File localSnapDesktopPath =
                            File('snap/gui/notifi.desktop');
                        if (f.data) {
                          await desktopPath.delete();
                        } else {
                          localSnapDesktopPath.copy(desktopPath.path);
                        }
                        setState(() {});
                      },
                    );
                  }),
            ),
          if (Platform.isMacOS)
            FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                // ignore: always_specify_types
                builder: (BuildContext context, AsyncSnapshot f) {
                  if (f.connectionState == ConnectionState.none ||
                      f.hasData == null ||
                      f.data == null) {
                    return const CircularProgressIndicator();
                  }
                  final SharedPreferences sp = f.data as SharedPreferences;
                  return SettingOption(
                    'Pin window',
                    Akaricons.pin,
                    switchValue: shouldPinWindow(sp),
                    switchCallback: (bool shouldPin) async {
                      final bool success = await invokeMacMethod(
                          'set-pin-window',
                          <String, bool>{'transient': !shouldPin}) as bool;
                      if (success) {
                        sp.setBool('pin-window', shouldPin);
                      }
                      setState(() {});
                    },
                  );
                }),
          Container(
            padding: const EdgeInsets.only(top: 30),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: <InlineSpan>[
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
          if (!isTest)
            ValueListenableBuilder<String>(
                valueListenable: _versionString,
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
                                      child: Icon(
                                        Akaricons.cloudDownload,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 18,
                                      ));
                                }
                                return const SizedBox();
                              })
                      ],
                    ),
                  );
                }),
        ]),
        bottomNavigationBar: bottomNavigationBar);
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
    final Container iconWidget = Container(
        padding: const EdgeInsets.only(right: 10),
        child: Icon(icon, size: 20, color: MyColour.black));

    double verticalPadding = 0;
    if (Platform.isLinux || Platform.isMacOS) verticalPadding = 10;
    Widget setting;
    if (switchCallback == null) {
      setting = Container(
          padding: EdgeInsets.only(top: 15 + verticalPadding),
          child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).backgroundColor),
                  overlayColor: MaterialStateProperty.all(MyColour.white),
                  elevation: MaterialStateProperty.all(0)),
              onPressed: onTapCallback,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(children: <Widget>[
                      iconWidget,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1.5),
                        child: Text(text,
                            style: Theme.of(context).textTheme.bodyText2),
                      )
                    ]),
                    Icon(Akaricons.chevronRight,
                        size: 15, color: MyColour.black)
                  ])));
    } else {
      switchValue ??= false;
      setting = Container(
          padding: EdgeInsets.only(left: 16, right: 7, top: verticalPadding),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: <Widget>[
                  iconWidget,
                  Text(text, style: Theme.of(context).textTheme.bodyText2)
                ]),
                Switch(
                    value: switchValue,
                    onChanged: switchCallback,
                    activeColor: Theme.of(context).colorScheme.secondary)
              ]));
    }
    return setting;
  }
}
