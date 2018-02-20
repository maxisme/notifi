//
//  AnimateView.h
//  notifi
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Animate)
- (void) animateWithDuration:(NSTimeInterval)duration
                   animation:(void (^)(void))animationBlock;
- (void) animateWithDuration:(NSTimeInterval)duration
                   animation:(void (^)(void))animationBlock
                  completion:(void (^)(void))completionBlock;
@end
