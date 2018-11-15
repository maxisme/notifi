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
#import "User.h"

@implementation SettingsMenu

-(id)init {
    if (self != [super init]) return nil;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]) return self;
    
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
    
    _show_on_startup = [[NSMenuItem alloc] initWithTitle:@"Open notifi at Login" action:@selector(toggleOpenOnStartup) keyEquivalent:@""];
    [_show_on_startup setTarget:self];
    if([CustomFunctions doesAlreadyOpenOnStartup]){
        [_show_on_startup setState:NSOnState];
    }else{
        [_show_on_startup setState:NSOffState];
    }
    [self addItem:_show_on_startup];
    
    [self addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* rec = [[NSMenuItem alloc] initWithTitle:@"How do I receive Notifications?" action:@selector(howToRec) keyEquivalent:@""];
    [rec setTarget:self];
    [self addItem:rec];
    
    NSMenuItem* updates = [[NSMenuItem alloc] initWithTitle:@"Check for Updates..." action:@selector(checkUpdate) keyEquivalent:@""];
    [updates setTarget:self];
    [self addItem:updates];
    
    NSMenuItem* about = [[NSMenuItem alloc] initWithTitle:@"About..." action:@selector(showAbout) keyEquivalent:@""];
    [about setTarget:self];
    [self addItem:about];
    
    NSMenuItem* view_log = [[NSMenuItem alloc] initWithTitle:@"Open Logs..." action:@selector(showLoggingFile) keyEquivalent:@""];
    [view_log setTarget:self];
    [self addItem:view_log];
    
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
-(void)checkUpdate{
    [CustomFunctions checkForUpdate:true];
}

-(void)toggleOpenOnStartup{
    [CustomFunctions toggleOpenOnStartup];
    [self init];
}

-(void)showLoggingFile{
    [[NSWorkspace sharedWorkspace] openFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"logging_path"]];
}

-(void)createNewCredentials{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Are you sure?"];
    [alert setInformativeText:@"You won't be able to receive messages using the previous credentials ever again."];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [User newCredentials];
    }
}

-(void)howToRec{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[CustomVars how_to:_credentials.title]]];
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
