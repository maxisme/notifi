//
//  User.m
//  notifi
//
//  Created by Maximilian Mitchell on 16/02/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "User.h"

#import <STHTTPRequest/STHTTPRequest.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#import "LOOCryptString.h"

#import "CustomVars.h"
#import "CustomFunctions.h"

#import "LOOCryptString.h"

#import "Socket.h"
#import "MainWindow.h"
#import "MenuBarClass.h"
#import "Keys.h"
#import "Notification.h"
#import "NotificationTable.h"

#import "SettingsMenu.h" //two classes in - _window.settings_menu.credentials

#define STICKYTIME 10
@implementation User
-(id)initWithMenuBar:(MenuBarClass*)mb{
    if (self != [super init]) return nil;
    
    _menu_bar = mb;
    _window = mb.window;
    
    _menu_bar.bell_image_cnt = 1;
    
    //update menu icon listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMBIcon:) name:@"update-menu-icon" object:nil];
    
    return self;
}

+(bool)newCredentials{
    NSString* backend_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Backend URL"];
    NSString* credential_ref = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Credential Ref"];
    NSString* credential_key_ref = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Credential Key Ref"];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:[NSString stringWithFormat:@"%@/code", backend_url]];
    NSMutableDictionary* post = [[NSMutableDictionary alloc] initWithDictionary:@{@"UUID":[CustomFunctions getSystemUUID]}];
    
    // give server current credentials if it has them
    NSString* current_credentials = [[NSUserDefaults standardUserDefaults] objectForKey:credential_ref];
    NSString* current_key = [[[Keys alloc] init] getKey:credential_key_ref];
    if(current_credentials && current_key){
        [post addEntriesFromDictionary:@{
            @"current_credentials": current_credentials,
            @"current_key": current_key
        }];
    }
    
    r.requestHeaders = [[NSMutableDictionary alloc] initWithDictionary:@{@"Sec-Key":[LOOCryptString serverKey]}];
    r.POSTDictionary = post;
    NSError *error = nil;
    NSString *content = [r startSynchronousWithError:&error];
    
    NSString* key = [CustomFunctions jsonToVal:content key:@"key"]; // password to credentials so no one else can use credentials
    NSString* credentials = [CustomFunctions jsonToVal:content key: @"credentials"];
    
    if([key length] > 0){
        [[[Keys alloc] init] setKey:credential_key_ref withPassword:key]; // store key to credentials in keychain
        if (![credentials isEqual: @""]){
            // store credentials in normal storage
            [[NSUserDefaults standardUserDefaults] setObject:credentials forKey:credential_ref];
            [[NSUserDefaults standardUserDefaults] synchronize];
            DDLogInfo(@"Updating credentials");
        }
        DDLogInfo(@"Succesfully set new credentials!");
    }else{
        if (error){
            DDLogError(@"Error creating new credentials %@", [error localizedDescription]);
        }
        if ([content length] > 0){
            DDLogError(@"Error content: %@", content);
            // TODO handle with http error code.
            if ([content rangeOfString:@"Error 1062"].location != NSNotFound) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"Okay"];
                [alert setMessageText:@"Error fetching credentials. Please contact max@max.me.uk quoting your UUID:"];
                [alert setInformativeText:[CustomFunctions getSystemUUID]];
                [alert setAlertStyle:NSAlertStyleCritical];
                [alert runModal];

                [NSApp terminate:self];
            }
        }
        return false;
    }
    return true;
}

#pragma mark - socket
-(void)createSocket{
    NSString* backend_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Backend URL"];
    _s = [[Socket alloc] initWithURL:[NSString stringWithFormat:@"%@/ws", backend_url] server_key:[LOOCryptString serverKey]];
    
    [_s setOnCloseBlock:^{
        [self updateMenuBarIcon:false];
    }];
    
    [_s setOnMessageBlock:^(NSString *message) {
        [self handleSocketMessage:message];
    }];
}

