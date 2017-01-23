//
//  AppDelegate.h
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SRWebSocket.h>
#import <AsyncImageDownloader.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic) NSMenuItem* showOnStartupItem;
@property (nonatomic) NSMenuItem* credentialsItem;
@property (nonatomic) NSMenuItem* errorItem;
@property (nonatomic) NSMenuItem* window_item;
@property (nonatomic) NSStatusItem *statusItem;

//window
@property NSColor* black;
@property NSColor* white;
@property NSColor* red;
@property NSColor* grey;
@property NSColor* offwhite;
@property (nonatomic, weak) NSImageView *window_up_arrow_view;
@property (nonatomic) NSWindow* window;
@property (nonatomic, weak) NSView* view;
@property (strong) NSMutableArray *time_fields;
@property (strong) NSMutableArray *notification_views;
@property (nonatomic, strong) NSScrollView *scroll_view;
@property (nonatomic, strong) NSTableView* notification_table;
@property (strong) NSString* split_message;

@property (nonatomic) int notification_id;
@property (nonatomic) NSMutableArray *alreadyStoredIDs;

//SR
//@property (nonatomic, weak) id <SRWebSocketDelegate> delegate;
@property (nonatomic, strong) SRWebSocket *webSocket;

-(bool)notificationRead:(int)index;
-(void)markAsRead:(bool)read index:(int)index;
-(void)deleteNotification:(int)index;
-(NSString*)notificationLink:(int)index;


@end

