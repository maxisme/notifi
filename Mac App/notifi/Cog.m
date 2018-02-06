//
//  Cog.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "Cog.h"
#import <QuartzCore/QuartzCore.h>

@implementation Cog

- (void)mouseDown:(NSEvent *)event {
    [NSMenu popUpContextMenu:_customMenu withEvent:event forView:(id)self];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    [self animate];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [super resetCursorRects];
    [self.layer removeAllAnimations];
}

-(void)updateTrackingAreas
{
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
}

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)
-(void)animate{
    CGRect old = self.layer.frame;
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.layer.frame = old;
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.fillMode = kCAFillModeForwards;
    rotate.removedOnCompletion = NO;
    rotate.fromValue = [NSNumber numberWithFloat:0.0f];
    rotate.toValue = [NSNumber numberWithFloat: - M_PI * 2.0f];
    rotate.duration = 3.0f;
    rotate.cumulative = YES;
    rotate.repeatCount = 1000;
    [self.layer addAnimation:rotate forKey:@"rotationAnimation"];
}

@end