-(void)handleSocketMessage:(NSString*)message{
    if([message isEqual: @"Invalid Credentials"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Invalid Credentials!"];
            [alert setInformativeText:@"For some suspicious reason your credentials have been altered. Would you like new ones"];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No"];
            
            NSInteger button = [alert runModal];
            if (button == NSAlertFirstButtonReturn) [User newCredentials];
        });
    }else{
        [self updateMenuBarIcon:false];
        
        NSError* error = nil;
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary* json_dic = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
        if(!error){
            BOOL shouldRefresh = false;
            NSMutableArray* incoming_notifications = [[NSMutableArray alloc] init];
            
            // get all the notifications from json_dic and tell the server
            // that they have been received.
            // each notification comes with an encrypted unique "id:" tag
            NSString* ids = @"";
            for (NSDictionary* notification in json_dic) {
                NSString* notification_id = [notification objectForKey:@"id"];
                if ([notification_id intValue] > 0){
                    ids = [NSString stringWithFormat:@"%@,%@", ids, notification_id];
                }
                [Notification storeNotificationDic:notification];
                [incoming_notifications addObject:notification];
                shouldRefresh = true;
            }
            
            // send ids to be deleted from server
            if(_s.connected && [ids length] > 0){
                [_s send:[ids substringFromIndex:1]]; // removes initial ','
            }
            
            if(shouldRefresh){
                //update ui and add notifications
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL has_created_new_table = false;
                    if(!_window.notification_table || _window.notifications == nil){
                        has_created_new_table = true;
                        [_window setWindowBody];
                    }else if(_window.notification_table && _window.scroll_view.documentView != _window.notification_table){
                        // showing original notification table rather than creating it
                        _window.scroll_view.documentView = _window.notification_table;
                    }
                    
                    if(!has_created_new_table){
                        for (NSDictionary* dic in incoming_notifications){
                            [_window.notifications insertObject:[_window createNotificationFromDic:dic] atIndex:0];
                            [_window.notification_table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
                        }
                        [_window animate:NO scroll:true];
                    }
                    
                    [self updateMenuBarIcon:true];
                });
                
                if([incoming_notifications count] <= 5){
                    //send notification individualy
                    for (NSDictionary* notification in incoming_notifications){
                        if(![_window isKeyWindow]){
                            [self sendLocalNotification:[notification objectForKey:@"title"]
                                                message:[notification objectForKey:@"message"]
                                               imageURL:[notification objectForKey:@"image"]
                                                   link:[notification objectForKey:@"link"]
                                                     ID:[[notification objectForKey:@"id"] intValue]
                             ];
                        }
                    }
                }else{
                    //send notification with the amount of notifications rather than each individual notifications
                    NSUserNotification *note = [[NSUserNotification alloc] init];
                    [note setHasActionButton:false];
                    [note setTitle:@"notifi"];
                    [note setInformativeText:[NSString stringWithFormat:@"You have %d new notifications!",(int)[incoming_notifications count]]];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
                }
            }
        }else{
            DDLogVerbose(@"Unrecognised message from socket: %@", message);
        }
    }
}

-(void)updateMBIcon:(NSNotification*)obj{
    bool ani = (bool)obj.userInfo;
    [self updateMenuBarIcon:ani];
}

-(void)updateMenuBarIcon:(bool)ani{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSImage* error_icon = [NSImage imageNamed:@"menu_error_bellicon.png" ];
        NSImage* alert_icon = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
        NSImage* menu_icon = [NSImage imageNamed:@"menu_bellicon.png" ];
        
        [_window.error_label setHidden:true];
        
        if(!_s.connected){
            if([_menu_bar getImage] != error_icon){
                _menu_bar.image = error_icon;
                _menu_bar.after_image = error_icon;
                [_window.error_label setStringValue:@"Network Error"];
                [_window.error_label setHidden:false];
            }
        }else if([_window numUnreadNotifications] > 0){
            if(ani){
                [_menu_bar animateBell];
            }else{
                _menu_bar.image = alert_icon;
            }
        }else{
            if([_menu_bar getImage] != menu_icon){
                _menu_bar.image = menu_icon;
                _menu_bar.after_image = menu_icon;
            }
        }
    });
}

#pragma mark - desktop notifications
-(void)sendLocalNotification:(NSString*)title message:(NSString*)mes imageURL:(NSString*)imgURL link:(NSString*)url ID:(unsigned long)ID{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    //pass variables through notification
    notification.userInfo = @{
        @"ID" : [NSString stringWithFormat:@"%lu", ID],
        @"url" : url
    };
    
    [notification setTitle:title];
    
    if([mes length] != 0) [notification setInformativeText:mes];
    
    if([imgURL length] != 0){
        NSImage* image;
        @try {
            image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgURL]];
            [notification setContentImage:image];
        }
        @catch (NSException * e) {
            DDLogVerbose(@"Problem loading image from URL: %@", imgURL);
        }
    }
    
    [notification setActionButtonTitle:@"Open Link"];
    if([url length] != 0){
        [notification setHasActionButton:true];
    }else{
        [notification setHasActionButton:false];
    }
    [notification setSoundName:@"Pop"];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"sticky_notification"]){
        // remove notification after ceratain amount of time depending
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, STICKYTIME * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification: notification];
        });
    }
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    bool openWindow = true;
    if(notification.userInfo[@"ID"]){
        int ID = [notification.userInfo[@"ID"] intValue];
        NSString* url_string = notification.userInfo[@"url"];
        
        NSURL* url;
        if([url_string length] != 0){
            @try {
                url = [NSURL URLWithString:url_string];
                openWindow = false;
            } @catch (NSException *exception) {
                DDLogVerbose(@"Not a valid link url - %@", url_string);
            }
        }
        
        if(url) [[NSWorkspace sharedWorkspace] openURL:url];
        [[_window notificationFromID:ID] markRead];
    }
    
    if(notification.activationType == NSUserNotificationActivationTypeContentsClicked){
        [_window showWindowAtMenuBarRect:[[_menu_bar.statusItem valueForKey:@"window"] frame]];
    }else{
        [_window closeWindow];
    }
    
    [center removeDeliveredNotification: notification];
}
@end
