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
#import "Keys.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation Socket

- (id)initWithURL:(NSString*)url key:(NSString*)key{
    if (self != [super init]) return nil;
    _url = url;
    _key = key;
    
    _keychain = [[Keys alloc] init];
    
    [self open];
    
    // send ping every 10 seconds to make sure still connected to server
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    
    return self;
}

-(void)open{
    DDLogDebug(@"opening socket");
    [self destroy];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [request setValue:_key forHTTPHeaderField:@"Sec-Key"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] forHTTPHeaderField:@"credentials"];
    [request setValue:[_keychain getKey:@"credential_key"] forHTTPHeaderField:@"credential_key"];
    [request setValue:[CustomFunctions getSystemUUID] forHTTPHeaderField:@"UUID"];
    [request setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];

    _web_socket = [[SRWebSocket alloc] initWithURLRequest:request];
    [_web_socket setDelegate:(id)self];
    [_web_socket open];
}

-(void)destroy{
    [_web_socket close];
    _web_socket.delegate = nil;
    _web_socket = nil;
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
    DDLogDebug(@"socket open");
    _connected = true;
    
    if(_reconnect_timer){
        [_reconnect_timer invalidate];
        _reconnect_timer = nil;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if ([error.localizedDescription rangeOfString:@"406"].location != NSNotFound){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Okay"];
        [alert setMessageText:@"Major Error. Please reopen app. Credentials will change."];
        [alert setInformativeText:[NSString stringWithFormat:@"Crash Message: %@", error]];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        
        // delete credentials
        [_keychain deleteItem:nil];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"credentials"];
        
        // quit app
        [CustomFunctions quit];
    }
    DDLogDebug(@"Socket failed with error: %@", error);
    [self close];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(nonnull NSString *)string
{
    if (self.onMessageBlock) _onMessageBlock(string);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    DDLogDebug(@"Socket closed with reason: %@", reason);
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

