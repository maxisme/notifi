import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({Key key}) : super(key: key);

  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  LogLevel _logLevel = LogLevel.INFO;
  final int _maxResults = 100;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListView>(
        future: logListView(),
        builder: (BuildContext context, AsyncSnapshot<ListView> f) {
          Widget widget;
          if (f.connectionState != ConnectionState.done || f.data == null) {
            widget = const Center(child: CircularProgressIndicator());
          } else {
            widget = Scrollbar(thickness: 4, child: f.data);
          }

          return Scaffold(
              appBar: AppBar(
                toolbarHeight: 80,
                leading: IconButton(
                    icon: const Icon(Akaricons.chevronLeft),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                title: Column(children: <Widget>[
                  DropdownButton<LogLevel>(
                      items: <DropdownMenuItem<LogLevel>>[
                        _menuItem(LogLevel.DEBUG),
                        _menuItem(LogLevel.INFO),
                        _menuItem(LogLevel.WARNING),
                        _menuItem(LogLevel.ERROR),
                      ],
                      value: _logLevel,
                      onChanged: (LogLevel val) {
                        setState(() {
                          _logLevel = val;
                        });
                      })
                ]),
              ),
              body: widget);
        });
  }

  Future<ListView> logListView() async {
    final List<Log> logs =
        await FLog.getAllLogsByFilter(logLevels: _levelToLevels(_logLevel));

    final List<Container> rows = <Container>[];
    for (int i = logs.length - 1; i >= logs.length - _maxResults; i--) {
      final Log log = logs[i];
      rows.add(Container(
        padding:
            const EdgeInsets.only(top: 5.0, bottom: 2.0, left: 10, right: 10),
        child: Row(
          children: <Widget>[
            Flexible(
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: _levelToString(log.logLevel).substring(0, 4),
                  style: TextStyle(
                      color: _levelToColour(log.logLevel),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Inconsolata'),
                ),
                TextSpan(
                  text: ' ~ ${log.timestamp}\n',
                  style: const TextStyle(
                      color: MyColour.grey,
                      fontWeight: FontWeight.w100,
                      fontSize: 12,
                      fontFamily: 'Inconsolata'),
                ),
                TextSpan(
                  text: log.text,
                  style: const TextStyle(
                      color: MyColour.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Inconsolata'),
                ),
              ])),
            ),
          ],
        ),
      ));
    }
    return ListView(children: rows);
  }

  DropdownMenuItem<LogLevel> _menuItem(LogLevel level) {
    return DropdownMenuItem<LogLevel>(
        value: level,
        child: Text(
          _levelToString(level),
          style: TextStyle(
              color: _levelToColour(level), fontWeight: FontWeight.w600),
        ));
  }

  List<String> _levelToLevels(LogLevel level) {
    if (level == LogLevel.INFO) {
      return <String>[
        LogLevel.INFO.toString(),
        LogLevel.WARNING.toString(),
        LogLevel.ERROR.toString(),
      ];
    } else if (level == LogLevel.WARNING) {
      return <String>[LogLevel.WARNING.toString(), LogLevel.ERROR.toString()];
    } else if (level == LogLevel.ERROR) {
      return <String>[LogLevel.ERROR.toString()];
    }
    return <String>[
      LogLevel.DEBUG.toString(),
      LogLevel.INFO.toString(),
      LogLevel.WARNING.toString(),
      LogLevel.ERROR.toString(),
    ];
  }

  String _levelToString(LogLevel level) {
    return level.toString().replaceAll('LogLevel.', '');
  }

  Color _levelToColour(LogLevel level) {
    if (level == LogLevel.INFO) {
      return MyColour.darkGrey;
    } else if (level == LogLevel.WARNING) {
      return MyColour.orange;
    } else if (level == LogLevel.ERROR) {
      return MyColour.red;
    }
    return MyColour.grey;
  }
}
