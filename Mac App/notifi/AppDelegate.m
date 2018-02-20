//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"

#import "MainWindow.h"
#import "MenuBarClass.h"

#import "CustomFunctions.h"
#import "User.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [CustomFunctions onlyOneInstanceOfApp];
    
    MainWindow* mw = [[MainWindow alloc] init];
    MenuBarClass* mb = [[MenuBarClass alloc] initWithStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] window:mw];
    [[[User alloc] initWithMenuBar:mb] createSocket];
    
    [CustomFunctions checkForUpdate:false];
}
@end
