//
//  NotificationImage.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "NotificationImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation NotificationImage

-(void)setImageFromURL:(NSString*)url hw:(int)hw{
    NSData* image_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSImage* img = [self imageResize:[[NSImage alloc] initWithData:image_data] hw:hw];
    [self setImage:img];
}

- (NSImage *)imageResize:(NSImage*)anImage hw:(int)hw {
    NSImage *sourceImage = anImage;
    
    float imageWidth = [sourceImage size].width;
    float imageHeight = [sourceImage size].height;
    
    if (imageWidth > imageHeight){
        imageHeight = imageHeight * (hw / imageWidth);
        imageWidth = hw;
    }else{
        imageWidth = imageWidth * (hw / imageHeight);
        imageHeight = hw;
    }
    
    NSSize newSize = NSMakeSize(imageWidth, imageHeight);
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    } else {
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}

- (void)mouseDown:(NSEvent *)event {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.url]];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    //use link cursor
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:1.0];
    flash.toValue = [NSNumber numberWithFloat:0.8];
    flash.duration = 0.5;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [super resetCursorRects];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:0.8];
    flash.toValue = [NSNumber numberWithFloat:1.0];
    flash.duration = 0.5;
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
