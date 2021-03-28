import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:notifi/notifications/notifis.dart';
import 'package:notifi/pallete.dart';
import 'package:notifi/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@JsonSerializable()
class NotificationUI extends StatefulWidget {
  final String title;
  final String UUID;
  final String time;
  final String message;
  final String image;
  final String link;
  int id;
  int index;
  bool read = false;
  bool isExpanded = false;
  void Function(int id) toggleExpand;

  NotificationUI(this.id, this.title, this.time, this.UUID, this.message,
      this.image, this.link,
      {Key key, this.read})
      : super(key: key);

  bool get isRead => read != null && read;

  factory NotificationUI.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @override
  NotificationUIState createState() => new NotificationUIState();
}

NotificationUI _$NotificationFromJson(Map<String, dynamic> json) {
  return NotificationUI(
    json['id'] as int,
    json['title'] as String,
    json['time'] as String,
    json['UUID'] as String,
    json['message'] as String,
    json['image'] as String,
    json['link'] as String,
    read: false,
  );
}

Map<String, dynamic> _$NotificationToJson(NotificationUI instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'time': instance.time,
      'message': instance.message,
      'image': instance.image,
      'link': instance.link
    };

class NotificationUIState extends State<NotificationUI> {
  GlobalKey _columnKey = GlobalKey();
  GlobalKey _titleKey = GlobalKey();
  static const _CANEXPANDHEIGHT = 116;

  bool _canExpand = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReloadTable>(builder: (context, reloadTable, child) {
      const iconSize = 15.0;
      var messageMaxLines = 3;
      var titleMaxLines = 1;
      if (widget.isExpanded == null) widget.isExpanded = false;

      // if expanded notification
      if (widget.isExpanded) {
        // no limit on lines TODO must be a better way to handle this
        titleMaxLines = null;
        messageMaxLines = null;
      }

      // if read notification
      var backgroundColour = Colors.white;
      var titleColour = MyColour.black;
      if (widget.isRead) {
        backgroundColour = MyColour.offWhite;
        titleColour = MyColour.black;
      }

      // if message
      var messageRow;
      if (widget.message != "") {
        messageRow = Row(children: <Widget>[
          Flexible(
              child: SelectableText(widget.message, onTap: () {
            setState(() {
              if (!widget.isExpanded) {
                widget.toggleExpand(widget.index);
              }
            });
          },
                  scrollPhysics: NeverScrollableScrollPhysics(),
                  style: TextStyle(
                      color: MyColour.black,
                      fontSize: 10,
                      letterSpacing: 0.2,
                      height: 1.4),
                  minLines: 1,
                  maxLines: messageMaxLines)),
        ]);
      } else {
        messageRow = Container();
      }

      // if link
      var linkBtn;
      if (widget.link != null) {
        linkBtn = InkWell(
            onTap: () async {
              await openUrl(widget.link);
            },
            child: Container(
                padding: const EdgeInsets.only(top: 5.0),
                child: Icon(
                  Icons.link,
                  size: iconSize,
                  color: MyColour.grey,
                )));
      }

      // if image
      var image;
      if (widget.image != "") {
        image = SizedBox(
            width: 60,
            child: GestureDetector(
                onTap: () async{
                  await openUrl(widget.image);
                },
                child: Container(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: CachedNetworkImage(
                        fadeInDuration: new Duration(seconds: 1),
                        imageUrl: widget.image,
                        width: 50,
                        filterQuality: FilterQuality.high))));
      }

      var titleStyle = TextStyle(
          color: titleColour, fontSize: 14, fontWeight: FontWeight.w600);

      return Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(10.0),
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: MyColour.offGrey),
                  color: backgroundColour,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            width: 15,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                          child: Icon(
                                            Icons.check,
                                            size: iconSize,
                                            color: MyColour.grey,
                                          ))),
                                  linkBtn != null ? linkBtn : Container(),
                                  _canExpand
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.toggleExpand(widget.index);
                                            });
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.only(
                                                  top: 7.0),
                                              child: Icon(
                                                widget.isExpanded
                                                    ? Icons.compress
                                                    : Icons.expand,
                                                size: iconSize,
                                                color: MyColour.grey,
                                              )))
                                      : Container()
                                ]),
                          ),
                        ),
                        image != null ? image : Container(),
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
                                          NeverScrollableScrollPhysics(),
                                      style: titleStyle,
                                      textAlign: TextAlign.left,
                                      minLines: 1,
                                      maxLines: titleMaxLines),
                                ),

                                // TIME
                                Container(
                                  child: Row(children: <Widget>[
                                    SelectableText(widget.time,
                                        style: TextStyle(
                                            color: MyColour.grey,
                                            fontSize: 12)),
                                  ]),
                                ),

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
  }

  _canExpandHandler(BuildContext context) {
    var canExpand = false;
    // for title
    if (_titleKey.currentContext.size.width >=
        _columnKey.currentContext.size.width) {
      canExpand = true;
    }

    // for message
    if (context.size.height >= _CANEXPANDHEIGHT) {
      canExpand = true;
    }

    if (canExpand) {
      setState(() {
        _canExpand = true;
      });
    }
  }
}
