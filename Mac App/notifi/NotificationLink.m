//
//  Link.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "NotificationLink.h"

#import "Notification.h"

#import <QuartzCore/QuartzCore.h>

@implementation NotificationLink
- (void)mouseDown:(NSEvent *)event {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_url]];
    [_notification markRead];
}

-(void)mouseEntered:(NSEvent *)event {
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    
    //fade out
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:self.layer.opacity];
    flash.toValue = [NSNumber numberWithFloat:0.7];
    flash.duration = 0.2;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
}

-(void)mouseExited:(NSEvent *)event
{
    [super resetCursorRects];
    [self.layer removeAllAnimations];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:self.layer.opacity];
    flash.toValue = [NSNumber numberWithFloat:1.0];
    flash.duration = 0.2;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
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
@end
