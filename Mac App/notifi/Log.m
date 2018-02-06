//
//  Log.m
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "Log.h"
#define LOG_LEVEL_DEF ddLogLevel
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "CustomFunctions.h"

@implementation Log

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

-(id)init{
    if (self != [super init]) return nil;
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 48; // 48 hour rolling files
    fileLogger.logFileManager.maximumNumberOfLogFiles = 14; // 2 weeks worth of logs
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.log_path = [[fileLogger currentLogFileInfo] filePath];
    
    // create log listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listener:) name:@"log" object:nil];
    
    return self;
}

// class functions to be called from any other class without having to `init`
+(void)log:(NSString*)mess{
    [self log:mess error:false];
}
+(void)log:(NSString*)mess error:(BOOL)error{
    NSDictionary *dict = @{ @"mess" : mess, @"error" : [NSNumber numberWithBool:error]};
    [CustomFunctions sendNotificationCenter:dict name:@"log"];
}

-(void)listener:(NSNotification*)obj{
    NSDictionary *dict = [obj userInfo];
    
    NSString* mess = dict[@"mess"];
    bool error = [dict[@"error"] boolValue];
    
    [self logging:mess error:error];
}

// actuall logger
-(void)logging:(NSString*)mess error:(BOOL)error{
    if(error){
        DDLogError(@"%@", mess);
    }else{
        DDLogVerbose(@"%@", mess);
    }
}

-(void)showLoggingFile{
    [[NSWorkspace sharedWorkspace] openFile:self.log_path];
}
@end
