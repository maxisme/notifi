//
//  AppDelegate.h
//  notify
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) NSMenuItem* showOnStartupItem;
@property (nonatomic) NSMenuItem* credentialsItem;
@property (nonatomic) NSStatusItem *statusItem;

@end

