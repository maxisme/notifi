//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"

@import Sentry;
#import <ExceptionHandling/NSExceptionHandler.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#import "MainWindow.h"
#import "MenuBarClass.h"
#import "CustomFunctions.h"
#import "User.h"
#import "Keys.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    NSError *error = nil;
    SentryClient *client = [[SentryClient alloc] initWithDsn:[[NSBundle mainBundle] infoDictionary][@"sentry_dsn"] didFailWithError:&error];
    SentryClient.sharedClient = client;
    [SentryClient.sharedClient startCrashHandlerWithError:&error];
    if (nil != error) {
        DDLogError(@"Sentry error: %@", error);
    }
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7;
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // log to xcode output
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // log apple stuff
    [[NSUserDefaults standardUserDefaults] setObject:[[fileLogger currentLogFileInfo] filePath] forKey:@"logging_path"]; // store log path
    
    // handle crashing logs
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:NSLogAndHandleEveryExceptionMask];
    [[NSExceptionHandler defaultExceptionHandler] setDelegate:self];
    
    [CustomFunctions onlyOneInstanceOfApp];
    
    DDLogDebug(@"\n----- started -----\n");
   
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] || ![[[Keys alloc] init] getKey:@"credential_key"]){
        // first time using app
        DDLogDebug(@"Creating new credentials");
        [User newCredentials];
        [CustomFunctions openOnStartup];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"sticky_notification"];
    }
    
    // create GUI
    MainWindow* mw = [[MainWindow alloc] init];
    MenuBarClass* mb = [[MenuBarClass alloc] initWithStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] window:mw];
    
    // start socket
    [[[User alloc] initWithMenuBar:mb] createSocket];
    
    [CustomFunctions checkForUpdate:false];
}

- (BOOL)exceptionHandler:(NSExceptionHandler *)sender shouldLogException:(NSException *)exception mask:(NSUInteger)aMask{
    NSString* exc = [exception reason];
    DDLogError(@"Crash Exception: %@", exc);

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Okay"];
    [alert setMessageText:@"App Crashed! We have been notified."];
    [alert setInformativeText:[NSString stringWithFormat:@"Crash Message: %@", exc]];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert runModal];
    
    [NSApp terminate:self]; // force close app
    
    return true;
}

@end
