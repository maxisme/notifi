import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:notifi/pallete.dart';
import 'package:url_launcher/url_launcher.dart';

@JsonSerializable()
class NotificationUI extends StatefulWidget {
  final String title;
  final String UUID;
  final String time;
  int id;
  int index;
  String message;
  String image;
  String link;
  bool isRead;
  bool isExpanded;
  void Function(int id) toggleExpand;
  void Function(int id) toggleRead;

  NotificationUI(this.id, this.title, this.time, this.UUID,
      {Key key, this.message, this.image, this.link, this.isRead})
      : super(key: key);

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
    message: json['message'] as String,
    image: json['image'] as String,
    link: json['link'] as String,
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
  @override
  Widget build(BuildContext context) {
    if (widget.isExpanded == null) widget.isExpanded = false;
    if (widget.isRead == null) widget.isRead = false;

    // if expanded notification
    var messageMaxLines = 3;
    var titleMaxLines = 1;
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
            child: SelectableText(widget.message,
                onTap: () {
                  setState(() {
                    widget.toggleExpand(widget.index);
                  });
                },
                scrollPhysics: NeverScrollableScrollPhysics(),
                style: TextStyle(color: MyColour.black, fontSize: 10),
                minLines: 1,
                maxLines: messageMaxLines)),
      ]);
    } else {
      messageRow = Container(width: 0, height: 0);
    }

    // if link
    var linkBtn;
    if (widget.link != "") {
      linkBtn = InkWell(
          onTap: () async {
            if (await canLaunch(widget.link)) {
              await launch(widget.link);
            } else {
              print("can't open: " + widget.link);
            }
          },
          child: Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: Icon(
                Icons.link,
                size: 20,
                color: MyColour.grey,
              )));
    }

    // if image
    var image;
    if (widget.image != "") {
      image = SizedBox(
          width: 60,
          child: GestureDetector(
              onTap: _launchImageLink,
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
        padding: const EdgeInsets.all(10.0),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: MyColour.offGrey),
                color: backgroundColour,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // mark as read
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        widget.toggleRead(widget.index);
                                      });
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Icon(
                                          Icons.check,
                                          size: 15,
                                          color: MyColour.grey,
                                        ))),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        widget.toggleExpand(widget.index);
                                      });
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.only(top: 7.0),
                                        child: Icon(
                                          Icons.zoom_out_map,
                                          size: 15,
                                          color: MyColour.grey,
                                        )))
                              ]),
                        ),
                      ),
                      image != null ? image : Container(width: 0, height: 0),
                      Expanded(
                          child: SizedBox(
                        width: double.infinity,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // TITLE
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: SelectableText(widget.title,
                                    onTap: () {
                                      setState(() {
                                        widget.toggleExpand(widget.index);
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
                                padding: const EdgeInsets.only(bottom: 7.0),
                                child: Row(children: <Widget>[
                                  SelectableText(widget.time,
                                      style: TextStyle(
                                          color: MyColour.grey, fontSize: 12)),
                                ]),
                              ),

                              // MESSAGE
                              messageRow
                            ]),
                      ))
                    ]))));
  }

  _launchImageLink() async {
    if (await canLaunch(widget.image)) {
      await launch(widget.image);
    } else {
      throw 'Could not launch ' + widget.image;
    }
  }
}
