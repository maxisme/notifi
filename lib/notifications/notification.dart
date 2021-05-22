import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' as i;
import 'package:json_annotation/json_annotation.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/utils/icons.dart';
import 'package:notifi/utils/pallete.dart';
import 'package:notifi/utils/utils.dart';
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
    this.canExpand,
    Key key,
  }) : super(key: key) {
    message = message ?? '';
    image = image ?? '';
    link = link ?? '';
    read = read ?? false;
    canExpand = canExpand ?? false;
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
  bool canExpand;
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
      title: eParser.emojify(json['title'] as String),
      message: eParser.emojify(json['message'] as String),
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
  NotificationUIState();

  final GlobalKey _columnKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _messageKey = GlobalKey();
  final ValueNotifier<String> _timeStr = ValueNotifier<String>('');
  Timer timer;
  SlideActionType mouseSliderAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _canExpandHandler(context));
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) => _setTime());
  }

  @override
  void dispose() {
    mouseSliderAction = null;
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Notifications>(builder:
        (BuildContext context, Notifications reloadTable, Widget child) {
      const double iconSize = 15.0;
      int messageMaxLines = 3;
      int titleMaxLines = 1;

      _setTime();

      // if expanded notification
      if (widget.isExpanded) {
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
        messageRow = Container(
          padding: const EdgeInsets.only(top: 3),
          child: Row(key: _messageKey, children: <Widget>[
            Flexible(
                child: SelectableText(widget.message, onTap: () {
              setState(() {
                if (!widget.isExpanded) {
                  widget.toggleExpand(widget.index);
                }
              });
            },
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    style: Theme.of(context).textTheme.bodyText1,
                    minLines: 1,
                    maxLines: messageMaxLines)),
          ]),
        );
      } else {
        messageRow = const SizedBox();
      }

      // if link
      Widget linkBtn;
      if (widget.link != '') {
        linkBtn = InkWell(
            onTap: () async {
              await openUrl(widget.link);
              setState(() {
                Provider.of<Notifications>(context, listen: false)
                    .markRead(widget.index, isRead: true);
              });
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
        image = MouseRegion(
          cursor: SystemMouseCursors.alias,
          child: GestureDetector(
              onTap: () async {
                await openUrl(widget.image);
                Provider.of<Notifications>(context, listen: false)
                    .toggleRead(widget.index);
              },
              child: Container(
                padding: const EdgeInsets.only(right: 10.0, top: 3.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: CachedNetworkImage(
                        imageUrl: widget.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorWidget:
                            (BuildContext context, String url, dynamic error) {
                          return const SizedBox();
                        },
                        filterQuality: FilterQuality.medium)),
              )),
        );
      }

      const double padding = 10.0;

      final Container slideNotification = Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(
              left: padding, right: padding, top: padding),
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).indicatorColor),
                  color: backgroundColour,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(padding))),
              child: Container(
                  padding: const EdgeInsets.all(padding),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(right: padding),
                          child: SizedBox(
                            width: 15,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
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
                                  if (widget.canExpand)
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
                                    Container(),
                                  if (linkBtn != null) linkBtn,
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          .copyWith(color: titleColour),
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
                                        return Expanded(
                                          child: SelectableText(timeStr,
                                              style: const TextStyle(
                                                  color: MyColour.grey,
                                                  fontSize: 12)),
                                        );
                                      })
                                ]),

                                // MESSAGE
                                messageRow
                              ]),
                        ))
                      ]))));

      if (Platform.isMacOS) {
        final SlidableState slider = Slidable.of(context);
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final double paddingArea = constraints.maxWidth - padding - 5;
          return MouseRegion(
              onHover: (PointerHoverEvent event) {
                SlideActionType actionType;
                if (event.position.dx > paddingArea) {
                  mouseSliderAction = actionType = SlideActionType.secondary;
                } else if (event.position.dx <= padding + 5) {
                  mouseSliderAction = actionType = SlideActionType.primary;
                } else {
                  Slidable.of(context).close();
                  mouseSliderAction = null;
                }

                // Add delay to make sure mouse is in area for a set amount of
                // time
                Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
                  if (mouseSliderAction != null &&
                      mouseSliderAction == actionType &&
                      slider != null) {
                    slider.open(actionType: actionType);
                  }
                });
              },
              onExit: (_) {
                mouseSliderAction = null;
              },
              child: slideNotification);
        });
      }
      return GestureDetector(
          onLongPress: () {
            setState(() {
              Provider.of<Notifications>(context, listen: false)
                  .toggleRead(widget.index);
            });
          },
          child: slideNotification);
    });
  }

  void _canExpandHandler(BuildContext context) {
    bool canExpand = false;

    if (_columnKey.currentContext != null &&
        hasTextOverflow(widget.title, Theme.of(context).textTheme.headline1,
            maxWidth: _columnKey.currentContext.size.width)) {
      canExpand = true;
    } else if (_messageKey.currentContext != null &&
        widget.message != '' &&
        hasTextOverflow(widget.message, Theme.of(context).textTheme.bodyText1,
            maxWidth: _messageKey.currentContext.size.width, maxLines: 3)) {
      canExpand = true;
    }

    if (canExpand) {
      widget.canExpand = true;
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
