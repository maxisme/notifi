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

@implementation Socket

- (id)initWithURL:(NSString*)url{
    if (self != [super init]) return nil;
    _url = url;
    
    [self open];
    
    // send ping every 10 seconds to make sure still connected to server
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    
    return self;
}

-(void)open{
    NSLog(@"opening socket");
    [self destroy];
    
    _web_socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:_url]];
    [_web_socket setDelegate:(id)self];
    [_web_socket open];
}

-(void)destroy{
    [_web_socket close];
    _web_socket.delegate = nil;
    _web_socket = nil;
    _authed = false;
    _connected = false;
}

- (void)sendPing{
    if(_web_socket.readyState == SR_OPEN){
        [_web_socket sendPing:nil];
        _received_pong = false;
        
        //check for pong in 1 second
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(!_received_pong){
                [self close];
            }
        });
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    _received_pong = true;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"socket open");
    _connected = true;
    
    if(_reconnect_timer){
        [_reconnect_timer invalidate];
        _reconnect_timer = nil;
    }
    
    if (self.onConnectBlock) _onConnectBlock();
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Socket failed with error: %@", error);
    [self close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(nonnull NSString *)string
{
    if (self.onMessageBlock) _onMessageBlock(string);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"Socket closed with reason: %@", reason);
    [self close];
}

-(void)send:(NSString*)m{
    if(_web_socket.readyState == SR_OPEN) [_web_socket send:m];
}

-(void)close{
    if(!_reconnect_timer){
        if (self.onCloseBlock) _onCloseBlock();
        [self destroy];
        
        // attempt to open socket again every 5 seconds
        _reconnect_timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(open) userInfo:nil repeats:YES];
    }
}

@end

