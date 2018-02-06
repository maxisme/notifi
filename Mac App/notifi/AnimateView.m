//
//  AnimateView.m
//  notifi
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "AnimateView.h"

@implementation AnimateView
- (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
{
    [self animateWithDuration:duration animation:animationBlock completion:nil];
}
- (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    animationBlock();
    [NSAnimationContext endGrouping];
    
    if(completionBlock)
    {
        id completionBlockCopy = [completionBlock copy];
        [self performSelector:@selector(runEndBlock:) withObject:completionBlockCopy afterDelay:duration];
    }
}

- (void)runEndBlock:(void (^)(void))completionBlock
{
    completionBlock();
}
@end
