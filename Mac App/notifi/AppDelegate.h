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
@class ControlButton;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

// store secret to credentials in keychain
@property Keys *keychain;

// socket
@property (nonatomic, strong) Socket* s;
@property bool socket_authed;

// GUI
@property Window* window;
@property NSView* view;
@property NSView *vis_view;
@property SettingsMenu* sm;
@property (nonatomic, strong) NotificationTable* notification_table;
@property NSStatusItem* status_item;
@property NSMenuItem* window_item;
@property NSImageView *window_up_arrow_view;
@property (strong) NSScrollView *scroll_view;
@property NSTextField* error_label;
@property NSWindow* about_window;

// window helpers
@property NSMutableArray* notifications;
@property NSTimer* animate_bell_timer;

@end


