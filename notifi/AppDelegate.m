//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"
#import <Sentry.h>

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
    [CustomFunctions onlyOneInstanceOfApp];
    
    // clear all local storage
//    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
//    NSDictionary * dict = [defs dictionaryRepresentation];
//    for (id key in dict) {
//        [defs removeObjectForKey:key];
//    }
//    [defs synchronize];
    
    // sentry
    NSString* dsn = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Dsn"];
    NSLog(@"%@", dsn);
    if (dsn != nil){
        NSError *err;
        SentryClient *client = [[SentryClient alloc] initWithDsn:dsn didFailWithError:&err];
        if(err == nil){
            [client setTags:@{@"UUID": [CustomFunctions getSystemUUID]}];
            SentryClient.sharedClient = client;
            [SentryClient.sharedClient startCrashHandlerWithError:nil];
        }
    }else{
        NSLog(@"SENTRY NOT RUNNING");
    }
    
    // logging
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7;
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // log to xcode output
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // log apple stuff
    [[NSUserDefaults standardUserDefaults] setObject:[[fileLogger currentLogFileInfo] filePath] forKey:@"logging_path"]; // store log path
    
    // custom crash handler
    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:NSLogAndHandleEveryExceptionMask];
    [[NSExceptionHandler defaultExceptionHandler] setDelegate:self];
    
    DDLogDebug(@"----- started -----");
    DDLogDebug(@"%@", [[[NSBundle mainBundle] bundleURL] URLByDeletingLastPathComponent]);
   
    NSString* credential_ref = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Credential Ref"];
    NSString* credential_key_ref = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Credential Key Ref"];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:credential_ref] || ![[[Keys alloc] init] getKey:credential_key_ref]){
        // first time using app
        DDLogDebug(@"Creating new credentials");
        if(![User newCredentials]){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Okay"];
            [alert setMessageText:@"Error fetching credentials. Please contact max@max.me.uk quoting your UUID:"];
            [alert setInformativeText:[CustomFunctions getSystemUUID]];
            [alert setAlertStyle:NSAlertStyleCritical];
            [alert runModal];
            
//            [self sendEmail:[[fileLogger currentLogFileInfo] filePath]];

            [NSApp terminate:self];
        }
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
    
    // send error to sentry
    [SentryClient.sharedClient snapshotStacktrace:^void{
        SentryEvent* event = [[SentryEvent alloc] initWithLevel:kSentrySeverityFatal];
        [event setMessage:exc];
        [SentryClient.sharedClient appendStacktraceToEvent:event];
        [SentryClient.sharedClient sendEvent:event withCompletionHandler:nil];
    }];
    
    DDLogError(@"Stack: %@", [NSThread callStackSymbols]);
    DDLogError(@"Crash Exception: %@", exc);

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Okay"];
    [alert setMessageText:@"App unexpectedly closed! We have been notified."];
    [alert setInformativeText:[NSString stringWithFormat:@"Crash Message: %@", exc]];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert runModal];

    [NSApp terminate:self]; // force close app

    return true;
}

//-(void)sendEmail:(NSString*)file_path{
//    NSURL* url = [[NSURL alloc] initFileURLWithPath:file_path];
//    NSArray* items = [NSArray arrayWithObject:url];
//    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
//    service.recipients=@[@"max@max.me.uk"];
//    service.subject= [NSString stringWithFormat:@"%@",NSLocalizedString(@"Error fetching credentials.",nil)];
//    service.delegate = self;
//    NSLog(@"canPerform %@", [service canPerformWithItems:items] ? @"YES" : @"NO");
//    [service performWithItems:items];
//}

@end
