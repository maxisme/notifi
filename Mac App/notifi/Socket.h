//
//  Socket.h
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SRWebSocket;

@interface Socket : NSObject
@property (nonatomic, strong) SRWebSocket *web_socket;
@property (nonatomic) NSString *url;
@property (nonatomic) bool received_pong;
@property (nonatomic) bool connecting;
@property (nonatomic) bool connected;
@property (copy, nonatomic) void (^onConnectBlock)(void);
@property (copy, nonatomic) void (^onCloseBlock)(void);
@property (copy, nonatomic) void (^onMessageBlock)(NSString*);

- (id)initWithURL:(NSString*)url;
- (void)send:(NSString*)m;
- (void)close;
@end
