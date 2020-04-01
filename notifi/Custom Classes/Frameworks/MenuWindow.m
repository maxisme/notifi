//
//  MenuWindow.m
//  notifi
//
//  Created by Maximilian Mitchell on 16/02/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "MenuWindow.h"
#import "CustomVars.h"


@implementation MenuWindow

-(id)initWithWidth:(int)width height:(int)height colour:(NSColor*)colour{
    if (self != [super init]) return nil;
    
    NSRect view_frame = NSMakeRect(0, 0, width, height);
    
    self = [self initWithContentRect:view_frame styleMask:0 backing:NSBackingStoreBuffered defer:YES];
    [self setIdentifier:@"default"];
    [self setOpaque:NO];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setReleasedWhenClosed: NO];
    [self setDelegate:(id)self];
    [self setHasShadow: YES];
    [self setHidesOnDeactivate:YES];
    [self setLevel:NSFloatingWindowLevel];
    
    // create view for window
    _view = [self contentView];
    [_view setWantsLayer:YES];
    _view.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    // add 'window to menu' image
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(0, 0)];
    [path lineToPoint:NSMakePoint(50, 100)];
    [path lineToPoint:NSMakePoint(100, 0)];
    [path closePath];
    [[NSColor redColor] set];
    [path fill];
    
    // up arrow
    NSImage *up = [NSImage imageNamed:@"up_arrow.png"];
    _window_to_menu_img = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [CustomVars windowToMenuBar], [CustomVars windowToMenuBar])];
    [_window_to_menu_img setImage:up];
    [_view addSubview:_window_to_menu_img];
    
    // fill background
    NSTextField* bg = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, width, height + 5)]; // for some reason _window_to_menu_img has padding (5)
    bg.backgroundColor = colour;
    bg.editable = false;
    bg.bordered = false;
    bg.wantsLayer = true;
    bg.layer.cornerRadius = 10.0f;
    [_view addSubview:bg];
    
    // send notification that window has closed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeWindow) name:NSWindowDidResignKeyNotification object:nil];
    
    return self;
}

-(void)showWindowAtMenuBarRect:(NSRect)pos{
    self.alphaValue = 0;
    
    [self setPosition:pos];
    [self makeKeyAndOrderFront: nil];
    [self orderFrontRegardless];
    
    [NSApp activateIgnoringOtherApps:YES];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = [CustomVars notificationAnimationDuration];
        self.animator.alphaValue = 1.0f;
    }completionHandler:^{
        [_view setNeedsDisplay:YES];
        [_view setNeedsLayout:YES];
        [_view setNeedsUpdateConstraints:YES];
        [_view layoutSubtreeIfNeeded];
    }];
}

-(void)closeWindow{
    [self close];
    [self orderOut:self];
    self.alphaValue = 0;
}

-(void)setPosition:(NSRect)menu_bar_rect{
    // position variables
    float window_height = self.frame.size.height;
    float window_width = self.frame.size.width;
    float menu_icon_width = menu_bar_rect.size.width;
    float menu_icon_x = menu_bar_rect.origin.x;
    float menu_icon_y = menu_bar_rect.origin.y;
    
    // position calculations
    float arrow_x = window_width / 2 - ([CustomVars windowToMenuBar] / 2);
    float arrow_y = window_height - [CustomVars windowToMenuBar];
    float window_x = (menu_icon_x + menu_icon_width/2) - window_width / 2;
    float window_y = menu_icon_y - window_height;
    
    // set positions
    [_window_to_menu_img setFrame:NSMakeRect(arrow_x, arrow_y, [CustomVars windowToMenuBar], [CustomVars windowToMenuBar])];
    [self setFrame:NSMakeRect(window_x, window_y, window_width, window_height) display:true];
}

- (BOOL) canBecomeKeyWindow{ return YES; }
@end
