//
//  NotificationLabel.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "NotificationLabel.h"

@implementation NotificationLabel

- (void)resetCursorRects
{
    [super resetCursorRects];
}

-(id)init {
    if (self != [super init]) return nil;
    
    [self setWantsLayer:true];
    [self setRefusesFirstResponder:true];
    [self setEditable:false];
    [self setBordered:false];
    [self setSelectable:true];
    [self setDrawsBackground:false];
    
    return self;
}



- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:
(NSUInteger)charIndex{
    return NO;
}

- (void)textViewDidChangeSelection:(NSNotification *)a{
    [self refresh];
}

-(void)refresh{
    [self setNeedsDisplay:YES];
    [self setNeedsLayout:YES];
    [self setNeedsUpdateConstraints:YES];
    [self layoutSubtreeIfNeeded];
}

// prevent the default right click menu
- (NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex{
    return nil;
}

- (void)mouseDown:(NSEvent *)event{
    [self.delegate expand];
    [self refresh];
    [super mouseDown:event];
}

- (void) rightMouseDown:(NSEvent *)event {
    [self.superview rightMouseDown:event];
}

// animation params
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

