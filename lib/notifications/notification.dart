import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as i;
import 'package:json_annotation/json_annotation.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/utils.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

@JsonSerializable()
// ignore: must_be_immutable
class NotificationUI extends StatefulWidget {
  NotificationUI({
    @required this.uuid,
    @required this.time,
    @required this.title,
    this.message,
    this.image,
    this.link,
    this.id,
    this.read,
    Key key,
  }) : super(key: key) {
    message = message ?? '';
    image = image ?? '';
    link = link ?? '';
    read = read ?? false;
  }

  factory NotificationUI.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  final String uuid;
  final String time;
  final String title;
  String message;
  String image;
  String link;
  int id;
  bool read;
  bool isExpanded = false;
  int index;
  void Function(int id) toggleExpand;

  bool get isRead => read != null && read;

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @override
  NotificationUIState createState() => NotificationUIState();
}

NotificationUI _$NotificationFromJson(Map<String, dynamic> json) {
  return NotificationUI(
      id: json['id'] as int,
      uuid: json['UUID'] as String,
      time: json['time'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      image: json['image'] as String,
      link: json['link'] as String);
}

Map<String, dynamic> _$NotificationToJson(NotificationUI notification) =>
    <String, dynamic>{
      'id': notification.id,
      'title': notification.title,
      'time': notification.time,
      'message': notification.message,
      'image': notification.image,
      'link': notification.link,
      'read': notification.isRead,
    };

class NotificationUIState extends State<NotificationUI> {
  final GlobalKey _columnKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _messageKey = GlobalKey();
  TextStyle messageStyle;
  TextStyle titleStyle;
  final ValueNotifier<String> _timeStr = ValueNotifier<String>('');
  Timer timer;

  @override
  Widget build(BuildContext context) {
    return Consumer<Notifications>(builder:
        (BuildContext context, Notifications reloadTable, Widget child) {
      const double iconSize = 15.0;
      int messageMaxLines = 3;
      int titleMaxLines = 1;

      // parse date
      _setTime();

      // if expanded notification
      if (widget.isExpanded) {
        // no limit on lines TODO must be a better way to handle this
        titleMaxLines = null;
        messageMaxLines = null;
      }

      // if read notification
      Color backgroundColour = Colors.white;
      Color titleColour = MyColour.black;
      if (widget.isRead) {
        backgroundColour = MyColour.offWhite;
        titleColour = MyColour.black;
      }

      // if message
      Widget messageRow;
      if (widget.message != '') {
        messageStyle = const TextStyle(
            inherit: false,
            textBaseline: TextBaseline.alphabetic,
            fontFamily: 'Inconsolata',
            color: MyColour.black,
            fontSize: 10,
            letterSpacing: 0.2,
            height: 1.4);
        messageRow = Row(key: _messageKey, children: <Widget>[
          Flexible(
              child: SelectableText(widget.message, onTap: () {
            setState(() {
              if (!widget.isExpanded) {
                widget.toggleExpand(widget.index);
              }
            });
          },
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  style: messageStyle,
                  minLines: 1,
                  maxLines: messageMaxLines)),
        ]);
      } else {
        messageRow = const SizedBox();
      }

      // if link
      Widget linkBtn;
      if (widget.link != '') {
        linkBtn = InkWell(
            onTap: () async {
              await openUrl(widget.link);
            },
            child: Container(
                padding: const EdgeInsets.only(top: 7.0),
                child: const Icon(
                  Akaricons.link,
                  size: iconSize,
                  color: MyColour.grey,
                )));
      }

      // if image
      Widget image;
      if (widget.image != '') {
        image = SizedBox(
            width: 60,
            child: GestureDetector(
                onTap: () async {
                  await openUrl(widget.image);
                },
                child: Container(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: CachedNetworkImage(
                        fadeInDuration: const Duration(seconds: 1),
                        imageUrl: widget.image,
                        width: 50,
                        filterQuality: FilterQuality.high))));
      }

      titleStyle = TextStyle(
          inherit: false,
          textBaseline: TextBaseline.alphabetic,
          fontFamily: 'Inconsolata',
          color: titleColour,
          fontSize: 14,
          fontWeight: FontWeight.w600);

      return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(10.0),
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: MyColour.offGrey),
                  color: backgroundColour,
                  borderRadius: const BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            width: 15,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // ignore: always_specify_types
                                children: [
                                  // mark as read
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          Provider.of<Notifications>(context,
                                                  listen: false)
                                              .toggleRead(widget.index);
                                        });
                                      },
                                      child: Container(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: const Icon(
                                            Akaricons.check,
                                            size: iconSize,
                                            color: MyColour.grey,
                                          ))),
                                  if (linkBtn != null) linkBtn,
                                  if (_canExpand)
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            widget.toggleExpand(widget.index);
                                          });
                                        },
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(top: 7.0),
                                            child: Icon(
                                              widget.isExpanded
                                                  ? Akaricons.reduce
                                                  : Akaricons.enlarge,
                                              size: iconSize,
                                              color: MyColour.grey,
                                            )))
                                  else
                                    Container()
                                ]),
                          ),
                        ),
                        image ?? Container(),
                        Expanded(
                            child: SizedBox(
                          width: double.infinity,
                          child: Column(
                              key: _columnKey,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // TITLE
                                Container(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: SelectableText(widget.title,
                                      key: _titleKey, onTap: () {
                                    setState(() {
                                      if (!widget.isExpanded) {
                                        widget.toggleExpand(widget.index);
                                      }
                                    });
                                  },
                                      scrollPhysics:
                                          const NeverScrollableScrollPhysics(),
                                      style: titleStyle,
                                      textAlign: TextAlign.left,
                                      minLines: 1,
                                      maxLines: titleMaxLines),
                                ),

                                // TIME
                                Row(children: <Widget>[
                                  ValueListenableBuilder<String>(
                                      valueListenable: _timeStr,
                                      builder: (BuildContext context,
                                          String timeStr, Widget child) {
                                        return SelectableText(timeStr,
                                            style: const TextStyle(
                                                color: MyColour.grey,
                                                fontSize: 12));
                                      })
                                ]),

                                // MESSAGE
                                messageRow
                              ]),
                        ))
                      ]))));
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _canExpandHandler(context));
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => _setTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool _canExpand = false;

  void _canExpandHandler(BuildContext context) {
    bool canExpand = false;
    // for title
    if (_columnKey.currentContext != null &&
        hasTextOverflow(widget.title, titleStyle,
            maxWidth: _columnKey.currentContext.size.width)) {
      canExpand = true;
    } else if (_messageKey.currentContext != null &&
        widget.message != '' &&
        hasTextOverflow(widget.message, messageStyle,
            maxWidth: _messageKey.currentContext.size.width, maxLines: 3)) {
      canExpand = true;
    }

    if (canExpand) {
      _canExpand = true;
      setState(() {});
    }
  }

  void _setTime() {
    final DateTime dttm =
        i.DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.time, true).toLocal();
    final String friendlyDttm = i.DateFormat('MMM d, y HH:mm:ss').format(dttm);
    _timeStr.value = '$friendlyDttm - ${timeago.format(dttm)}';
  }

  bool hasTextOverflow(String text, TextStyle style,
      {double maxWidth = double.infinity, int maxLines = 1}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    )..layout(minWidth: 0, maxWidth: maxWidth - 1);
    // not really sure why I have to -1
    return textPainter.didExceedMaxLines;
  }
}
