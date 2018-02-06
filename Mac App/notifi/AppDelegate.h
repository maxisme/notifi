//
//  AppDelegate.h
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

// apple
#import <Cocoa/Cocoa.h>

@class Keys;
@class NotificationTable;
@class Socket;
@class SettingsMenu;
@class Window;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property NSMutableArray* notifications;

@property Keys *keychain;
@property SettingsMenu* sm;

@property NSStatusItem* status_item;

@property NSMenuItem* window_item;

@property (nonatomic, strong) Socket* s;
@property bool socket_authed;

@property Window* window;
@property NSImageView *window_up_arrow_view;
@property NSView* view;
@property NSView *vis_view;
@property (strong) NSScrollView *scroll_view;
@property (nonatomic, strong) NotificationTable* notification_table;

@property NSWindow* about_window;

@end


