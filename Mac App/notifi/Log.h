//
//  Log.h
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Log : NSObject
@property NSString* log_path;
+(void)log:(NSString*)mess;
+(void)log:(NSString*)mess error:(BOOL)error;
@end
