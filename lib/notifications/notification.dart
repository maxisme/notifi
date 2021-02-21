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
  String message;
  String image;
  String link;
  bool isRead;
  bool isExpanded;

  NotificationUI(this.id, this.title, this.time, this.UUID,
      {Key key, this.message, this.image, this.link})
      : super(key: key);

  factory NotificationUI.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @override
  NotificationUIState createState() => new NotificationUIState();

  toggleRead(bool isRead){
    this.isRead = isRead;
  }
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
    if (widget.message != null) {
      messageRow = Row(children: <Widget>[
        Flexible(
            child: SelectableText(
                widget.message,
                scrollPhysics:
                NeverScrollableScrollPhysics(),
                style: TextStyle(
                    color: MyColour.black,
                    fontSize: 15),
                minLines: 1,
                maxLines: messageMaxLines)),
      ]);
    }else{
      messageRow = Container(width: 0, height: 0);
    }

    // if link
    var linkBtn;
    if (widget.link != null) {
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
    if (widget.image != null) {
      image = GestureDetector(
          onTap: _launchImageLink,
          child: Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: CachedNetworkImage(
                  fadeInDuration: new Duration(seconds: 1),
                  imageUrl: widget.image,
                  width: 50,
                  filterQuality: FilterQuality.high)));
    }

    var titleStyle = TextStyle(
        color: titleColour, fontSize: 20, fontWeight: FontWeight.w600);

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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // mark as read
                                InkWell(
                                    onTap: () async {
                                      print("delete");
                                    },
                                    child: Container(
                                        child: Icon(
                                          Icons.close,
                                          size: 15,
                                          color: MyColour.grey,
                                        ))),

                                // mark as read
                                // InkWell(
                                //     onTap: () async {
                                //       print("mark read");
                                //     },
                                //     child: Container(
                                //         padding:
                                //             const EdgeInsets.only(top: 5.0),
                                //         child: Icon(
                                //           Icons.check,
                                //           size: 20,
                                //           color: MyColour.grey,
                                //         ))),
                                //
                                // // link
                                // if (linkBtn != null) linkBtn,
                                //
                                // // expand
                                // InkWell(
                                //     onTap: () async {
                                //       print("expand");
                                //     },
                                //     child: Container(
                                //         padding:
                                //             const EdgeInsets.only(top: 5.0),
                                //         child: Icon(
                                //           Icons.zoom_out_map,
                                //           size: 20,
                                //           color: MyColour.grey,
                                //         )))
                              ])),
                      // IMAGE
                      Flexible(
                        fit: FlexFit.tight,
                        flex: image != null ? 5 : 0,
                        child: image != null
                            ? image
                            : Container(width: 0, height: 0), // optional image
                      ),
                      Spacer(),
                      // CONTENT
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 60,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // TITLE
                                Container(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: SelectableText(widget.title,
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
                                            color: MyColour.grey,
                                            fontSize: 12)),
                                  ]),
                                ),

                                // MESSAGE
                                messageRow
                              ]))
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
