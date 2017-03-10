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
#import <SAMKeychain.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property SAMKeychainQuery *keychainQuery;
@property NSMenuItem* showOnStartupItem;
@property NSMenuItem* credentialsItem;
@property NSMenuItem* errorItem;
@property NSMenuItem* window_item;
@property NSStatusItem *statusItem;

//window
@property NSColor* black;
@property NSColor* white;
@property NSColor* red;
@property NSColor* grey;
@property NSColor* offwhite;
@property NSImageView *window_up_arrow_view;
@property NSWindow* window;
@property NSView* view;
@property (strong) NSMutableArray *time_labels;
@property (strong) NSMutableArray *notification_views;
@property (strong) NSScrollView *scroll_view;
@property (strong) NSTableView* notification_table;
@property (strong) NSString* split_message;

@property int notification_id;
@property NSMutableArray *alreadyStoredIDs;

//SR
//@property (nonatomic, weak) id <SRWebSocketDelegate> delegate;
@property (nonatomic, strong) SRWebSocket *webSocket;

-(bool)notificationRead:(int)index;
-(void)markAsRead:(bool)read index:(int)index;
-(void)deleteNotification:(int)index;
-(NSString*)notificationLink:(int)index;
-(NSString*)imageLink:(int)index;

@end

