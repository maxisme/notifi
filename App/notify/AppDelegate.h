//
//  AppDelegate.h
//  notify
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) NSMenuItem* showOnStartupItem;
@property (nonatomic) NSMenuItem* credentialsItem;
@property (nonatomic) NSMenuItem* errorItem;
@property (nonatomic) NSMenuItem* window_item;
@property (nonatomic) NSStatusItem *statusItem;

//window
@property (nonatomic) NSWindow* window;
@property (nonatomic) NSView* view;

@property (nonatomic) int notification_id;

-(bool)notificationRead:(int)index;
-(void)markAsRead:(bool)read index:(int)index;
-(void)deleteNotification:(int)index;


@end

