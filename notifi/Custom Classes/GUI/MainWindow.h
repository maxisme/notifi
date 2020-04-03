//
//  Window.h
//  notifi
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MenuWindow.h"

@class SettingsMenu;
@class NotificationTable;
@class Notification;

@interface MainWindow : MenuWindow <NSTableViewDelegate, NSTableViewDataSource>
@property NSTextField* error_label;

@property SettingsMenu* settings_menu;

// notification table
@property (nonatomic, strong) NotificationTable* notification_table;
@property (strong) NSScrollView *scroll_view;
@property NSMutableArray* notifications;
@property NSMutableArray *animated_notifications;

-(void)setWindowBody;
-(void)animate:(bool)should_delay;
-(void)animate:(bool)should_delay scroll:(bool)should_scroll;
-(int)numUnreadNotifications;
-(Notification*)createNotificationFromDic:(NSDictionary*)dic;
-(Notification*)notificationFromID:(unsigned long)ID;
@end
