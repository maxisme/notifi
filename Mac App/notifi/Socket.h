//
//  Socket.h
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SRWebSocket;
@class Keys;

@interface Socket : NSObject
@property Keys *keychain;
@property (nonatomic, strong) SRWebSocket *web_socket;
@property (nonatomic, strong) NSTimer *reconnect_timer;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *key;
@property (nonatomic) bool received_pong;
@property (nonatomic) bool connected;
@property (copy, nonatomic) void (^onCloseBlock)(void);
@property (copy, nonatomic) void (^onMessageBlock)(NSString*);

- (id)initWithURL:(NSString*)url key:(NSString*)key;
- (void)send:(NSString*)m;
- (void)open;
@end

