//
//  keys.m
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "Keys.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation Keys

-(id)init{
    if (self != [super init]) return nil;
    [self setAccount:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    
    return self;
}

-(BOOL)setKey:(NSString*)service withPassword:(NSString*)pass{
    NSError* error = nil;
    
    self.service = service;
    [self setPassword:pass];
    [self save:&error];
    
    if(error){
        DDLogError(@"Error setting key: %@", [error localizedDescription]);
        return FALSE;
    }
    return TRUE;
}

-(NSString*)getKey:(NSString*)service{
    NSError* error;
    
    self.service = service;
    [self fetch:&error];
    
    if(error){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error fetching your Key!"];
        [alert setInformativeText:[NSString stringWithFormat:@"There was an error fetching your key.\r %@",error]];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return nil;
    }
    
    return [self password];
}
@end

