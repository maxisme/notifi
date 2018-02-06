//
//  MenuIcon.m
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "SettingsMenu.h"
#import "CustomVars.h"
#import "CustomFunctions.h"

@implementation SettingsMenu

-(id)init {
    if (self != [super init]) return nil;
        
    _credentials = [[NSMenuItem alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] action:nil keyEquivalent:@""];
    [_credentials setTarget:self];
    [_credentials setEnabled:false];
    [self addItem:_credentials];
    
    NSMenuItem* copy = [[NSMenuItem alloc] initWithTitle:@"Copy Credentials" action:@selector(copyCredentials) keyEquivalent:@"c"];
    [copy setTarget:self];
    [copy setEnabled:true];
    [self addItem:copy];
    
    NSMenuItem* newCredentials = [[NSMenuItem alloc] initWithTitle:@"Create New Credentials" action:@selector(createNewCredentials) keyEquivalent:@""];
    [newCredentials setTarget:self];
    [self addItem:newCredentials];
    
    [self addItem:[NSMenuItem separatorItem]];
    
    _sticky_notifications = [[NSMenuItem alloc] initWithTitle:@"Sticky Notifications" action:@selector(shouldMakeSticky) keyEquivalent:@""];
    [_sticky_notifications setTarget:self];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"sticky_notification"]) [_sticky_notifications setState:NSOnState];
    [self addItem:_sticky_notifications];
    
    _show_on_startup = [[NSMenuItem alloc] initWithTitle:@"Open notifi At Login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_show_on_startup setTarget:self];
    if([CustomFunctions doesAlreadyOpenOnStartup]){
        [_show_on_startup setState:NSOnState];
    }else{
        [_show_on_startup setState:NSOffState];
    }
    [self addItem:_show_on_startup];
    
    [self addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* rec = [[NSMenuItem alloc] initWithTitle:@"How Do I Receive Notifications?" action:@selector(howToRec) keyEquivalent:@""];
    [rec setTarget:self];
    [self addItem:rec];
    
    NSMenuItem* updates = [[NSMenuItem alloc] initWithTitle:@"Check For Updates..." action:@selector(checkUpdate) keyEquivalent:@""];
    [updates setTarget:self];
    [self addItem:updates];
    
    NSMenuItem* view_log = [[NSMenuItem alloc] initWithTitle:@"View Log..." action:@selector(showLoggingFile) keyEquivalent:@""];
    [view_log setTarget:self];
    [self addItem:view_log];
    
    [self addItemWithTitle:@"About..." action:@selector(showAbout) keyEquivalent:@""];
    
    [self addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit notifi" action:@selector(quit) keyEquivalent:@"q"];
    [quit setTarget:self];
    [self addItem:quit];
//
    // Disable auto enable
    [self setAutoenablesItems:NO];
    [self setDelegate:(id)self];
    
    return self;
}

#pragma mark - menu functions

-(void)openOnStartup{
    [CustomFunctions openOnStartup];
}

-(void)createNewCredentials{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Are you sure?"];
    [alert setInformativeText:@"You won't be able to receive messages using the previous credentials ever again."];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [CustomFunctions sendNotificationCenter:nil name:@"create-credentials"];
    }
}

-(void)howToRec{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[CustomVars how_to]]];
}

-(void)copyCredentials{
    [CustomFunctions copyText:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]];
}

- (void)shouldMakeSticky{
    bool sticky_notification = ![[NSUserDefaults standardUserDefaults] boolForKey:@"sticky_notification"];
    if(!sticky_notification){
        [_sticky_notifications setState:NSOffState];
    }else{
        [_sticky_notifications setState:NSOnState];
    }
    [[NSUserDefaults standardUserDefaults] setBool:sticky_notification forKey:@"sticky_notification"];
}

// show about panel Credits.html
-(void)showAbout{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
}

-(void)quit{
    [CustomFunctions quit];
}

@end
