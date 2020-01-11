//
//  Notification.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NotificationLabel;
@interface Notification: NSView

@property (strong) NSTrackingArea* trackingArea;

@property (nonatomic) unsigned long ID;
@property (nonatomic) bool read;
@property (nonatomic) NSString* title_string;
@property (nonatomic) NSString* message_string;
@property (nonatomic) NSString* link;
@property (nonatomic) NSString* image_url;
@property NotificationLabel* title_label;
@property NotificationLabel* time_label;
@property NotificationLabel* info_label;

//time
@property NSDate* time;
@property NSString* str_time;

// expand and shrink
@property (nonatomic) bool expanded;
@property int height_diff;
@property float expand_height;
@property float shrink_height;
@property float text_width;
@property float title_height_change;

@property float time_frame_shrink_y;
@property float info_frame_shrink_y;

@property NSFont* title_font;
@property NSFont* info_font;

- (id) initWithTitle:(NSString *)title message:(NSString *)message link:(NSString*)link image_url:(NSString*)image_url time_string:(NSString*)time_string read:(bool)read ID:(unsigned long)ID;
- (void) markRead;
- (void) markRead:(bool)isall;
- (void) markUnread;
- (void) reloadTime;
- (void) shrink:(bool)animate;
- (unsigned long) defaultsIndex;
+ (void) storeNotificationDic:(NSDictionary*)nDic;
@end

