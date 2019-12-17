//
//  MenuIcon.h
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsMenu : NSMenu
@property NSMenuItem* show_on_startup;
@property NSMenuItem* sticky_notifications;
@property NSMenuItem* credentials;
@end
