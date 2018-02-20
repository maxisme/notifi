//
//  CustomFunctions.h
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface CustomFunctions : NSObject
+ (bool)openOnStartup;
+ (bool)doesAlreadyOpenOnStartup;

+ (void)onlyOneInstanceOfApp;
+ (void)quit;

+ (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font;
+ (NSString*)jsonToVal:(NSString*)json key:(NSString*)key;
+ (NSString*)dicToJsonString:(NSDictionary*)dic;
+ (NSString *)getSystemUUID;
+ (void)sendNotificationCenter:(id)message name:(NSString*)name;
+ (unsigned long)stringToUL:(NSString*)str;
+ (void)copyText:(NSString*)text;
+ (void)checkForUpdate:(bool)fg;
+ (NSImage*)setImgOriginalSize:(NSImage*)image;
@end
