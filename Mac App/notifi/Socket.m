//
//  Socket.m
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "Socket.h"

#import <SocketRocket/SRWebSocket.h>
#import "CustomFunctions.h"
#import "Log.h"

@implementation Socket

- (id)initWithURL:(NSString*)url{
    if (self != [super init]) return nil;
    
    _url = url;
    
    [self create];
    
    // send ping every 30 seconds to make sure still connected to server
    [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    
    return self;
}

-(void)create{
    _web_socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:_url]];
    [_web_socket setDelegate:(id)self];
    [_web_socket open];
}

-(void)destroy{
    _connecting = true;
    _connected = false;
    _web_socket.delegate = nil;
    _web_socket = nil;
    [_web_socket close];
}

- (void)sendPing{
    _received_pong = false;
    if(_connected) [_web_socket sendPing:nil];
    
    //check for pong in 1 second
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(!_received_pong){
            [self close];
        }
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    _received_pong = true;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"open");
    _connected = true;
    
    if (self.onConnectBlock) _onConnectBlock();
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(nonnull NSString *)string
{
    if (self.onMessageBlock) _onMessageBlock(string);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    [self close];
}

-(void)send:(NSString*)m{
    [_web_socket send:m];
}

-(void)close{
    [self destroy];
    
    // run user code
    if (self.onCloseBlock) _onCloseBlock();
    
    // automatic reconnect attempt after 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self create];
    });
}

@end
