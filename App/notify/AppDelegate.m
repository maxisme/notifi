//
//  AppDelegate.m
//  notify
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self onlyOneInstanceOfApp];
    [self createStatusBarItem];
    [self initNetworkCommunication];
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self selector:@selector(check) userInfo:nil repeats:YES];
    
    //mark menu item
    int shouldOpenOnStartup = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"openOnStartup"];
    if (shouldOpenOnStartup == 0) {
        [self openOnStartup];
    }else if(shouldOpenOnStartup == 2){
        [_showOnStartupItem setState:NSOnState];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - set key

-(void)createNewCredentials{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Are you sure?"];
    [alert setInformativeText:@"You won't be able to receive messages using the previous credentials ever again."];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [self newCredentials];
    }
}

-(void)newCredentials{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *credential_key = [NSMutableString stringWithCapacity:25];
    for (NSUInteger i = 0U; i < 25; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [credential_key appendFormat:@"%C", c];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:credential_key forKey:@"credentials"];
    [_credentialsItem setTitle:credential_key];
}

#pragma mark - handle icoming notification
-(void)check{
    //sends request to server with key. The server then replies if there is a new notification.
    [self sendMessage:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]];
}

-(void)handleIncomingNotification:(NSString*)json{
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* json_dic = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:nil];
    for (NSDictionary* notification in json_dic) {
        [self sendNotification:[notification objectForKey:@"title"]
                       message:[notification objectForKey:@"message"]
                      imageURL:[notification objectForKey:@"image"]
                          link:[notification objectForKey:@"link"]
                         sound:true];
        
        [self storeNotification:notification];
    }
    
}

-(void)storeNotification:(NSDictionary*)dic{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"notify"];    // The file will go in this directory
    NSString *stored_notification_path = [path stringByAppendingPathComponent:@"notifications.txt"];
    NSString *str = [NSString stringWithFormat:@"%@", dic];
    NSError *error = nil;
    [str writeToFile:stored_notification_path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSLog(@"wrote notification to: %@ error:%@",stored_notification_path,error);
}

#pragma mark - notifications

-(void)sendNotification:(NSString*)title message:(NSString*)mes imageURL:(NSString*)imgURL link:(NSString*)url sound:(BOOL)soundOn {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    [notification setTitle:title];
    
    if(![mes  isEqual: @" "])
        [notification setInformativeText:mes];
    
    if(![imgURL  isEqual: @" "]){
        NSImage* image;
        @try {
            image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgURL]];
        }
        @catch (NSException * e) {
            NSLog(@"ERROR loading image from URL: %@",imgURL);
        }
        
        if (image)
            [notification setContentImage:image];
    }
    
    if(![url  isEqual: @" "]){
        [notification setIdentifier:url];
        [notification setHasActionButton:true];
    }else{
        [notification setHasActionButton:false];
    }
    
    if(soundOn)
        [notification setSoundName:NSUserNotificationDefaultSoundName];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSURL* url;
    @try {
        url = [NSURL URLWithString:[notification identifier]];
    } @catch (NSException *exception) {
        NSLog(@"error with link url");
    }
    
    if(url)
        [[NSWorkspace sharedWorkspace] openURL:url];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}



#pragma mark - telnet

NSInputStream* inputStream;
NSOutputStream* outputStream;
BOOL streamOpen = false;

- (void)sendMessage: (NSString*) message{ //called when the user interacts with UISwitches, is supposed to send message to server
    if(streamOpen){
        NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]]; //is ASCIIStringEncoding what I want?
        [outputStream write:[data bytes] maxLength:[data length]];
    }
}

- (void)initNetworkCommunication { //called in viewDidLoad of the view controller
    //clear input and output stream
    [inputStream setDelegate:nil];
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    inputStream = nil;
    [outputStream setDelegate:nil];
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    outputStream = nil;
    
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"81.133.172.114", 38815, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:(id)self];
    [outputStream setDelegate:(id)self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            streamOpen = true;
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = (int)[inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            [self handleIncomingNotification:output];
                        }
                    }
                }
            }
            break;

            
        case NSStreamEventErrorOccurred:
            streamOpen = false;
            NSLog(@"Can not connect to the host!");
            [NSThread sleepForTimeInterval:1.0f];
            [self initNetworkCommunication];
            break;
            
        case NSStreamEventEndEncountered:
            break;
    }
    
}

#pragma mark - menu bar
- (void)createStatusBarItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"bellicon.png" ];
    _statusItem.highlightMode = YES;
    _statusItem.menu = [self defaultStatusBarMenu];
    [_statusItem setTarget:self];
}

- (NSMenu *)defaultStatusBarMenu {
    NSMenu* mainMenu = [[NSMenu alloc] init];
    
    NSMenuItem* cred = [[NSMenuItem alloc] initWithTitle:@"Credentials:" action:nil keyEquivalent:@""];
    [cred setTarget:self];
    [cred setEnabled:false];
    [mainMenu addItem:cred];
    
    _credentialsItem = [[NSMenuItem alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] action:@selector(copyCredentials) keyEquivalent:@"c"];
    [_credentialsItem setTarget:self];
    [mainMenu addItem:_credentialsItem];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* newCredentials = [[NSMenuItem alloc] initWithTitle:@"New Credentials" action:@selector(createNewCredentials) keyEquivalent:@"n"];
    [newCredentials setTarget:self];
    [mainMenu addItem:newCredentials];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    _showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Open Notify at login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_showOnStartupItem setTarget:self];
    [mainMenu addItem:_showOnStartupItem];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit Notify" action:@selector(quit) keyEquivalent:@""];
    [quit setTarget:self];
    [mainMenu addItem:quit];
    
    // Disable auto enable
    [mainMenu setAutoenablesItems:NO];
    [mainMenu setDelegate:(id)self];
    return mainMenu;
}

-(void)copyCredentials{
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:credentials forType:NSStringPboardType];
}

#pragma mark - open on startup

-(void)openOnStartup{
    int shouldOpenOnStartup;
    if(![self loginItemExistsWithLoginItemReference]){
        [self enableLoginItemWithURL];
        [_showOnStartupItem setState:NSOnState];
        shouldOpenOnStartup = 2;
    }else{
        [self removeLoginItemWithURL];
        [_showOnStartupItem setState:NSOffState];
        shouldOpenOnStartup = 1;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:shouldOpenOnStartup forKey:@"openOnStartup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)loginItemExistsWithLoginItemReference{
    BOOL found = NO;
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in (__bridge NSArray *)loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
                found = YES;
                break;
            }
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    
    return found;
}

- (void)enableLoginItemWithURL
{
    if(![self loginItemExistsWithLoginItemReference]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        if (loginListRef) {
            // Insert the item at the bottom of Login Items list.
            LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                                 kLSSharedFileListItemBeforeFirst,
                                                                                 NULL,
                                                                                 NULL,
                                                                                 (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                                 NULL,
                                                                                 NULL);
            if (loginItemRef) {
                CFRelease(loginItemRef);
            }
            CFRelease(loginListRef);
        }
    }
}

- (void)removeLoginItemWithURL
{
    if([self loginItemExistsWithLoginItemReference]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                             kLSSharedFileListItemBeforeFirst,
                                                                             NULL,
                                                                             NULL,
                                                                             (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                             NULL,
                                                                             NULL);
        
        // Insert the item at the bottom of Login Items list.
        LSSharedFileListItemRemove(loginListRef, loginItemRef);
    }
}

#pragma mark - quit

-(void)quit{
    [NSApp terminate:self];
}

- (void)onlyOneInstanceOfApp {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        NSLog(@"already running");
        [self quit];
    }
    
}


@end
