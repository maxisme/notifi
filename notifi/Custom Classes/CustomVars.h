//
//  Colours.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface CustomVars: NSObject
+(NSColor *)black;
+(NSColor *)white;
+(NSColor *)red;
+(NSColor *)grey;
+(NSColor *)boarder;
+(NSColor *)offwhite;

+(NSString *)how_to:(NSString*)credentials;

+(int)windowWidth;
+(float)notificationAnimationDuration;
+(int)windowToMenuBar;
+(int)shrinkHeight:(bool)hasInfo;
@end
