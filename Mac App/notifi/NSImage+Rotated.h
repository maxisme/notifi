//
//  NSImage.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Rotated)
- (NSImage *)imageRotated:(float)degrees;
@end
