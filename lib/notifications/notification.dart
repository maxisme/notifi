import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:notifi/pallete.dart';
import 'package:url_launcher/url_launcher.dart';

@JsonSerializable(nullable: false)
class NotificationUI extends StatefulWidget {
  final String title;
  final String time;
  String message;
  String image;
  String link;
  int id;
  bool isRead;
  bool isExpanded;

  NotificationUI(this.title, this.time,
      {Key key, this.message, this.image, this.link})
      : super(key: key);

  factory NotificationUI.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @override
  NotificationUIState createState() => new NotificationUIState();
}

NotificationUI _$NotificationFromJson(Map<String, dynamic> json) {
  return NotificationUI(
    json['title'] as String,
    json['time'] as String,
    message: json['message'] as String,
    image: json['image'] as String,
    link: json['link'] as String,
  );
}

Map<String, dynamic> _$NotificationToJson(NotificationUI instance) =>
    <String, dynamic>{
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
    var messageMaxLines = 2;
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

    // if link
    var linkBtn;
    if (widget.link.length > 0) {
      linkBtn = InkWell(
        onTap: () async {
          if (await canLaunch(widget.link)) {
            await launch(widget.link);
          } else {
            print("can't open: " + widget.link);
          }
        },
        child: Container(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(
              Icons.link,
              color: MyColour.red,
            )),
      );
    }

    // if image
    var image;
    if (widget.image.length > 0) {
      image = GestureDetector(
          onTap: _launchImageLink,
          child: Container(
              padding: const EdgeInsets.only(top: 10.0),
              child: CachedNetworkImage(
                  fadeInDuration: new Duration(seconds: 1),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  imageUrl: widget.image,
                  width: 50,
                  filterQuality: FilterQuality.high)));
    }

    var titleStyle = TextStyle(
        color: titleColour, fontSize: 20, fontWeight: FontWeight.w600);

//    print(getLinesOfText(1, widget.title, titleStyle));

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
                      // IMAGE // TODO valign top
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
                          fit: FlexFit.loose,
                          flex: 35,
                          child: Column(children: <Widget>[
                            // TITLE
                            Container(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    if (linkBtn != null) linkBtn,
                                    // optional link
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: SelectableText(widget.title,
                                          scrollPhysics:
                                              NeverScrollableScrollPhysics(),
                                          style: titleStyle,
                                          minLines: 1,
                                          maxLines: titleMaxLines),
                                    )
                                  ]),
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
                            Row(children: <Widget>[
                              Flexible(
                                  fit: FlexFit.loose,
                                  child: SelectableText(widget.message ?? "",
                                      scrollPhysics:
                                          NeverScrollableScrollPhysics(),
                                      style: TextStyle(
                                          color: MyColour.black, fontSize: 15),
                                      minLines: 1,
                                      maxLines: messageMaxLines)),
                            ])
                          ]))
                    ]))));
  }

//  getLinesOfText(int maxLines, String text, TextStyle style) {
//    assert(maxLines > 0);
//    while (true) {
//      final tp = TextPainter(text: TextSpan(text: text, style: style));
//      tp.layout(maxWidth: size.maxWidth);
//      final numLines = tp.computeLineMetrics().length;
//      if (numLines <= maxLines) {
//        break;
//      }
//      var textArr = text.split(" ");
//      int valuesToRemove =
//          (textArr.length * ((numLines - maxLines) / numLines)).floor() - 1;
//      var newArr = textArr.sublist(0, valuesToRemove);
//      print(newArr.length);
//      text = newArr.join(" ") + "...";
//    }
//    return text;
//  }

  _launchImageLink() async {
    if (await canLaunch(widget.image)) {
      await launch(widget.image);
    } else {
      throw 'Could not launch ' + widget.image;
    }
  }
}
