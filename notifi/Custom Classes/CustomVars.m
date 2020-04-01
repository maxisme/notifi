//
//  Colours.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "CustomVars.h"

@implementation CustomVars
+(NSColor *)black{
    return [NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
}

+(NSColor *)white{
    return [NSColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
}

+(NSColor *)red{
    return [NSColor colorWithRed:0.74 green:0.13 blue:0.13 alpha:1.0];
}

+(NSColor *)grey{
    return [NSColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];
}

+(NSColor *)boarder{
    return [NSColor colorWithRed:0.92 green:0.91 blue:0.91 alpha:1.0];
}

+(NSColor *)offwhite{
    return [NSColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
}

+(NSString *)how_to:(NSString*)credentials{
    return [NSString stringWithFormat:@"https://notifi.it/?c=%@#How-To", credentials];
}

+(int)windowToMenuBar{
    return 20;
}

+(float)notificationAnimationDuration{
    return 0.25;
}

+(int)windowWidth{
    return 350;
}

+(int)shrinkHeight:(bool)hasMessage{
    if(hasMessage) return 70;
    return 55;
}
@end
