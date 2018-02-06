//
//  ControllButton.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "ControllButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation ControlButton
-(void)mouseEntered:(NSEvent *)theEvent {
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:1];
    
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if((int)[notifications count] != 0){
        [super resetCursorRects];
        [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
        
        flash.toValue = [NSNumber numberWithFloat:self.opacity_min];
    }
    
    flash.duration = 0.2;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
}

-(void)mouseExited:(NSEvent *)theEvent{
    [super resetCursorRects];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    flash.fromValue = [NSNumber numberWithFloat:self.opacity_min];
    
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if((int)[notifications count] != 0){
        flash.toValue = [NSNumber numberWithFloat:1];
    }
    
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

