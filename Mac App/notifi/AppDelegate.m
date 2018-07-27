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
#import "Keys.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    [CustomFunctions onlyOneInstanceOfApp];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] || ![[[Keys alloc] init] getKey:@"credential_key"]){
        // first time using app
        [User newCredentials];
        [CustomFunctions openOnStartup];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"sticky_notification"];
    }
    
    MainWindow* mw = [[MainWindow alloc] init];
    MenuBarClass* mb = [[MenuBarClass alloc] initWithStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] window:mw];
    [[[User alloc] initWithMenuBar:mb] createSocket];
    
    [CustomFunctions checkForUpdate:false];
}
@end
