//
//  Link.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Notification;

@interface NotificationLink: NSImageView
@property (nonatomic, strong) Notification *notification;
@property (strong) NSTrackingArea* trackingArea;
@property (strong) NSMenu* customMenu;
@property NSString* url;
@end
